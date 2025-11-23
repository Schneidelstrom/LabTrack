import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/checkout.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/models/course.dart';
import 'package:labtrack/student/models/user.dart';
import 'package:labtrack/student/models/lab_item.dart';

/// For displaying the cart, managing group members, selecting a course, and confirming the borrow request
class CheckoutView extends StatefulWidget {
  final UserModel currentUser;
  final List<LabItem> selectedItems;
  final Set<UserModel> initialGroupMembers;
  final Course? initialCourse;

  const CheckoutView({
    super.key,
    required this.currentUser,
    required this.selectedItems,
    required this.initialGroupMembers,
    this.initialCourse,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late final CheckoutController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CheckoutController(
      currentUser: widget.currentUser,
      selectedItems: widget.selectedItems,
      initialGroupMembers: widget.initialGroupMembers,
      initialCourse: widget.initialCourse,
    );

    _controller.loadInitialData().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Checkout'),
        titleTextStyle: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white,),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => _controller.onWillPop(context),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _GroupMemberSearch(controller: _controller, onStateUpdate: () => setState(() {}),),
            const Text(
              'Selected Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1),),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = _controller.cartItems[index];
                  return _CartItemCard(item: item, onIncrement: () => setState(() => _controller.incrementQuantity(index, context)), onDecrement: () => setState(() => _controller.decrementQuantity(index)),);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CheckoutBar(controller: _controller, onStateUpdate: () => setState(() {}),),
    );
  }
}

class _GroupMemberSearch extends StatelessWidget {
  final CheckoutController controller;
  final VoidCallback onStateUpdate;

  const _GroupMemberSearch({required this.controller, required this.onStateUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Group Members', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        const SizedBox(height: 8),
        Autocomplete<UserModel>(
          displayStringForOption: (option) => option.fullName,
          optionsBuilder: (textEditingValue) => controller.searchGroupMembers(textEditingValue.text),
          onSelected: (selection) {
            controller.addGroupMember(selection);
            onStateUpdate();
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (_) => onFieldSubmitted(),
              decoration: InputDecoration(
                labelText: 'Search Group Member by Name or UPMail',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),),
            );
          },
        ),
        const SizedBox(height: 16),
        if (controller.groupMembers.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: controller.groupMembers.map((member) {
              return Chip(
                label: Text(member.firstName),
                deleteIcon: const Icon(Icons.cancel, size: 18),
                onDeleted: () {
                  controller.removeGroupMember(member);
                  onStateUpdate();
                },
              );
            }).toList(),
          ),
        const Divider(height: 32),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            _QuantityStepper(quantity: item.quantity, onIncrement: onIncrement, onDecrement: onDecrement,),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStepButton(icon: Icons.remove, onPressed: onDecrement),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(quantity.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        _buildStepButton(icon: Icons.add, onPressed: onIncrement),
      ],
    );
  }

  Widget _buildStepButton({required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),),
        child: Icon(icon, color: const Color(0xFF0D47A1)),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final CheckoutController controller;
  final VoidCallback onStateUpdate;
  const _CheckoutBar({required this.controller, required this.onStateUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 12, offset: const Offset(0, -2))
        ],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<Course?>(
            value: controller.selectedCourse,
            items: controller.allCourses.map((Course course) {
              return DropdownMenuItem<Course>(
                value: course,
                child: Text(course.courseCode),
              );
            }).toList(),
            // Update state and view rebuilds
            onChanged: (newCourse) {
              if (newCourse != null) {
                controller.setSelectedCourse(newCourse);
                onStateUpdate();
              }
            },
            underline: Container(height: 2, color: Colors.blue.shade900),
          ),
          // Final checkout action
          ElevatedButton(
            onPressed: () => controller.handleCheckout(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
          ),
        ],
      ),
    );
  }
}