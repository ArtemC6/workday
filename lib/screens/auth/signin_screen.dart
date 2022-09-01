import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workday/screens/auth/signup_screen.dart';
import 'package:workday/screens/waiter_screen.dart';

import '../../main.dart';
import '../administrator_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";
  CollectionReference users = FirebaseFirestore.instance.collection('User');

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
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => WaiterScreen()));
          } else {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AdministratorScreen()));
          }
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Войти'),
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
                                builder: (context) => SignUpScreen()));
                          },
                          child: Text('зарегистрироваться'))),
                  Container(
                      padding: EdgeInsets.only(),
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {



                            if (formKey.currentState!.validate()) {
                              FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: _email, password: _password)
                                  .then((value) => {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen()))
                                      })
                                  .onError((error, stackTrace) => {});
                            }
                          },
                          child: Text('Войти'))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
