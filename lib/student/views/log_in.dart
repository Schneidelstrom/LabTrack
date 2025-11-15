import 'package:flutter/material.dart';
import 'package:labtrack/student/controllers/login.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
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

  void _handleLogin() {
    _controller.login(
      context: context,
      email: _upMailController.text,
      password: _passwordController.text,
      onLoadingChanged: (loading) {if (mounted) setState(() => _isLoading = loading);},
    );
  }

  void _handleResetPassword() {
    _controller.resetPassword(
      context: context,
      email: _upMailController.text,
      onLoadingChanged: (loading) {if (mounted) setState(() => _isLoading = loading);},
    );
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
              const Text(
                'LabTrack',
                style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 50),
              _buildTextField(
                controller: _upMailController,
                labelText: 'UP Mail',
                hintText: 'e.g., your.name@up.edu.ph',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  onPressed: _isLoading ? null : () { setState(() {_isPasswordVisible = !_isPasswordVisible;});},
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                    onPressed: _isLoading ? null : _handleResetPassword,
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

  Widget _buildTextField({required TextEditingController controller, required String labelText, required String hintText, required IconData prefixIcon, TextInputType? keyboardType, bool obscureText = false, Widget? suffixIcon,}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],),
      child: TextField(
        controller: controller,
        enabled: !_isLoading,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: Colors.grey),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          filled: true,
          fillColor: _isLoading ? Colors.grey.shade100 : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0)),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}