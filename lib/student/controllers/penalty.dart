import 'package:flutter/material.dart';
import 'package:labtrack/student/models/penalty_item.dart';
import 'package:labtrack/student/services/database.dart';
import 'package:labtrack/student/services/auth.dart';
import 'package:labtrack/student/models/user.dart';

/// Fetching penalty data and handling user actions like "Pay Now" for the [PenaltyView]
class PenaltyController {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();
  List<Penalty> _penalties = [];
  List<Penalty> get penalties => _penalties;

  Future<void> loadPenalties() async {
    final UserModel? currentUser = await _authService.getCurrentUserDetails();
    if (currentUser == null) return;
    _penalties = await _dbService.getPenalties(currentUser.upMail);
  }

  Future<void> handlePayNow(BuildContext context, Penalty penalty) async {
    try {
      await _dbService.updatePenaltyStatus(penalty.penaltyId, PenaltyStatus.resolved);
      final index = _penalties.indexWhere((p) => p.penaltyId == penalty.penaltyId);

      if (index != -1) {
        _penalties[index] = Penalty(
          penaltyId: penalty.penaltyId,
          itemName: penalty.itemName,
          reason: penalty.reason,
          dateIncurred: penalty.dateIncurred,
          amount: penalty.amount,
          status: PenaltyStatus.resolved,
          penalizedUpMail: penalty.penalizedUpMail,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment for ${penalty.itemName} recorded.'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      print("Error updating penalty status: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record payment. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}