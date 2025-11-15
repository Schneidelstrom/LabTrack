import 'package:flutter/material.dart';
import 'package:labtrack/student/models/return_item.dart';

/// Fetching user return history and handling navigation to details for the [ReturnView]
class ReturnController {
  List<ReturnItem> _returnItems = [];
  List<ReturnItem> get returnItems => _returnItems;

  Future<void> loadReturnItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _returnItems = const [
      ReturnItem(
        courseCode: 'CS101',
        quantity: 5,
        returnedQuantity: 5,
        borrowDate: '15-01-2025',
        returnDate: '20-01-2025',
      ),
      ReturnItem(
        courseCode: 'PHYS205',
        quantity: 10,
        returnedQuantity: 7,
        borrowDate: '14-01-2025',
        returnDate: '18-01-2025',
      ),
      ReturnItem(
        courseCode: 'CHEM310',
        quantity: 10,
        returnedQuantity: 10,
        borrowDate: '10-01-2025',
        returnDate: '15-01-2025',
      ),
      ReturnItem(
        courseCode: 'BIO101',
        quantity: 2,
        returnedQuantity: 1,
        borrowDate: '05-01-2025',
        returnDate: '10-01-2025',
      ),
    ];
  }

  void viewReturnDetails(BuildContext context, ReturnItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${item.courseCode} return...'),),
    );
  }
}