import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  staff,
}

class UserModel {
  final String upMail;
  final String firstName;
  final String? middleName;
  final String? lastName;
  final String studentId;
  final String degreeProgram;
  final int yearLevel;
  final String contactNumber;
  final UserRole role;

  const UserModel({
    required this.upMail,
    required this.firstName,
    this.middleName,
    this.lastName,
    required this.studentId,
    required this.degreeProgram,
    required this.yearLevel,
    required this.contactNumber,
    required this.role,
  });

  String get fullName {
    final parts = [firstName, middleName, lastName];
    return parts.where((p) => p != null && p.isNotEmpty).join(' ');
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      upMail: data['upmail'] ?? doc.id,
      firstName: data['fname'] ?? '',
      middleName: data['mname'],
      lastName: data['lname'],
      studentId: data['sid'] ?? '',
      degreeProgram: data['dprogram'] ?? '',
      yearLevel: data['ylevel'] ?? 0,
      contactNumber: data['cnumber'] ?? '',
      role: _roleFromString(data['role']),
    );
  }

  Map<String, dynamic> toJson() => {
    'upmail': upMail,
    'fname': firstName,
    'mname': middleName,
    'lname': lastName,
    'sid': studentId,
    'dprogram': degreeProgram,
    'ylevel': yearLevel,
    'cnumber': contactNumber,
    'role': role.name,
  };
}

UserRole _roleFromString(String? roleString) {
  switch (roleString?.toLowerCase()) {
    case 'student':
      return UserRole.student;
    case 'staff':
      return UserRole.staff;
    default:
      return UserRole.student;
  }
}