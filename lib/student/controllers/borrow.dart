import 'package:flutter/material.dart';
import 'package:labtrack/student/models/course.dart';
import 'package:labtrack/student/models/group_member.dart';
import 'package:labtrack/student/models/lab_item.dart';
import 'package:labtrack/student/views/checkout.dart';

/// Fetching available items, managing selection of items, and navigating to checkout screen for the [BorrowView]
class BorrowController {
  List<LabItem> _items = [];
  final Set<String> _selectedItemNames = {};
  Set<GroupMember> _retainedGroupMembers = {};
  Course? _retainedCourse;
  List<LabItem> get items => _items;
  int get selectedItemCount => _selectedItemNames.length;
  bool isSelected(LabItem item) => _selectedItemNames.contains(item.name);

  Future<void> loadItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items = const [
      LabItem(name: 'Beaker', stock: 5, category: 'Glassware'),
      LabItem(name: 'Microscope', stock: 0, category: 'Equipment'),
      LabItem(name: 'Bunsen Burner', stock: 8, category: 'Heating'),
      LabItem(name: 'Test Tubes', stock: 25, category: 'Glassware'),
      LabItem(name: 'Digital Scale', stock: 3, category: 'Measurement'),
      LabItem(name: 'Petri Dish', stock: 50, category: 'Glassware'),
      LabItem(name: 'Safety Goggles', stock: 12, category: 'Safety'),
      LabItem(name: 'Graduated Cylinder', stock: 0, category: 'Measurement'),
    ];
  }

  /// Selection state toggle
  void toggleItemSelection(LabItem item) {
    if (_selectedItemNames.contains(item.name)) {
      _selectedItemNames.remove(item.name);
    } else {
      _selectedItemNames.add(item.name);
    }
  }

  /// When the user tries to navigate back to dashboard
  Future<bool> onWillPop(BuildContext context) async {
    if (_selectedItemNames.isEmpty) return true;                // Allow back navigation if cart is empty
    return await _showExitConfirmationDialog(context) ?? false; // Show dialog asking user to exit confirm
  }

  /// Navigates to the checkout view, passing the current state.
  /// It awaits the result from the checkout view to update its retained state.
  Future<void> navigateToCheckout(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutView(selectedItems: _selectedItemNames, initialGroupMembers: _retainedGroupMembers, initialCourse: _retainedCourse,),
      ),
    );
    // Update the retained state
    if (result is Map<String, dynamic>) {
      _retainedGroupMembers = result['groupMembers'] as Set<GroupMember>;
      _retainedCourse = result['course'] as Course?;
    }
  }

  /// Display confirmation dialog to user before exiting screen
  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Return to Dashboard?'),
          content: const Text('All your selected items will be cleared.'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
                Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false,);
              },
            ),
          ],
        );
      },
    );
  }
}