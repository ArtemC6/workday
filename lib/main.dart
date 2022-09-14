import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workday/screens/Log.dart';
import 'package:workday/screens/home_screen.dart';
import 'package:workday/screens/administrator_screen.dart';
import 'package:workday/screens/analytics_today_screen.dart';
import 'package:workday/screens/statistics/global_statistics_screen.dart';
import 'package:workday/screens/auth/signin_screen.dart';
import 'package:workday/screens/auth/signup_screen.dart';
import 'package:workday/screens/employee_screen.dart';
import 'package:intl/intl.dart';
import 'data/fine_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseFirestore.instance.clearPersistence();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/administrator': (context) => AdministratorScreen(),
        '/analytic': (context) => const AnalyticScreen(),
        '/detailed': (context) => const GlobalStatics(),
        '/signIn': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/waiter': (context) => EmployeeScreen(),
      }, /* home: const HomeScreen(),*/
    );
  }
}
