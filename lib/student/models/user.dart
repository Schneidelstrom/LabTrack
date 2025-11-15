import 'package:flutter/foundation.dart';

/// An enum to define user roles for better type safety than using strings.
enum UserRole {
  student,
  staff
}

/// Represents a user in the system with detailed profile information.
/// This model replaces the simpler GroupMember model.
@immutable
class UserModel {
  final String upMail;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String studentId;
  final String degreeProgram;
  final int yearLevel;
  final String contactNumber;
  final UserRole role;
  const UserModel({
    required this.upMail,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.studentId,
    required this.degreeProgram,
    required this.yearLevel,
    required this.contactNumber,
    required this.role,
  });
  /// A convenience getter to display the user's full name.
  String get fullName => '$firstName ${middleName ?? ''} $lastName'.replaceAll(' ', ' ');
  /// Factory constructor to create a UserModel instance from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      upMail: json['upmail'],
      firstName: json['fname'],
      middleName: json['mname'],
      lastName: json['lname'],
      studentId: json['sid'],
      degreeProgram: json['dprogram'],
      yearLevel: json['ylevel'],
      contactNumber: json['cnumber'],
      role: _roleFromString(json['role']),
    );
  }
}

UserRole _roleFromString(String? roleString) {
  switch (roleString?.toLowerCase()) {
    case 'student':
      return UserRole.student;
    case 'faculty':
      return UserRole.staff;
    default:
      return UserRole.student;
  }
}