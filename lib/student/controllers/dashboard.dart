
import 'package:flutter/material.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/views/borrow.dart';
import 'package:labtrack/student/views/penalty.dart';
import 'package:labtrack/student/views/report.dart';
import 'package:labtrack/student/views/reports.dart';
import 'package:labtrack/student/views/requests.dart';
import 'package:labtrack/student/views/returns.dart';
import 'package:labtrack/student/views/transaction_receipt.dart';
import 'package:labtrack/student/views/waitlist.dart';

/// Fetching data, managing currently displayed transaction, and handling navigation to other screens for the [DashboardView]
class DashboardController {
  List<BorrowTransaction> _borrowedItems = [];
  int _currentTransactionIndex = 0;
  bool _hasPenalty = false;
  List<Map<String, String>> _waitlistSummary = [];
  List<Map<String, String>> _returnsSummary = [];
  List<Map<String, String>> _requestsSummary = [];
  List<Map<String, String>> _reportsSummary = [];
  List<BorrowTransaction> get borrowedItems => _borrowedItems;
  int get currentTransactionIndex => _currentTransactionIndex;
  bool get hasPenalty => _hasPenalty;
  BorrowTransaction get currentTransaction => _borrowedItems[_currentTransactionIndex];
  List<Map<String, String>> get waitlistSummary => _waitlistSummary;
  List<Map<String, String>> get returnsSummary => _returnsSummary;
  List<Map<String, String>> get requestsSummary => _requestsSummary;
  List<Map<String, String>> get reportsSummary => _reportsSummary;

  Future<void> loadData() async {
    await Future.delayed(
        const Duration(milliseconds: 500));
    _borrowedItems = [
      BorrowTransaction(
        transactionId: 'TXN-00123',
        courseCode: 'BIO-101',
        courseName: 'General Biology',
        borrowerName: 'John Doe',
        dateBorrowed: '2025-11-10',
        deadlineDate: '2025-11-12',
        groupMembers: ['John Doe', 'Jane Smith'],
        borrowedItems: [
          CartItem(name: 'Microscope', quantity: 5),
          CartItem(name: 'Slide Set', quantity: 5),
        ],
      ),
      BorrowTransaction(
        transactionId: 'TXN-00124',
        courseCode: 'CHEM-103',
        courseName: 'Organic Chemistry',
        borrowerName: 'Alice Johnson',
        dateBorrowed: '2025-11-01',
        deadlineDate: '2025-11-25',
        groupMembers: ['Alice Johnson', 'Bob Brown'],
        borrowedItems: [
          CartItem(name: 'Test Tube Rack', quantity: 1),
          CartItem(name: 'Safety Goggles', quantity: 12),
        ],
      ),
    ];

    _waitlistSummary = const [
      {'name': 'BIO-1', 'status': '#2'},
      {'name': 'ENVI-1', 'status': 'PICK-UP'},
    ];
    _returnsSummary = const [
      {'name': 'BIO-2', 'status': 'COMPLETE'},
      {'name': 'PHYSICS-94', 'status': 'PARTIAL'},
    ];
    _requestsSummary = const [
      {'name': 'PHYSICS-105', 'status': '13x'},
      {'name': 'ECO-34', 'status': '16x'},
    ];
    _reportsSummary = const [
      {'name': 'Bunsen Burner', 'status': '1x'},
    ];

    _hasPenalty =
        _borrowedItems.any((item) => calculateDaysLeft(item.deadlineDate) < 0);
  }

  /// Method to calculate days left until deadline
  static int calculateDaysLeft(String deadlineDate) {
    final now = DateTime.now();
    final deadline = DateTime.parse(deadlineDate);
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  /// Move to next transaction in list
  void nextTransaction() {
    if (_borrowedItems.isEmpty) return;
    _currentTransactionIndex = (_currentTransactionIndex + 1) % _borrowedItems.length;
  }

  /// Move to previous transaction in list
  void previousTransaction() {
    if (_borrowedItems.isEmpty) return;
    _currentTransactionIndex = (_currentTransactionIndex - 1 + _borrowedItems.length) % _borrowedItems.length;
  }

  /// Sets current transaction index directly
  void setCurrentTransactionIndex(int index) {
    if (index >= 0 && index < _borrowedItems.length) _currentTransactionIndex = index;
  }

  Future<dynamic> navigateToTransactionViewer(BuildContext context) async {
    if (borrowedItems.isEmpty) return null;
    return await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionViewerView(transactions: _borrowedItems, initialIndex: _currentTransactionIndex,),
      ),
    );
  }

  void navigateToPenalty(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PenaltyView()));
  }
  void navigateToWaitlist(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WaitlistView()));
  }
  void navigateToReturns(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReturnView()));
  }
  void navigateToRequests(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RequestView()));
  }
  void navigateToReportedItems(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportedItemsView()));
  }
  void navigateToBorrow(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BorrowView()));
  }
  void navigateToReport(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportView()));
  }
}