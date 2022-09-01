import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workday/screens/administrator_screen.dart';
import 'package:workday/screens/analytics_screen.dart';
import 'package:workday/screens/statistics/detailed_statistics_screen.dart';
import 'package:workday/screens/auth/signin_screen.dart';
import 'package:workday/screens/auth/signup_screen.dart';
import 'package:workday/screens/waiter_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/administrator': (context) => const AdministratorScreen(),
        '/analytic': (context) => const AnalyticScreen(),
        '/detailed': (context) => const DetailedStatics(),
        '/signIn': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/waiter': (context) => const WaiterScreen(),
      },
      // home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isVisible = true;

  void sigNinFirebase() async {
    await FirebaseFirestore.instance
        .collection('User')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((document) {
        setState(() {
          isVisible = false;
        });

        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        if (data['uid'] == FirebaseAuth.instance.currentUser?.uid) {
          if (data['status'] == 'waiter') {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => WaiterScreen()));
          } else {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AdministratorScreen()));
          }
        } else {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => SignInScreen()));
        }
      });
    });

    if (isVisible) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => SignInScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    sigNinFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
    );
  }
}
