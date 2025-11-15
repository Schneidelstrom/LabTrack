import 'dart:convert';
import 'package:flutter/services.dart';

/// Presentation-layer model to unify different transaction types for display
class DisplayTransaction {
  final String courseCode;
  final String status;
  final String date;
  final String type;
  const DisplayTransaction({
    required this.courseCode,
    required this.status,
    required this.date,
    required this.type,
  });
}

/// fetching and consolidating all transaction types into a single, displayable list for the [TransactionsView]
class TransactionsController {
  List<DisplayTransaction> _transactions = [];
  List<DisplayTransaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    final results = await Future.wait([
      rootBundle.loadString('lib/database/borrow_transactions.json'),
      rootBundle.loadString('lib/database/return_items.json'),
    ]);
    final List<DisplayTransaction> consolidatedList = [];

    final borrowJson = json.decode(results[0]);
    final List<dynamic> borrowList = borrowJson['borrow_transactions'];
    for (var tx in borrowList) {
      final int itemCount = (tx['borrowedItems'] as List).length;
      consolidatedList.add(
        DisplayTransaction(
          courseCode: tx['courseCode'],
          status: '$itemCount ${itemCount == 1 ? "Item" : "Items"}',
          date: tx['dateBorrowed'],
          type: 'Borrow',
        ),
      );
    }

    final returnJson = json.decode(results[1]);
    final List<dynamic> returnList = returnJson['return_items'];
    for (var item in returnList) {
      final status = (item['returnedQuantity'] as int) >= (item['quantity'] as int) ? 'COMPLETE' : 'PARTIAL';
      consolidatedList.add(
        DisplayTransaction(
          courseCode: item['courseCode'],
          status: status,
          date: item['returnDate'],
          type: 'Return',
        ),
      );
    }

    consolidatedList.sort((a, b) => b.date.compareTo(a.date));
    _transactions = consolidatedList;
  }
}