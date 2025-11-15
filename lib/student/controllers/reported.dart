import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:labtrack/student/models/report_item.dart';

/// Fetching user's past reports and handling navigation to detail view [ReportedItemsView]
class ReportedItemsController {
  List<ReportedItem> _reportedItems = [];
  List<ReportedItem> get reportedItems => _reportedItems;

  Future<void> loadReportedItems() async {
    final String jsonString = await rootBundle.loadString('lib/database/reported_items.json');
    final Map<String, dynamic> decodedJson = json.decode(jsonString);
    final List<dynamic> reportedListJson = decodedJson['reported_items'];

    _reportedItems = reportedListJson.map((jsonItem) {
      return ReportedItem(
        itemName: jsonItem['itemName'],
        reportDate: jsonItem['reportDate'],
        status: _reportStatusFromString(jsonItem['status']),
      );
    }).toList();
  }

  ReportStatus _reportStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return ReportStatus.resolved;
      case 'under_review':
        return ReportStatus.underReview;
      default:
        return ReportStatus.underReview;
    }
  }

  void viewReportDetails(BuildContext context, ReportedItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${item.itemName} report...'),),
    );
  }
}