import 'package:flutter/material.dart';
import 'package:labtrack/student/models/waitlist_item.dart';
import 'package:labtrack/student/services/database.dart';
import 'package:labtrack/student/services/auth.dart';
import 'package:labtrack/student/models/user.dart';

/// Fetching user waitlisted items and handling actions for cancellation for the [WaitlistView]
class WaitlistController {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  List<WaitlistItem> _waitlistItems = [];
  List<WaitlistItem> get waitlistItems => _waitlistItems;

  /// Fetching list of items the user is waitlisted for
  Future<void> loadWaitlistItems() async {
    final UserModel? currentUser = await _authService.getCurrentUserDetails();
    if (currentUser == null) return;
    _waitlistItems = await _dbService.getWaitlistItems(currentUser.upMail);
  }

  Future<void> cancelReservation(BuildContext context, WaitlistItem item) async {
    try {
      await _dbService.cancelWaitlistReservation(item.waitlistId);
      _waitlistItems.removeWhere((w) => w.waitlistId == item.waitlistId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cancelled reservation for ${item.name}.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } catch (e) {
      print("Error cancelling reservation: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel reservation. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}