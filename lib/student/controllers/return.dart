import 'package:flutter/material.dart';
import 'package:labtrack/student/models/return_item.dart';
import 'package:labtrack/student/services/database.dart';
import 'package:labtrack/student/services/auth.dart';
import 'package:labtrack/student/models/user.dart';

/// Fetching user return history and handling navigation to details for the [ReturnView]
class ReturnController {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  List<ReturnItem> _returnItems = [];
  List<ReturnItem> get returnItems => _returnItems;

  Future<void> loadReturnItems() async {
    final UserModel? currentUser = await _authService.getCurrentUserDetails();
    if (currentUser == null) return;
    _returnItems = await _dbService.getReturnItems(currentUser.upMail);
  }

  void viewReturnDetails(BuildContext context, ReturnItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing details for ${item.courseCode} return...'),
      ),
    );
  }
}