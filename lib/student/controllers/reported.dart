import 'package:flutter/material.dart';
import 'package:labtrack/student/models/report_item.dart';
import 'package:labtrack/student/services/database.dart';
import 'package:labtrack/student/services/auth.dart';
import 'package:labtrack/student/models/user.dart';

/// Fetching user's past reports and handling navigation to detail view [ReportedItemsView]
class ReportedItemsController {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  List<ReportedItem> _reportedItems = [];
  List<ReportedItem> get reportedItems => _reportedItems;

  Future<void> loadReportedItems() async {
    final UserModel? currentUser = await _authService.getCurrentUserDetails();
    if (currentUser == null) return;
    _reportedItems = await _dbService.getReportedItems(currentUser.upMail);
  }

  void viewReportDetails(BuildContext context, ReportedItem item) {
  /// Must navigate to a detailed report screen.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing details for ${item.itemName} report...'),
      ),
    );
  }
}