import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


typedef LoadingCallback = void Function(bool isLoading); // For updating loading state in view

/// User authentication with Firebase, input validation, and showing feedback to user for the [LoginView]
class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Shows dialog with message
  void _showInfoPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {

        Future.delayed(const Duration(seconds: 3), () { // Dismiss dialog after 3 seconds
          if (Navigator.of(dialogContext).canPop()) Navigator.of(dialogContext).pop();
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12.0)),
            child: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        );
      },
    );
  }

  /// Attempts to sign in user with provided credentials
  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
    required LoadingCallback onLoadingChanged,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _showInfoPopup(context, 'Email and password cannot be empty.');
      return;
    }
    if (!email.endsWith('@up.edu.ph')) {
      _showInfoPopup(
          context, 'Invalid Email: Must be a valid @up.edu.ph address.');
      return;
    }
    onLoadingChanged(true); // Signal view to show loading indicator

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password); // Use Firebase Auth to sign in
      if (context.mounted) Navigator.pushReplacementNamed(context, '/main');  // Go to main screen on success
    } on FirebaseAuthException catch (e) {
      // Handle authentication errors
      String message = 'An unknown error occurred.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') message = 'Invalid email or password. Please try again.';
      else if (e.code == 'user-disabled') message = 'This account has been disabled. Please contact support.';
      else if (e.code == 'invalid-email') message = 'The email address is not valid.';
      _showInfoPopup(context, message);
    } catch (e) {
      _showInfoPopup(context, 'An unexpected error occurred. Please try again.'); // Handle unexpected errors
    } finally { // Ensure loading indicator is hidden even if error occurs
      if (context.mounted) onLoadingChanged(false);
    }
  }

  /// Sends password reset email to provided email address
  Future<void> resetPassword({
    required BuildContext context,
    required String email,
    required LoadingCallback onLoadingChanged,
  }) async {
    if (email.isEmpty) {
      _showInfoPopup(context, 'Please enter your email to reset the password.');
      return;
    }
    if (!email.endsWith('@up.edu.ph')) {
      _showInfoPopup(context, 'Invalid Email: Must be a @up.edu.ph address.');
      return;
    }
    onLoadingChanged(true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showInfoPopup(context, 'If an account exists for $email, a password reset email has been sent.');
    } on FirebaseAuthException catch (e) {
      _showInfoPopup(context, 'Error: ${e.message ?? "Could not send reset email."}');
    } catch (e) {
      _showInfoPopup(context, 'An unexpected error occurred.');
    } finally {
      if (context.mounted) onLoadingChanged(false);
    }
  }
}