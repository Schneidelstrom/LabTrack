import 'package:cloud_firestore/cloud_firestore.dart';

enum WaitlistStatus {
  inQueue,
  readyForPickup,
}

class WaitlistItem {
  final String waitlistId;
  final String name;
  final String courseCode;
  final String statusMessage;
  final WaitlistStatus status;
  final String waitlistedUpMail;


  const WaitlistItem({
    required this.waitlistId,
    required this.name,
    required this.courseCode,
    required this.statusMessage,
    required this.status,
    required this.waitlistedUpMail,
  });

  factory WaitlistItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    WaitlistStatus _statusFromString(String? statusStr) {
      if (statusStr == 'ready_for_pickup') return WaitlistStatus.readyForPickup;
      return WaitlistStatus.inQueue;
    }

    return WaitlistItem(
      waitlistId: data['waitlistId'] ?? doc.id,
      name: data['name'] ?? '',
      courseCode: data['courseCode'] ?? '',
      statusMessage: data['statusMessage'] ?? '',
      status: _statusFromString(data['status']),
      waitlistedUpMail: data['waitlistedUpMail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'waitlistId': waitlistId,
    'name': name,
    'courseCode': courseCode,
    'statusMessage': statusMessage,
    'status': status.name == 'readyForPickup' ? 'ready_for_pickup' : 'in_queue',
    'waitlistedUpMail': waitlistedUpMail,
  };
}