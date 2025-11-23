import 'package:flutter/material.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';
import 'package:labtrack/student/models/user.dart';
import 'package:labtrack/student/models/return_item.dart';
import 'package:labtrack/student/models/penalty_item.dart';
import 'package:labtrack/student/services/auth.dart';
import 'package:labtrack/student/services/database.dart';
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
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  UserModel? currentUser;
  List<BorrowTransaction> _borrowedItems = [];
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
  int _currentTransactionIndex = 0;

  /// Loads all data required for the student dashboard screen
  Future<void> loadData() async {
    currentUser = await _authService.getCurrentUserDetails();
    if (currentUser == null) {
      print("Error: Could not load current user details.");
      _borrowedItems = [];
      return;
    }

    _borrowedItems = await _dbService.getBorrowTransactions(currentUser!.upMail);
    final waitlistItems = await _dbService.getWaitlistItems(currentUser!.upMail);
    final returnItems = await _dbService.getReturnItems(currentUser!.upMail);
    final requestItems = await _dbService.getRequests(currentUser!.upMail);
    final reportedItems = await _dbService.getReportedItems(currentUser!.upMail);
    final penalties = await _dbService.getPenalties(currentUser!.upMail);

    _waitlistSummary = waitlistItems.map((item) => {
      'name': item.courseCode,
      'status': item.statusMessage
    }).toList();

    _returnsSummary = returnItems.map((item) {
      final status = item.status == ReturnStatus.complete ? 'COMPLETE' : 'PARTIAL';
      return {'name': item.courseCode, 'status': status};
    }).toList();

    _requestsSummary = requestItems.map((item) => {
      'name': item.courseCode,
      'status': '${item.itemCount}x'
    }).toList();

    _reportsSummary = reportedItems.map((item) => {'name': item.itemName, 'status': '1x'}).toList();
    _hasPenalty = penalties.any((p) => p.status == PenaltyStatus.unresolved);

    if (_borrowedItems.isNotEmpty && _currentTransactionIndex >= _borrowedItems.length) _currentTransactionIndex = 0;
  }

  /// Method to calculate days left until deadline
  static int calculateDaysLeft(String deadlineDate) {
    if (deadlineDate.isEmpty) return 0;
    final now = DateTime.now();
    final deadline = DateTime.parse(deadlineDate);
    return deadline.difference(now).inDays;
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
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not load user data. Please try again later.")));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BorrowView(currentUser: currentUser!),));
  }

  void navigateToReport(BuildContext context) {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User data not loaded. Please wait.")));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportView(currentUser: currentUser!),));
  }
}