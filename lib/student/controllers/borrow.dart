import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:labtrack/student/models/course.dart';
import 'package:labtrack/student/models/user.dart';
import 'package:labtrack/student/models/lab_item.dart';
import 'package:labtrack/student/views/checkout.dart';

/// Fetching available items, managing selection of items, and navigating to checkout screen for the [BorrowView]
class BorrowController {
  List<LabItem> _items = [];
  final Set<String> _selectedItemNames = {};
  final UserModel currentUser;
  Set<UserModel> _retainedGroupMembers = {};
  Course? _retainedCourse;
  List<LabItem> get items => _items;
  int get selectedItemCount => _selectedItemNames.length;
  bool isSelected(LabItem item) => _selectedItemNames.contains(item.name);

  BorrowController({required this.currentUser});

  Future<void> loadItems() async {
    final String jsonString = await rootBundle.loadString('lib/database/lab_items.json');
    final Map<String, dynamic> decodedJson = json.decode(jsonString);
    final List<dynamic> itemListJson = decodedJson['lab_items'];

    _items = itemListJson.map((jsonItem) {
      return LabItem(
        name: jsonItem['name'],
        stock: jsonItem['stock'],
        category: jsonItem['category'],
      );
    }).toList();
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
        builder: (context) => CheckoutView(currentUser: currentUser, selectedItems: _selectedItemNames, initialGroupMembers: _retainedGroupMembers, initialCourse: _retainedCourse,),
      ),
    );
    // Update the retained state
    if (result is Map<String, dynamic>) {
      _retainedGroupMembers = result['groupMembers'] as Set<UserModel>;
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