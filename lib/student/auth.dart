import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:labtrack/student/models/user.dart';

/// Service to handle authentication and user data retrieval
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retrieves the currently logged-in Firebase user and finds their detailed profile from the database
  Future<UserModel?> getCurrentUserDetails() async {
    final User? firebaseUser = _auth.currentUser;

    if (firebaseUser == null || firebaseUser.email == null) return null;

    final String jsonString = await rootBundle.loadString('lib/database/users.json');
    final Map<String, dynamic> decodedJson = json.decode(jsonString);
    final List<dynamic> userListJson = decodedJson['users'];
    final userJson = userListJson.firstWhere((user) => user['upmail'] == firebaseUser.email, orElse: () => null,);

    if (userJson != null) return UserModel.fromJson(userJson);

    return null;
  }
}