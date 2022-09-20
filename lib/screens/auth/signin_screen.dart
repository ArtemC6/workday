import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workday/screens/auth/signup_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../data/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../administrator_screen.dart';
import '../employee_screen.dart';
import '../home_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreen createState() => _SignInScreen();
}

class _SignInScreen extends State<SignInScreen> {
  String _email = "", _password = "";
  bool _isHidden = true, isVisibleSizedBox = false;

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;

          if (data['post'] == 'boss') {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AdministratorScreen()));
          } else {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => EmployeeScreen()));
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).requestFocus(new FocusNode());

        setState(() {
          isVisibleSizedBox = false;
        });

        return await false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xff292C31),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                left: _width / 10, right: _width / 10, top: _height / 8),
            height: _height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Войти',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                      letterSpacing: 1),
                ),
                Container(
                  margin: EdgeInsets.only(top: 40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color_main_black,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    onSubmitted: (value) {
                      setState(() {
                        isVisibleSizedBox = false;

                        showAlertDialogMy(context);
                        FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: _email, password: _password)
                            .then((value) => {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()))
                                })
                            .catchError((e) => Navigator.pop(context));
                      });
                    },
                    onTap: () {
                      setState(() {
                        isVisibleSizedBox = true;
                      });
                    },
                    style: TextStyle(color: Colors.white.withOpacity(.7)),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.white.withOpacity(.7),
                      ),
                      border: InputBorder.none,
                      hintMaxLines: 1,
                      hintText: 'Email...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(.5),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color_main_black,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    onSubmitted: (value) {
                      setState(() {
                        isVisibleSizedBox = false;

                        showAlertDialogMy(context);
                        FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: _email, password: _password)
                            .then((value) => {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()))
                                })
                            .catchError((e) => Navigator.pop(context));
                      });
                    },
                    onTap: () {
                      setState(() {
                        isVisibleSizedBox = true;
                      });
                    },
                    style: TextStyle(color: Colors.white.withOpacity(.7)),
                    obscureText: _isHidden,
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isHidden = !_isHidden;
                          });
                        },
                        child: _isHidden
                            ? Icon(
                                Icons.remove_red_eye_sharp,
                                color: Colors.white24,
                              )
                            : Icon(
                                Icons.remove_red_eye,
                                color: Colors.blueAccent,
                              ),
                      ),
                      prefixIcon: Icon(
                        Icons.lock_open_outlined,
                        color: Colors.white.withOpacity(.7),
                      ),
                      border: InputBorder.none,
                      hintMaxLines: 1,
                      hintText: 'Password...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(.5),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: AnimatedTextKit(
                    displayFullTextOnTap: true,
                    isRepeatingAnimation: true,
                    repeatForever: true,
                    stopPauseOnTap: true,
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Зарегистрировать аккаунт',
                        textStyle: TextStyle(fontSize: 17),
                        colors: [
                          Colors.blueAccent,
                          Colors.purple,
                          Colors.pink,
                          Colors.indigo,
                          Colors.redAccent,
                          Colors.deepPurpleAccent,
                          Colors.purpleAccent,
                          Colors.deepPurpleAccent,
                          Colors.blueAccent
                        ],
                      ),
                    ],
                    onTap: () {
                      Navigator.push(context, Scale_Transition(SignUpScreen()));
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 30)),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    showAlertDialogMy(context);
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _email, password: _password)
                        .then((value) => {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()))
                            })
                        .catchError((e) => Navigator.pop(context));
                  },
                  child: AvatarGlow(
                    glowColor: Colors.blueAccent,
                    endRadius: 120,
                    duration: Duration(milliseconds: 3000),
                    repeat: true,
                    showTwoGlows: true,
                    curve: Curves.easeOutQuad,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99)),
                      child: Icon(
                        Icons.navigate_next_rounded,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                if (isVisibleSizedBox)
                  SizedBox(
                    height: 170,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
