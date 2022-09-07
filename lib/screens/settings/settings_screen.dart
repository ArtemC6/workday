import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workday/screens/employee_screen.dart';

import '../auth/signin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  final formKey = GlobalKey<FormState>();
  String _name = '';

  void readFirebase() {
    FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          _name = documentSnapshot['name'];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    readFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await false;
      },
      child: Scaffold(
          body: Form(
        key: formKey,
        child: Container(
          color: Colors.blueAccent,
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                child: TextFormField(
                  cursorColor: Colors.white,
                  controller: TextEditingController(text: _name),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusColor: Colors.white,
                    iconColor: Colors.white,
                    hintText: 'Введите имя',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Постое поле';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() async {
                      if (value.length >= 3) {
                        _name = value;
                      }
                    });
                  },
                ),
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final dockUsers =
                          await FirebaseFirestore.instance.collection('User');

                      final json = {
                        'name': _name,
                      };
                      dockUsers
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update(json);
                    }
                  },
                  child: Text(
                    'Сохронить',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(),
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => SignInScreen()));
                  },
                  child: Text(
                    'Выйти с аккаунта',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
