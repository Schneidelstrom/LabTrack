import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:labtrack/student/models/borrow_transaction.dart';
import 'package:labtrack/student/models/cart_item.dart';
import 'package:labtrack/student/models/user.dart';
import 'package:labtrack/student/auth.dart';
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
  final AuthService _authService = AuthService();
  UserModel? currentUser;

  Future<void> loadData() async {
    currentUser = await _authService.getCurrentUserDetails();
    final results = await Future.wait([
      rootBundle.loadString('lib/database/borrow_transactions.json'),
      rootBundle.loadString('lib/database/waitlist_items.json'),
      rootBundle.loadString('lib/database/return_items.json'),
      rootBundle.loadString('lib/database/request_items.json'),
      rootBundle.loadString('lib/database/reported_items.json'),
      rootBundle.loadString('lib/database/penalties.json'),
    ]);
    final borrowTxJson = json.decode(results[0]);
    final List<dynamic> borrowTxList = borrowTxJson['borrow_transactions'];

    _borrowedItems = borrowTxList.map((tx) {
      final List<dynamic> itemsJson = tx['borrowedItems'];
      return BorrowTransaction(
        transactionId: tx['transactionId'],
        courseCode: tx['courseCode'],
        courseName: tx['courseName'],
        borrowerName: tx['borrowerName'],
        dateBorrowed: tx['dateBorrowed'],
        deadlineDate: tx['deadlineDate'],
        groupMembers: List<String>.from(tx['groupMembers']),
        borrowedItems: itemsJson.map((item) => CartItem(name: item['name'], quantity: item['quantity'])).toList(),
      );
    }).toList();

    final waitlistJson = json.decode(results[1]);
    _waitlistSummary = (waitlistJson['waitlist_items'] as List<dynamic>).map((item) => <String, String>{'name': item['courseCode'], 'status': item['statusMessage']}).toList();

    final returnsJson = json.decode(results[2]);
    _returnsSummary = (returnsJson['return_items'] as List<dynamic>).map((item) {
      final status = (item['returnedQuantity'] as int) >= (item['quantity'] as int) ? 'COMPLETE' : 'PARTIAL';
      return <String, String>{'name': item['courseCode'], 'status': status};
    }).toList();

    final requestsJson = json.decode(results[3]);
    _requestsSummary = (requestsJson['request_items'] as List<dynamic>).map((item) => <String, String>{'name': item['courseCode'], 'status': '${item['itemCount']}x'}).toList();

    final reportsJson = json.decode(results[4]);
    _reportsSummary = (reportsJson['reported_items'] as List<dynamic>).map((item) => <String, String>{'name': item['itemName'], 'status': '1x'}).toList();

    final penaltiesJson = json.decode(results[5]);
    _hasPenalty = (penaltiesJson['penalties'] as List<dynamic>).any((p) => p['status'] == 'unresolved');
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