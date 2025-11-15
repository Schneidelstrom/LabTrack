import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:labtrack/student/models/waitlist_item.dart';

/// Fetching user waitlisted items and handling actions for cancellation for the [WaitlistView]
class WaitlistController {
  List<WaitlistItem> _waitlistItems = [];
  List<WaitlistItem> get waitlistItems => _waitlistItems;

  /// Simulates fetching list of items the user is waitlisted for
  Future<void> loadWaitlistItems() async {
    final String jsonString = await rootBundle.loadString('lib/database/waitlist_items.json');
    final Map<String, dynamic> decodedJson = json.decode(jsonString);
    final List<dynamic> waitlistListJson = decodedJson['waitlist_items'];

    _waitlistItems = waitlistListJson.map((jsonItem) {
      return WaitlistItem(
        name: jsonItem['name'],
        courseCode: jsonItem['courseCode'],
        statusMessage: jsonItem['statusMessage'],
        status: _waitlistStatusFromString(jsonItem['status']),
      );
    }).toList();
  }

  WaitlistStatus _waitlistStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'in_queue':
        return WaitlistStatus.inQueue;
      case 'ready_for_pickup':
        return WaitlistStatus.readyForPickup;
      default:
        return WaitlistStatus.inQueue;
    }
  }

  /// When a user cancels a reservation on the waitlist.
  void cancelReservation(BuildContext context, WaitlistItem item) {
    print('Cancelling reservation for ${item.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelled reservation for ${item.name}.'), backgroundColor: Colors.red.shade700,),
    );
  }
}