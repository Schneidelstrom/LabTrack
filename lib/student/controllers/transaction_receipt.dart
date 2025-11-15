import 'package:flutter/material.dart';

/// Date calculations, deriving display properties, and handling navigation for the [TransactionViewerView]
class TransactionViewerController {
  /// Calculates the number of days left until the deadline.
  int calculateDaysLeft(String deadlineDate) {
    final now = DateTime.now();
    final deadline = DateTime.parse(deadlineDate);
    final difference = deadline.difference(now);
    if (difference.isNegative && difference.inHours > -24) return -1; // .inDays truncates so a difference of -23 hours is 0 days, adjust so that any past deadline is at least -1
    return difference.inDays;
  }

  /// Determines the text to display in the status banner based on days left
  String getDaysLeftText(int daysLeft) {
    if (daysLeft < 0) return 'OVERDUE by ${daysLeft.abs()} days remaining';
    else return '${daysLeft.abs()} days remaining';
  }

  /// Determines the color of the status banner based on days left
  Color getDaysLeftColor(int daysLeft) {
    if (daysLeft < 0) return Colors.red.shade600;
    if (daysLeft == 0) return Colors.orange.shade600;
    return Colors.green.shade700;
  }

  /// Allows [DashboardView] to stay in sync with the user's last viewed transaction
  void handlePop(BuildContext context, int currentIndex) {
    Navigator.of(context).pop(currentIndex);
  }
}