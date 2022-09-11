import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workday/screens/auth/signin_screen.dart';

import '../../data/const.dart';
import '../../data/variable.dart';
import '../../main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:avatar_glow/avatar_glow.dart';

import '../home_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreen createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  String _email = "", _password = "", _name = "";
  bool _isHidden = true, isVisibleSizedBox = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xff292C31),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: _width / 10, right: _width / 10, top: _height / 20),
          height: _height,
          child: Column(
            children: [
              Expanded(child: SizedBox()),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(),
                    Text(
                      'Зарегистироваться',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(),
                    componentTextField(Icons.account_circle_outlined, 'Name...',
                        false, false, "name"),
                    componentTextField(
                        Icons.email_outlined, 'Email...', false, true, 'email'),
                    componentTextField(Icons.lock_outline, 'Password...', true,
                        false, "password"),
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                            context, Scale_Transition(SignInScreen()));
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text('Войти в аккаунт',
                            style: TextStyle(
                                color: Colors.blueAccent, fontSize: 17),
                            textAlign: TextAlign.right),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  showAlertDialogMy(context);

                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _email, password: _password)
                      .then((value) async {
                    final docUser = await FirebaseFirestore.instance
                        .collection('User')
                        .doc(FirebaseAuth.instance.currentUser!.uid);

                    final json = {
                      'uid': FirebaseAuth.instance.currentUser!.uid,
                      'name': _name,
                      'email': _email,
                      'status': 'waiter',
                      'post': '',
                    };

                    docUser.set(json);

                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  }).onError((error, stackTrace) {
                    Navigator.pop(context);
                  });
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
                Padding(padding: EdgeInsets.only(bottom: 150)),
            ],
          ),
        ),
      ),
    );
  }

  Widget componentTextField(IconData icon, String hintText, bool isPassword,
      bool isEmail, String changed) {
    if (isPassword) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color_main_black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          onTap: () {
            setState(() {
              isVisibleSizedBox = true;
            });
          },
          style: TextStyle(color: Colors.white.withOpacity(.7)),
          obscureText: _isHidden,
          keyboardType:
              isEmail ? TextInputType.emailAddress : TextInputType.text,
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
              if (changed == 'name') {
                _name = value;
              }
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
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color_main_black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        onTap: () {
          setState(() {
            isVisibleSizedBox = true;
          });
        },
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
            if (changed == 'name') {
              _name = value;
            }
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
