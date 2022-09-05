import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workday/screens/administrator_screen.dart';
import 'package:workday/screens/analytics_screen.dart';
import 'package:workday/screens/statistics/detailed_statistics_screen.dart';
import 'package:workday/screens/auth/signin_screen.dart';
import 'package:workday/screens/auth/signup_screen.dart';
import 'package:workday/screens/employee_screen.dart';
import 'package:intl/intl.dart';
import 'data/fine_model.dart';

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
        '/waiter': (context) => const EmployeeScreen(),
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
  List<FineModel> listFine = [], listFineFull = [];
  bool isPosition = true,
      isPositionVisible = false,
      isEmpty = false,
      isVisible = true;

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
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => EmployeeScreen()));
          } else {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AdministratorScreen()));
          }
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SignInScreen()));
        }
      });
    });

    if (isVisible) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SignInScreen()));
    }

    FirebaseFirestore.instance
        .collection('Work')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((document) async {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        final Timestamp timestampStart = data['startDate'] as Timestamp;
        final DateTime dateTimeStart = timestampStart.toDate();

        var timeStart = new DateTime(dateTimeStart.year, dateTimeStart.month,
            dateTimeStart.day, dateTimeStart.hour);

        DateTime dateOver =
            DateTime.parse("${DateFormat('yyyy-MM-dd').format(timeStart)} 23");

        var timeOver = new DateTime(
            dateOver.year, dateOver.month, dateOver.day, dateOver.hour);

        if (data['endDate'] == '') {
          if (timeOver.hour > timeStart.hour) {
            final dockUsers =
                await FirebaseFirestore.instance.collection('Work');

            final json = {
              'endUri':
                  'https://img2.freepng.ru/20180421/qgq/kisspng-computer-icons-emoticon'
                      '-smiley-sadness-clip-art-pain-5adbd26692d7b0.2429607315243556866015.jpg',
              'endDate': DateTime.parse(
                  "${DateFormat('yyyy-MM-dd').format(timeStart)} 23"),
            };
            dockUsers.doc(document.id).update(json);
          }
        }
      });
    });
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
