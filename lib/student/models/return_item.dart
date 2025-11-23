import 'package:cloud_firestore/cloud_firestore.dart';

enum ReturnStatus {
  partial,
  complete,
}

class ReturnItem {
  final String returnId;
  final String courseCode;
  final String borrowDate;
  final String returnDate;
  final int quantity;
  final int returnedQuantity;
  final returnerUpMail;

  const ReturnItem({
    required this.returnId,
    required this.courseCode,
    required this.borrowDate,
    required this.returnDate,
    required this.quantity,
    required this.returnedQuantity,
    required this.returnerUpMail,
  });

  ReturnStatus get status {
    return returnedQuantity >= quantity ? ReturnStatus.complete : ReturnStatus.partial;
  }

  factory ReturnItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReturnItem(
      returnId: data['returnId'] ?? doc.id,
      courseCode: data['courseCode'] ?? '',
      borrowDate: data['borrowDate'] ?? '',
      returnDate: data['returnDate'] ?? '',
      quantity: data['quantity'] ?? 0,
      returnedQuantity: data['returnedQuantity'] ?? 0,
      returnerUpMail: data['returnerUpMail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'returnId': returnId,
    'courseCode': courseCode,
    'borrowDate': borrowDate,
    'returnDate': returnDate,
    'quantity': quantity,
    'returnedQuantity': returnedQuantity,
    'returnerUpMail': returnerUpMail,
  };
}