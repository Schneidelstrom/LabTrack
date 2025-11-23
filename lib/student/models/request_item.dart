import 'package:cloud_firestore/cloud_firestore.dart';

class RequestItem {
  final String requestId;
  final String courseCode;
  final int itemCount;
  final String requestDate;
  final String requesterUpMail;

  const RequestItem({
    required this.requestId,
    required this.courseCode,
    required this.itemCount,
    required this.requestDate,
    required this.requesterUpMail,
  });

  factory RequestItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RequestItem(
      requestId: data['requestId'] ?? doc.id,
      courseCode: data['courseCode'] ?? '',
      itemCount: data['itemCount'] ?? 0,
      requestDate: data['requestDate'] ?? '',
      requesterUpMail: data['requesterUpMail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'courseCode': courseCode,
    'itemCount': itemCount,
    'requestDate': requestDate,
    'requesterUpMail': requesterUpMail,
  };
}