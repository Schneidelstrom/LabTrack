import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/checkout.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/models/course.dart';
import 'package:labtrack/student/models/group_member.dart';

/// The UI for the checkout process.
/// This view is responsible for displaying the cart, managing group members,
/// selecting a course, and confirming the borrow request. All logic is
/// handled by the [CheckoutController].
class CheckoutView extends StatefulWidget {
// Initial data passed from the BorrowView.
  final Set<String> selectedItems;
  final Set<GroupMember> initialGroupMembers;
  final Course? initialCourse;

  const CheckoutView({
    super.key,
    required this.selectedItems,
    required this.initialGroupMembers,
    this.initialCourse,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
// The controller manages all state and business logic for the checkout process.
  late final CheckoutController _controller;

  @override
  void initState() {
    super.initState();
// Initialize the controller with the data passed to this widget.
    _controller = CheckoutController(
      selectedItemNames: widget.selectedItems,
      initialGroupMembers: widget.initialGroupMembers,
      initialCourse: widget.initialCourse,
    );
// Load any necessary data for the controller.
    _controller.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
// The back button now pops with the current state from the controller.
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text('Checkout'),
        titleTextStyle: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _controller.onWillPop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
// Group member search and display widget.
            _GroupMemberSearch(
              controller: _controller,
              onStateUpdate: () => setState(() {}),
            ),
            const Text(
              'Selected Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),
// List of items in the cart.
            Expanded(
              child: ListView.builder(
                itemCount: _controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = _controller.cartItems[index];
                  return _CartItemCard(
                    item: item,
// Quantity changes are handled by the controller, followed by a UI update.
                    onIncrement: () => setState(() => _controller.incrementQuantity(index)),
                    onDecrement: () => setState(() => _controller.decrementQuantity(index)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CheckoutBar(
        controller: _controller,
        onStateUpdate: () => setState(() {}),
      ),
    );
  }
}

// --- Private UI Widgets ---

class _GroupMemberSearch extends StatelessWidget {
  final CheckoutController controller;
  final VoidCallback onStateUpdate;

  const _GroupMemberSearch(
      {required this.controller, required this.onStateUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Group Members',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1))),
        const SizedBox(height: 8),
        Autocomplete<GroupMember>(
          displayStringForOption: (option) => option.name,
// The search logic is delegated to the controller.
          optionsBuilder: (textEditingValue) =>
              controller.searchGroupMembers(textEditingValue.text),
          onSelected: (selection) {
// The controller handles adding the member, then the view updates.
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
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
// The list of chips is built from the controller's state.
        if (controller.groupMembers.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: controller.groupMembers.map((member) {
              return Chip(
                label: Text(member.name),
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

  const _CartItemCard(
      {required this.item,
        required this.onIncrement,
        required this.onDecrement});

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
            Text(item.name,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            _QuantityStepper(
              quantity: item.quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
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

  const _QuantityStepper(
      {required this.quantity,
        required this.onIncrement,
        required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStepButton(icon: Icons.remove, onPressed: onDecrement),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(quantity.toString(),
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        _buildStepButton(icon: Icons.add, onPressed: onIncrement),
      ],
    );
  }

  Widget _buildStepButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
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
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -2))
        ],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
// The dropdown's value and items come from the controller.
          DropdownButton<Course?>(
            value: controller.selectedCourse,
            items: controller.allCourses.map((Course course) {
              return DropdownMenuItem<Course>(
                value: course,
                child: Text(course.code),
              );
            }).toList(),
            onChanged: (newCourse) {
// The controller updates its state, and the view rebuilds.
              if (newCourse != null) {
                controller.setSelectedCourse(newCourse);
                onStateUpdate();
              }
            },
            underline: Container(height: 2, color: Colors.blue.shade900),
          ),
          ElevatedButton(
// The final checkout action is a single method call on the controller.
            onPressed: () => controller.handleCheckout(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Checkout',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1))),
          ),
        ],
      ),
    );
  }
}