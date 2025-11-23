import 'package:flutter/material.dart';
import 'package:labtrack/student/models/course.dart';
import 'package:labtrack/student/models/user.dart';
import 'package:labtrack/student/models/lab_item.dart';
import 'package:labtrack/student/views/checkout.dart';
import 'package:labtrack/student/services/database.dart';

/// Fetching available items, managing selection of items, and navigating to checkout screen for the [BorrowView]
class BorrowController {
  final DatabaseService _dbService = DatabaseService();
  final UserModel currentUser;
  List<LabItem> _items = [];
  List<LabItem> filteredItems = [];
  final Set<String> _selectedItemNames = {};
  Set<UserModel> _retainedGroupMembers = {};
  Course? _retainedCourse;
  List<LabItem> get items => filteredItems;
  int get selectedItemCount => _selectedItemNames.length;
  bool isSelected(LabItem item) => _selectedItemNames.contains(item.name);
  Set<String> get uniqueCategories => _items.map((item) => item.category).toSet();

  BorrowController({required this.currentUser});

  Future<void> loadItems() async {
    _items = await _dbService.getLabItems();
    filteredItems = _items;
  }

  void applyFilters({String? searchTerm, String? category}) {
    List<LabItem> result = _items;
    if (searchTerm != null && searchTerm.isNotEmpty) result = result.where((item) => item.name.toLowerCase().contains(searchTerm.toLowerCase())).toList();
    if (category != null && category.isNotEmpty) result = result.where((item) => item.category == category).toList();
    filteredItems = result;
  }

  /// Selection state toggle
  void toggleItemSelection(LabItem item, BuildContext context) {
    if (_selectedItemNames.contains(item.name)) {
      _selectedItemNames.remove(item.name);
    } else {
      if (item.stock > 0) {
        _selectedItemNames.add(item.name);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} is out of stock.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }


  /// When the user tries to navigate back to dashboard
  Future<bool> onWillPop(BuildContext context) async {
    if (_selectedItemNames.isEmpty) return true;                // Allow back navigation if cart is empty
    return await _showExitConfirmationDialog(context) ?? false; // Show dialog asking user to exit confirm
  }

  /// Navigates to the checkout view
  Future<void> navigateToCheckout(BuildContext context) async {
    final selectedLabItems = _items.where((item) => _selectedItemNames.contains(item.name)).toList();

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutView(
          currentUser: currentUser,
          selectedItems: selectedLabItems,
          initialGroupMembers: _retainedGroupMembers,
          initialCourse: _retainedCourse,
        ),
      ),
    );

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
                Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }
}