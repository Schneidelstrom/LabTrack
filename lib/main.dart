import 'package:flutter/material.dart';
import 'package:labtrack/log_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:labtrack/firebase_options.dart';
import 'package:labtrack/student/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LogInPage());
}

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabTrack',
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => StudentDashboard(),
      },
    );
  }
}
