import 'package:firebase_auth/firebase_auth.dart';
import 'package:labtrack/student/services/database.dart';
import 'package:labtrack/student/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();

  Future<UserModel?> getCurrentUserDetails() async {
    final User? firebaseUser = _auth.currentUser;

    if (firebaseUser == null || firebaseUser.email == null) {
      return null;
    }

    try {
      final userModel = await _dbService.getUserByEmail(firebaseUser.email!);
      return userModel;
    } catch (e) {
      print("Error fetching user details from Firestore: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}