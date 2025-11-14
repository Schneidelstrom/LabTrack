import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _upMailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _upMailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showInfoPopup(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.of(context, rootNavigator: true).canPop()) Navigator.of(context, rootNavigator: true).pop();
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12.0)),
            child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        );
      },
    );
  }

  Future<void> _login() async {
    if (_isLoading) return;
    setState(() {_isLoading = true;});
    final String email = _upMailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showInfoPopup('Email and password cannot be empty.');
      setState(() {_isLoading = false;});
      return;
    }

    if (!email.endsWith('@up.edu.ph')) {
      _showInfoPopup('Invalid Email: Must be a valid @up.edu.ph address.');
      setState(() {_isLoading = false;});
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) if (mounted) Navigator.pushReplacementNamed(context, '/main');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') _showInfoPopup('Invalid email or password. Please check your credentials.');
      else if (e.code == 'user-disabled') _showInfoPopup('This account has been disabled. Please contact support.');
      else if (e.code == 'invalid-email') _showInfoPopup('The email address is not valid.');
      else {
        print("Login Error: $e");
        _showInfoPopup('Login failed: ${e.message ?? 'An error occurred.'}');
      }
    } catch (e) {
      print("Login Error: $e");
      _showInfoPopup('An unexpected error occurred. Please try again.');
    }

    if (mounted) setState(() {_isLoading = false;});
  }

  Future<void> _resetPassword() async {
    if (_isLoading) return;
    final String email = _upMailController.text.trim();

    if (email.isEmpty) {
      _showInfoPopup('Please enter your email to reset password.');
      return;
    }

    if (!email.endsWith('@up.edu.ph')) {
      _showInfoPopup('Invalid Email: Must be a @up.edu.ph address.');
      return;
    }

    setState(() {_isLoading = true;});

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showInfoPopup('If an account exists for $email, a password reset email has been sent.');
    } on FirebaseAuthException catch (e) {
      print("Password Reset Error: $e");
      _showInfoPopup('Error: ${e.message ?? 'Could not send reset email.'}');
    } catch (e) {
      print("Password Reset Error: $e");
      _showInfoPopup('An unexpected error occurred.');
    }

    if (mounted) setState(() {_isLoading = false;});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('LabTrack', style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 50),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
                ),
                child: TextField(
                  controller: _upMailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'UP Mail',
                    hintText: 'e.g., your.name@up.edu.ph',
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: _isLoading ? Colors.grey.shade100 : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0)),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
                ),
                child: TextField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      onPressed: _isLoading ? null : () {setState(() {_isPasswordVisible = !_isPasswordVisible;});},
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey)
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: _isLoading ? Colors.grey.shade100 : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0)),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      disabledBackgroundColor: Colors.blue.shade900,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: _isLoading ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    ) : const Text('Login'),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: _isLoading ? Colors.grey : Colors.blue.shade900, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}