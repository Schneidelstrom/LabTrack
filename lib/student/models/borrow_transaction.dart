import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labtrack/student/models/cart_item.dart';

/// Handle serialization and deserialization of transaction data, including nested lists of borrowed items
class BorrowTransaction {
  final String borrowId;
  final String courseCode;
  final String courseName;
  final String borrowerUpMail;
  final String dateBorrowed;
  final String deadlineDate;
  final List<String> groupMembers;    // List of all UP Mails involved
  final List<CartItem> borrowedItems; // List of added to cart items

  const BorrowTransaction({
    required this.borrowId,
    required this.courseCode,
    required this.courseName,
    required this.borrowerUpMail,
    required this.dateBorrowed,
    required this.deadlineDate,
    required this.groupMembers,
    required this.borrowedItems,
  });

  /// Handles firebase data parsing to prevent runtime null errors
  factory BorrowTransaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>; //  Cast the document data to a Map for type safety
    var borrowedItemsList = (data['borrowedItems'] as List<dynamic>?)?.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList() ?? []; // Safely parse the list of borrowed items where if list is null, default to empty

    return BorrowTransaction(
      borrowId: data['borrowId'] ?? doc.id,
      courseCode: data['courseCode'] ?? '',
      courseName: data['courseName'] ?? '',
      borrowerUpMail: data['borrowerUpMail'] ?? '',
      dateBorrowed: data['dateBorrowed'] ?? '',
      deadlineDate: data['deadlineDate'] ?? '',
      groupMembers: List<String>.from(data['groupMembers'] ?? []),
      borrowedItems: borrowedItemsList,
    );
  }

  /// Converts instance into a Map suitable for writing to Firestore
  Map<String, dynamic> toJson() => {
    'borrowId': borrowId,
    'courseCode': courseCode,
    'courseName': courseName,
    'borrowerName': borrowerUpMail,
    'dateBorrowed': dateBorrowed,
    'deadlineDate': deadlineDate,
    'groupMembers': groupMembers,
    'borrowedItems': borrowedItems.map((item) => item.toJson()).toList() // Convert CartItem objects list back into a list of maps
  };
}