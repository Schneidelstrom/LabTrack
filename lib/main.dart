import 'package:flutter/material.dart';
import 'package:labtrack/login_page.dart';

void main(){
  runApp(const LogInPage());
}

class LogInPage extends StatelessWidget{
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabTrack',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}