import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:labtrack/student/models/return_item.dart';

/// Fetching user return history and handling navigation to details for the [ReturnView]
class ReturnController {
  List<ReturnItem> _returnItems = [];
  List<ReturnItem> get returnItems => _returnItems;

  Future<void> loadReturnItems() async {
    final String jsonString = await rootBundle.loadString('lib/database/return_items.json');
    final Map<String, dynamic> decodedJson = json.decode(jsonString);
    final List<dynamic> returnListJson = decodedJson['return_items'];

    _returnItems = returnListJson.map((jsonItem) {
      return ReturnItem(
        courseCode: jsonItem['courseCode'],
        borrowDate: jsonItem['borrowDate'],
        returnDate: jsonItem['returnDate'],
        quantity: jsonItem['quantity'],
        returnedQuantity: jsonItem['returnedQuantity'],
      );
    }).toList();
  }

  void viewReturnDetails(BuildContext context, ReturnItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${item.courseCode} return...'),),
    );
  }
}