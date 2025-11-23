import 'package:flutter/material.dart';
import 'package:labtrack/student/models/request_item.dart';
import 'package:labtrack/student/services/database.dart';
import 'package:labtrack/student/services/auth.dart';
import 'package:labtrack/student/models/user.dart';

/// Fetching the user's pending requests and handling cancellations for the [RequestView]
class RequestController {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  List<RequestItem> _requests = [];
  List<RequestItem> get requests => _requests;

  Future<void> loadRequests() async {
    final UserModel? currentUser = await _authService.getCurrentUserDetails();
    if (currentUser == null) return;
    _requests = await _dbService.getRequests(currentUser.upMail);
  }

  Future<void> cancelRequest(BuildContext context, RequestItem request) async {
    try {
      await _dbService.cancelRequest(request.requestId);
      _requests.removeWhere((req) => req.requestId == request.requestId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cancelled request for ${request.courseCode}.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      print("Error cancelling request: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel request. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}