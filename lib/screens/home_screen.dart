import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workday/screens/administrator_screen.dart';
import 'package:workday/screens/employee_screen.dart';
import 'package:intl/intl.dart';

import '../data/const.dart';
import 'auth/signin_screen.dart';
import 'auth/signup_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> with TickerProviderStateMixin {
  bool isVisible = true;

  late AnimationController firstController,
      secondController,
      thirdController,
      fourthController,
      fifthController;

  late Animation<double> firstAnimation,
      secondAnimation,
      thirdAnimation,
      fourthAnimation,
      fifthAnimation;

  void sigNinFirebase() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          isVisible = false;
        });
        if (documentSnapshot['post'] == 'boss') {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdministratorScreen()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => EmployeeScreen()));
        }
      } else {
        Navigator.pushReplacement(context, Scale_Transition(SignInScreen()));
      }
    });

    if (isVisible) {
      Navigator.pushReplacement(context, Scale_Transition(SignInScreen()));
    }

    FirebaseFirestore.instance
        .collection('Work')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((document) async {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        final Timestamp timestampStart = data['startDate'] as Timestamp;
        final DateTime dateTimeStart = timestampStart.toDate();
        DateTime currentDate = DateTime.now();

        var timeStartNotHour = new DateTime(
            dateTimeStart.year, dateTimeStart.month, dateTimeStart.day);

        var timeCurrentNOtHour =
        new DateTime(currentDate.year, currentDate.month, currentDate.day);

        var timeCurrentHour = new DateTime(currentDate.year, currentDate.month,
            currentDate.day, currentDate.hour);

        var timeStart = new DateTime(dateTimeStart.year, dateTimeStart.month,
            dateTimeStart.day, dateTimeStart.hour);

        final dockUsers = await FirebaseFirestore.instance.collection('Work');

        DateTime dateOver_15 =
        DateTime.parse("${DateFormat('yyyy-MM-dd').format(timeStart)} 15");

        DateTime dateOver_23 =
        DateTime.parse("${DateFormat('yyyy-MM-dd').format(timeStart)} 23");

        if (data['endDate'] == '') {
          if (data['post'] != 'admin') {
            if (timeStart.hour >= 7 && timeStart.hour < 15) {
              if (timeCurrentNOtHour == timeStartNotHour) {
                // print('object');

                if (timeCurrentHour.hour >= dateOver_15.hour) {
                  final json = {
                    'endUri':
                    'https://media.baamboozle.com/uploads/images/59634/1591055175_32403',
                    'endDate': DateTime.parse(
                        "${DateFormat('yyyy-MM-dd').format(timeStart)} 15"),
                  };

                  dockUsers.doc(document.id).update(json);
                }
              } else {
                final json = {
                  'endUri':
                  'https://media.baamboozle.com/uploads/images/59634/1591055175_32403',
                  'endDate': DateTime.parse(
                      "${DateFormat('yyyy-MM-dd').format(timeStart)} 15"),
                };
                dockUsers.doc(document.id).update(json);
              }
            }
            if (timeStart.hour >= 15 && timeStart.hour <= 23) {
              if (timeCurrentNOtHour == timeStartNotHour) {
                if (timeCurrentHour.hour >= dateOver_23.hour) {
                  final json = {
                    'endUri':
                    'https://media.baamboozle.com/uploads/images/59634/1591055175_32403',
                    'endDate': DateTime.parse(
                        "${DateFormat('yyyy-MM-dd').format(timeStart)} 23"),
                  };
                  dockUsers.doc(document.id).update(json);
                }
              } else {
                final json = {
                  'endUri':
                  'https://media.baamboozle.com/uploads/images/59634/1591055175_32403',
                  'endDate': DateTime.parse(
                      "${DateFormat('yyyy-MM-dd').format(timeStart)} 23"),
                };
                dockUsers.doc(document.id).update(json);
              }
            }
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();

    firstController =
        AnimationController(vsync: this, duration: Duration(seconds: 6));
    firstAnimation = Tween<double>(begin: -pi, end: pi).animate(firstController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          firstController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          firstController.forward();
        }
      });

    secondController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    secondAnimation =
    Tween<double>(begin: -pi, end: pi).animate(secondController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          secondController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          secondController.forward();
        }
      });

    thirdController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    thirdAnimation = Tween<double>(begin: -pi, end: pi).animate(thirdController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          thirdController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          thirdController.forward();
        }
      });

    fourthController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    fourthAnimation =
    Tween<double>(begin: -pi, end: pi).animate(fourthController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          fourthController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          fourthController.forward();
        }
      });

    fifthController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    fifthAnimation = Tween<double>(begin: -pi, end: pi).animate(fifthController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          fifthController.repeat();
        } else if (status == AnimationStatus.dismissed) {
          fifthController.forward();
        }
      });

    firstController.forward();
    secondController.forward();
    thirdController.forward();
    fourthController.forward();
    fifthController.forward();

    sigNinFirebase();
  }

  @override
  void dispose() {
    firstController.dispose();
    secondController.dispose();
    thirdController.dispose();
    fourthController.dispose();
    fifthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_main_black,
      body: Center(
        child: Container(
          height: 100,
          width: 100,
          child: CustomPaint(
            painter: MyPainter(
              firstAnimation.value,
              secondAnimation.value,
              thirdAnimation.value,
              fourthAnimation.value,
              fifthAnimation.value,
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final double firstAngle;
  final double secondAngle;
  final double thirdAngle;
  final double fourthAngle;
  final double fifthAngle;

  MyPainter(this.firstAngle,
      this.secondAngle,
      this.thirdAngle,
      this.fourthAngle,
      this.fifthAngle,);

  @override
  void paint(Canvas canvas, Size size) {
    Paint myArc = Paint()
      ..color = Color(0xff00A2FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTRB(
        0,
        0,
        size.width,
        size.height,
      ),
      firstAngle,
      2,
      false,
      myArc,
    );
    canvas.drawArc(
      Rect.fromLTRB(
        size.width * .1,
        size.height * .1,
        size.width * .9,
        size.height * .9,
      ),
      secondAngle,
      2,
      false,
      myArc,
    );
    canvas.drawArc(
      Rect.fromLTRB(
        size.width * .2,
        size.height * .2,
        size.width * .8,
        size.height * .8,
      ),
      thirdAngle,
      2,
      false,
      myArc,
    );
    canvas.drawArc(
      Rect.fromLTRB(
        size.width * .3,
        size.height * .3,
        size.width * .7,
        size.height * .7,
      ),
      fourthAngle,
      2,
      false,
      myArc,
    );
    canvas.drawArc(
      Rect.fromLTRB(
        size.width * .4,
        size.height * .4,
        size.width * .6,
        size.height * .6,
      ),
      fifthAngle,
      2,
      false,
      myArc,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
