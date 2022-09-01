import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:workday/screens/auth/signin_screen.dart';

import '../../main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";
  String _name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Зарегистрироваться'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.only(left: 30, right: 30, top: 200),
          alignment: Alignment.center,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Введите email',
                    ),
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пустое поле';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Введите name',
                    ),
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пустое поле';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _name = value;
                      });
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Введите password',
                    ),
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пустое поле';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                  ),
                ),
                Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(),
                    width: double.infinity,
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SignInScreen()));
                        },
                        child: Text('Войти'))),
                Container(
                    padding: EdgeInsets.only(),
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {

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
                              };

                              docUser.set(json);

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                            }).onError((error, stackTrace) {
                              print("${error}");
                            });
                          }
                        },
                        child: Text('Зарегистрироваться'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
