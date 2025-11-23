import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String courseCode;
  final String title;

  const Course({
    required this.courseCode,
    required this.title,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Course(
      courseCode: data['courseCode'] ?? '',
      title: data['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'courseCode': courseCode,
    'title': title,
  };
}