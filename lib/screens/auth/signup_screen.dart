import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workday/screens/auth/signin_screen.dart';
import '../../data/const.dart';
import '../home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreen createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  String _token = '';
  bool _isHidden = true, isVisibleSizedBox = false;
  String postUser = '', postUserName = '';

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        _token = token!;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    setState(() {
      if (postUser != null) {
        postUserName = getName(postUser);
      }
    });

    showAlertDialogSettingUser(BuildContext context) {
      setState(() {
        AlertDialog alert = AlertDialog(
          backgroundColor: color_main_black,
          content: ExpansionTile(
            maintainState: true,
            onExpansionChanged: (value) {},
            title: Text(
              'Должности',
              style: TextStyle(color: Colors.white),
            ),
            collapsedIconColor: Colors.white,
            children: [
              Container(
                  padding: EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width / 2.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        postUser = 'admin';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Администартор'),
                  )),
              Container(
                  padding: EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width / 2.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        postUser = 'barista';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Бариста'),
                  )),
              Container(
                  padding: EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width / 2.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        postUser = 'maid';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Горничная'),
                  )),
              Container(
                  padding: EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width / 2.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        postUser = 'concierge';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Коньсьерж'),
                  )),
              Container(
                  padding: EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width / 2.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        postUser = 'chef-cook';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Шеф-Повор'),
                  )),
              Container(
                  padding: EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width / 2.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        postUser = 'sous-chef';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Су-Шеф'),
                  )),
              Container(
                  padding: EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width / 2.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        postUser = 'confectioner';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Кондитер'),
                  )),
              Container(
                  padding: EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width / 2.0,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        postUser = 'cook';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('Повор'),
                  )),
              Container(
                  padding: EdgeInsets.all(4),
                  width: MediaQuery.of(context).size.width / 2.0,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      setState(() {
                        postUser = 'workers-cook';
                      });
                    },
                    child: Text('Кух-Работник'),
                  )),
            ],
          ),
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      });
    }

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
                          letterSpacing: 1),
                    ),
                    SizedBox(),
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color_main_black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: _nameController,
                        onTap: () {
                          setState(() {
                            isVisibleSizedBox = true;
                          });
                        },
                        style: TextStyle(color: Colors.white.withOpacity(.7)),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.account_circle_sharp,
                            color: Colors.white.withOpacity(.7),
                          ),
                          border: InputBorder.none,
                          hintMaxLines: 1,
                          hintText: 'Name...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(.5),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color_main_black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: _emailController,
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
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color_main_black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        onSubmitted: (value) {
                          if (postUser != '') {
                            setState(() {
                              isVisibleSizedBox = false;
                              showAlertDialogMy(context);
                              FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: _emailController.text, password: _passwordController.text)
                                  .then((value) async {
                                final docUser = await FirebaseFirestore.instance
                                    .collection('User')
                                    .doc(
                                        FirebaseAuth.instance.currentUser?.uid);

                                final json = {
                                  'uid': FirebaseAuth.instance.currentUser?.uid,
                                  'name': _nameController.text,
                                  'email': _emailController.text,
                                  'password': _passwordController.text,
                                  'post': postUser,
                                  'token': _token,
                                };

                                docUser.set(json);

                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()));
                              }).onError((error, stackTrace) {
                                Navigator.pop(context);
                              });
                            });
                          }
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
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          child: AnimatedTextKit(
                            displayFullTextOnTap: true,
                            isRepeatingAnimation: true,
                            repeatForever: true,
                            stopPauseOnTap: true,
                            animatedTexts: [
                              ColorizeAnimatedText(
                                postUserName == ''
                                    ? 'Указать должность'
                                    : postUserName,
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
                              showAlertDialogSettingUser(context);
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
                                'Войти в аккаунт',
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
                              Navigator.push(
                                  context, Scale_Transition(SignInScreen()));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  if (postUser != '') {
                    showAlertDialogMy(context);
                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: _emailController.text, password: _passwordController.text)
                        .then((value) async {
                      final docUser = await FirebaseFirestore.instance
                          .collection('User')
                          .doc(FirebaseAuth.instance.currentUser?.uid);

                      final json = {
                        'uid': FirebaseAuth.instance.currentUser?.uid,
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'password': _passwordController.text,
                        'post': postUser,
                        'token': _token,
                      };

                      docUser.set(json);

                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => HomeScreen()));
                    }).onError((error, stackTrace) {
                      Navigator.pop(context);
                    });
                  }
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
}
