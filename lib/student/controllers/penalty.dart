import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:labtrack/student/models/penalty_item.dart';

/// Fetching penalty data and handling user actions like "Pay Now" for the [PenaltyView]
class PenaltyController {
  List<Penalty> _penalties = [];
  List<Penalty> get penalties => _penalties;

  Future<void> loadPenalties() async {
    final String jsonString = await rootBundle.loadString('lib/database/penalties.json');
    final Map<String, dynamic> decodedJson = json.decode(jsonString);
    final List<dynamic> penaltyListJson = decodedJson['penalties'];

    _penalties = penaltyListJson.map((jsonItem) {
      return Penalty(
        itemName: jsonItem['itemName'],
        reason: jsonItem['reason'],
        dateIncurred: jsonItem['dateIncurred'],
        amount: (jsonItem['amount'] as num).toDouble(),
        status: _penaltyStatusFromString(jsonItem['status']),
      );
    }).toList();
  }

  PenaltyStatus _penaltyStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return PenaltyStatus.resolved;
      case 'unresolved':
        return PenaltyStatus.unresolved;
      default:
        return PenaltyStatus.unresolved;
    }
  }

  void handlePayNow(BuildContext context, Penalty penalty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proceeding to pay for ${penalty.itemName} penalty...'), backgroundColor: Colors.blue.shade700,),
    );
  }
}