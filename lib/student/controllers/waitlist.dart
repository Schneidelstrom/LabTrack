import 'package:flutter/material.dart';
import 'package:labtrack/student/models/waitlist_item.dart';
/// Fetching user waitlisted items and handling actions for cancellation for the [WaitlistView]
class WaitlistController {
  List<WaitlistItem> _waitlistItems = [];
  List<WaitlistItem> get waitlistItems => _waitlistItems;

  /// Simulates fetching list of items the user is waitlisted for
  Future<void> loadWaitlistItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _waitlistItems = const [
      WaitlistItem(
        name: 'Digital Scale',
        courseCode: 'BIO-1',
        statusMessage: 'Position: #2',
        status: WaitlistStatus.inQueue,
      ),
      WaitlistItem(
        name: 'Graduated Cylinder',
        courseCode: 'ENVI-1',
        statusMessage: 'Ready for Pickup',
        status: WaitlistStatus.readyForPickup,
      ),
    ];
  }

  /// When a user cancels a reservation on the waitlist.
  void cancelReservation(BuildContext context, WaitlistItem item) {
    print('Cancelling reservation for ${item.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelled reservation for ${item.name}.'), backgroundColor: Colors.red.shade700,),
    );
  }
}