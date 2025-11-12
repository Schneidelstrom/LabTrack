import 'package:flutter/material.dart';
import 'package:labtrack/student/screens/checkout.dart';
import 'package:labtrack/student/reusables.dart';
import 'package:labtrack/student/models/group_member.dart';
import 'package:labtrack/student/models/course.dart';

class _DummyItem {
  final String name;
  final int stock;
  final String category;

  const _DummyItem({required this.name, required this.stock, required this.category});
}

class StudentBorrow extends StatefulWidget {
  const StudentBorrow({super.key});

  @override
  State<StudentBorrow> createState() => _StudentBorrowState();
}

class _StudentBorrowState extends State<StudentBorrow> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<String> _selectedItemNames = {};
  Set<GroupMember> _currentGroupMembers = {};
  Course? _currentCourse;

  final List<_DummyItem> _items = const [
    _DummyItem(name: 'Beaker', stock: 5, category: 'Glassware'),
    _DummyItem(name: 'Microscope', stock: 0, category: 'Equipment'),
    _DummyItem(name: 'Bunsen Burner', stock: 8, category: 'Heating'),
    _DummyItem(name: 'Test Tubes', stock: 25, category: 'Glassware'),
    _DummyItem(name: 'Digital Scale', stock: 3, category: 'Measurement'),
    _DummyItem(name: 'Petri Dish', stock: 50, category: 'Glassware'),
    _DummyItem(name: 'Safety Goggles', stock: 12, category: 'Safety'),
    _DummyItem(name: 'Graduated Cylinder', stock: 0, category: 'Measurement'),
  ];

  void _toggleItemSelection(_DummyItem item) {
    setState(() {
      if (_selectedItemNames.contains(item.name)) {
        _selectedItemNames.remove(item.name);
      } else {
        _selectedItemNames.add(item.name);
      }
    });
    print('Current selected items: ${_selectedItemNames.length}');
  }

  Future<void> _navigateToCheckout() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentCheckout(
          selectedItems: _selectedItemNames,
          initialGroupMembers: _currentGroupMembers,
          initialCourse: _currentCourse,
        ),
      ),
    );

    if (result is Map<String, dynamic>) {
      setState(() {
        _currentGroupMembers = result['groupMembers'] as Set<GroupMember>;
        _currentCourse = result['courseCode'] as Course?;

        print('Group members retained: ${_currentGroupMembers.map((m) => m.name).join(', ')}');
        print('Course Code retained: ${_currentCourse?.code}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: buildAppDrawer(context, selectedIndex: 0),
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          title: const Text('Borrow'),
          titleTextStyle: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          elevation: 10,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          shadowColor: Colors.black,
          actions: [
            buildProfilePopupMenuButton(context),
          ],
        ),
        body: Column(
          children: [
            const _SearchBar(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final isSelected = _selectedItemNames.contains(item.name);

                  return _ItemCard(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => _toggleItemSelection(item),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _BottomCartBar(itemCount: _selectedItemNames.length, selectedItemNames: _selectedItemNames, onCheckoutPressed: _navigateToCheckout)
      ),
    );
  }
  Future<bool> _onWillPop(BuildContext context) async {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
      return false;
    }
    if (_selectedItemNames.isNotEmpty) {
      return await _showExitConfirmationDialog(context) ?? false;
    }
    return true;
  }
}

class _BottomCartBar extends StatelessWidget {
  final Set<String> selectedItemNames;
  final int itemCount;
  final VoidCallback onCheckoutPressed;

  const _BottomCartBar({required this.itemCount, required this.selectedItemNames, required this.onCheckoutPressed});

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -5)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton.icon(
            onPressed: onCheckoutPressed,
            icon: const Icon(Icons.shopping_cart, size: 20),
            label: const Text(
              'Go to Borrow Cart',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
            ),
          ),
        ],
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
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            onPressed: () => print('Filter button pressed!')
              /* TODO: Implement the filtering logic (e.g., show a dialog or bottom sheet) */
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0)),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final _DummyItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ItemCard({required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = item.stock > 0;
    final Color cardColor = isSelected ? Colors.blue.shade50 : Colors.white;
    final Color cardBorderColor = isSelected ? Colors.blue.shade700 : Colors.grey.shade300;
    final double cardElevation = isSelected ? 6 : 3;
    final Widget indicatorIcon = isSelected ? Icon(Icons.check_circle, color: Colors.blue.shade700, size: 20) : Icon(Icons.add_circle_outline, color: Colors.grey.shade600, size: 20);

    return Card(
      elevation: cardElevation,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: cardBorderColor, width: isSelected ? 2 : 1)),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
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
                      color: isAvailable ? Colors.grey[600] : Colors.red,
                      fontWeight: isAvailable ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        isSelected ? 'Added' : 'Tap to Add',
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.blue.shade700 :  Colors.grey[600],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      indicatorIcon,
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> _showExitConfirmationDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Return to Dashboard?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'All selections will be reset.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/dashboard', (Route<dynamic> route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}