import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:labtrack/firebase_options.dart';
import 'package:labtrack/staff/dashboard.dart';
import 'package:labtrack/student/main_screen.dart';
import 'package:labtrack/student/views/log_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabTrack',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/main': (context) => const MainScreen(),
        '/staff_dashboard': (context) => const StaffDashboard(),
      },
    );
  }
}