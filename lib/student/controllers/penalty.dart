import 'package:flutter/material.dart';
import 'package:labtrack/student/models/penalty_item.dart';

/// Fetching penalty data and handling user actions like "Pay Now" for the [PenaltyView]
class PenaltyController {
  List<Penalty> _penalties = [];
  List<Penalty> get penalties => _penalties;

  Future<void> loadPenalties() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _penalties = const [
      Penalty(
        itemName: 'Beaker (250ml)',
        reason: 'Overdue Return',
        dateIncurred: '21-10-2025',
        amount: 5.00,
        status: PenaltyStatus.unresolved,
      ),
      Penalty(
        itemName: 'Microscope',
        reason: 'Damaged Item',
        dateIncurred: '15-10-2025',
        amount: 50.00,
        status: PenaltyStatus.unresolved,
      ),
      Penalty(
        itemName: 'Bunsen Burner',
        reason: 'Overdue Return',
        dateIncurred: '05-10-2025',
        amount: 15.00,
        status: PenaltyStatus.resolved,
      ),
    ];
  }

  void handlePayNow(BuildContext context, Penalty penalty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proceeding to pay for ${penalty.itemName} penalty...'), backgroundColor: Colors.blue.shade700,),
    );
  }
}