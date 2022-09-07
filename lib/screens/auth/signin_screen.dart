import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workday/screens/auth/signin_screen.dart';
import 'package:workday/screens/auth/signup_screen.dart';

import '../../data/variable.dart';
import '../../main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:avatar_glow/avatar_glow.dart';

import '../Log.dart';
import '../administrator_screen.dart';
import '../employee_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreen createState() => _SignInScreen();
}

class _SignInScreen extends State<SignInScreen> {
  String _email = "", _password = "";

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        content: new Container(
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: const Color(0xFFFFFF),
        borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
      ),
      child: Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 18), child: Text("Загрузка...")),
        ],
      ),
    ));
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null)
      FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;

          if (data['status'] == 'waiter') {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => EmployeeScreen()));
          } else {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AdministratorScreen()));
          }
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xff292C31),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: _width / 10, right: _width / 10),
          height: _height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.only(top: 200)),
              Text(
                'Войти',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 50)),
              componentTextField(
                  Icons.email_outlined, 'Email...', false, true, 'email'),
              Padding(padding: EdgeInsets.only(top: 25)),
              componentTextField(
                  Icons.lock_outline, 'Password...', true, false, "password"),
              Padding(padding: EdgeInsets.only(top: 25)),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  Navigator.push(context, Scale_Transition(SignUpScreen()));
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text('Зарегистрировать аккаунт',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 17),
                      textAlign: TextAlign.right),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 30)),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  showAlertDialog(context);
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
            ],
          ),
        ),
      ),
    );
  }

  Widget componentTextField(IconData icon, String hintText, bool isPassword,
      bool isEmail, String changed) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xff212428),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        style: TextStyle(color: Colors.white.withOpacity(.7)),
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(.7),
          ),
          border: InputBorder.none,
          hintMaxLines: 1,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(.5),
          ),
        ),
        onChanged: (value) {
          setState(() {
            if (changed == 'email') {
              _email = value;
            }
            if (changed == 'password') {
              _password = value;
            }
          });
        },
      ),
    );
  }
}
