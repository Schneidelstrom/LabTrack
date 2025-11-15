import 'package:flutter/material.dart';
import 'package:labtrack/student/models/report_item.dart';

/// Fetching user's past reports and handling navigation to detail view [ReportedItemsView]
class ReportedItemsController {
  List<ReportedItem> _reportedItems = [];
  List<ReportedItem> get reportedItems => _reportedItems;

  Future<void> loadReportedItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _reportedItems = const [
      ReportedItem(
        itemName: 'Bunsen Burner',
        reportDate: '22-10-2025',
        status: ReportStatus.underReview,
      ),
      ReportedItem(
        itemName: 'Microscope Lens',
        reportDate: '15-10-2025',
        status: ReportStatus.resolved,
      ),
      ReportedItem(
        itemName: 'Beaker (500ml)',
        reportDate: '01-10-2025',
        status: ReportStatus.resolved,
      ),
    ];
  }

  void viewReportDetails(BuildContext context, ReportedItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${item.itemName} report...'),),
    );
  }
}