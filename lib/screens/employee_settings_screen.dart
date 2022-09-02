import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:workday/screens/auth/signin_screen.dart';
import 'package:intl/intl.dart';
import 'package:workday/screens/employee_screen.dart';

import '../data/user_model.dart';
import 'analytics_screen.dart';
import 'statistics/detailed_statistics_screen.dart';

class EmployeeSettingsScreen extends StatefulWidget {
  const EmployeeSettingsScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeSettingsScreen> createState() => _EmployeeSettingsScreen();
}

class _EmployeeSettingsScreen extends State<EmployeeSettingsScreen> {
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
          appBar: AppBar(
            title: Text('Настройки'),
          ),
          body: Form(
            key: formKey,
            child: Container(
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
                      controller: TextEditingController(text: _name),
                      decoration: InputDecoration(
                        hintText: 'Введите процент сотрудникам',
                      ),
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black,
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
                    color: Colors.white,
                    width: double.infinity,
                    child: ElevatedButton(
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
                      child: Text('Сохронить'),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => EmployeeScreen()));
                      },
                      child: Text('Вернуться'),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
