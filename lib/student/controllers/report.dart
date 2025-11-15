import 'package:flutter/material.dart';
import 'package:labtrack/student/models/cart_item.dart';

/// Fetching borrowed items, managing reporting state (list vs. form), and handling submission of new report for the [ReportView]
class ReportController {
  List<CartItem> _borrowedItems = [];
  bool _isReporting = false;
  CartItem? _itemToReport;
  List<CartItem> get borrowedItems => _borrowedItems;
  bool get isReporting => _isReporting;
  CartItem? get itemToReport => _itemToReport;

  Future<void> loadBorrowedItems() async {
    await Future.delayed(const Duration(milliseconds: 250));
    _borrowedItems = [
      CartItem(name: 'Microscope', quantity: 1),
      CartItem(name: 'Beaker (250ml)', quantity: 5),
      CartItem(name: 'Digital Scale', quantity: 2),
    ];
  }

  /// Switch view to report form for a specific item
  void startReporting(CartItem item) {
    _isReporting = true;
    _itemToReport = item;
  }

  /// Switch view back to list of borrowed items
  void cancelReporting() {
    _isReporting = false;
    _itemToReport = null;
  }

  /// Handle final submission of report
  void submitReport(BuildContext context) {
    print('Report submitted for ${_itemToReport?.name}');
    cancelReporting();  // Switch back to list view after submission

  // Show confirmation message to the user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.green,),
      );
    }
  }
}