import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/models/report_item.dart';
import 'package:labtrack/student/models/user.dart';
import 'package:labtrack/student/services/database.dart';

/// Fetching borrowed items, managing reporting state (list vs. form), and handling submission of new report for the [ReportView]
class ReportController {
  final DatabaseService _dbService = DatabaseService();
  final UserModel currentUser;
  List<CartItem> _borrowedItems = [];
  bool _isReporting = false;
  CartItem? _itemToReport;
  List<CartItem> get borrowedItems => _borrowedItems;
  bool get isReporting => _isReporting;
  CartItem? get itemToReport => _itemToReport;

  ReportController({required this.currentUser});

  Future<void> loadBorrowedItems() async {
    final allTransactions = await _dbService.getBorrowTransactions(currentUser.upMail);
    final userTransactions = allTransactions.where((tx) => tx.groupMembers.contains(currentUser.upMail)).toList();
    final Map<String, int> aggregatedItems = {};

    for (var transaction in userTransactions) {
      for (var item in transaction.borrowedItems) {
        aggregatedItems.update(item.name, (value) => value + item.quantity,
            ifAbsent: () => item.quantity);
      }
    }

    _borrowedItems = aggregatedItems.entries.map((entry) {
      return CartItem(name: entry.key, quantity: entry.value);
    }).toList();
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
  Future<void> submitReport(BuildContext context) async {
    if (_itemToReport == null) return;

    final newReport = ReportedItem(
      reportId: 'TNREP-${DateFormat('yyyy-MM-dd').format(DateTime.now())}-${currentUser.studentId}-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      itemName: _itemToReport!.name,
      reporterUpMail: currentUser.upMail,
      reportDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      status: ReportStatus.underReview,
    );

    await _dbService.addReport(newReport);
    cancelReporting();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}