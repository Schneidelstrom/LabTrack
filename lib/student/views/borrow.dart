import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/borrow.dart';
import 'package:labtrack/student/models/lab_item.dart';
import 'package:labtrack/student/models/user.dart';
import 'package:labtrack/student/widgets/app_bar.dart';
import 'package:labtrack/student/widgets/drawer.dart';

class BorrowView extends StatefulWidget {
  final UserModel currentUser;
  const BorrowView({super.key, required this.currentUser});

  @override
  State<BorrowView> createState() => _BorrowViewState();
}
class _BorrowViewState extends State<BorrowView> {
  late final BorrowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BorrowController(currentUser: widget.currentUser);
    _controller.loadItems();
  }

  void _toggleItemSelection(LabItem item) {
    setState(() {
      _controller.toggleItemSelection(item);
    });
  }

  Future<void> _navigateToCheckout() async {
    await _controller.navigateToCheckout(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _controller.onWillPop(context),
      child: Scaffold(
        drawer: const CommonDrawer(),
        appBar: const CommonAppBar(title: 'Borrow'),
        body: Column(
          children: [
            const _SearchBar(),
            Expanded(
              child: FutureBuilder<void>(
                future: _controller.loadItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                  if (_controller.items.isEmpty) return const Center(child: Text('No items available.'));
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _controller.items.length,
                    itemBuilder: (context, index) {
                      final item = _controller.items[index];
                      final isSelected = _controller.isSelected(item);
                      return _ItemCard(item: item, isSelected: isSelected, onTap: () => _toggleItemSelection(item),);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _BottomCartBar(itemCount: _controller.selectedItemCount, onCheckoutPressed: _navigateToCheckout,),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search Item',
          hintText: 'e.g., microscope, beaker, etc.',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            onPressed: () { /* TODO: Connect to controller for filtering logic */},
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0)),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final LabItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ItemCard({required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = item.isAvailable;
    final Color cardColor = isSelected ? Colors.blue.shade50 : Colors.white;
    final Color cardBorderColor = isSelected ? Colors.blue.shade700 : Colors.grey.shade300;
    final double cardElevation = isSelected ? 6 : 3;

    return Card(
      elevation: cardElevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: cardBorderColor, width: isSelected ? 2 : 1),),
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.category,
                style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Text(item.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.stock} left',
                    style: TextStyle(
                      fontSize: 14,
                      color: isAvailable ? Colors.grey : Colors.red,
                      fontWeight:
                      isAvailable ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  isSelected ? Icon(Icons.check_circle, color: Colors.blue.shade700, size: 20) : Icon(Icons.add_circle_outline, color: Colors.grey.shade600, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomCartBar extends StatelessWidget {
  final int itemCount;
  final VoidCallback onCheckoutPressed;

  const _BottomCartBar({required this.itemCount, required this.onCheckoutPressed});

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$itemCount ${itemCount == 1 ? 'item' : 'items'} selected',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            onPressed: onCheckoutPressed,
            icon: const Icon(Icons.shopping_cart, size: 20),
            label: const Text('Checkout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }
}
