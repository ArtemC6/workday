import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workday/screens/employee_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../data/const.dart';
import '../administrator_screen.dart';
import '../auth/signin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  final formKey = GlobalKey<FormState>();
  String _name = '', _post = '', _postMain = '';
  bool isVisible = false;

  void readFirebase() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          _name = documentSnapshot['name'];
          _postMain = documentSnapshot['post'];

          if (documentSnapshot['post'] == 'barista') {
            _post = 'Бириста';
          } else if (documentSnapshot['post'] == 'admin') {
            _post = 'Администратор';
          } else if (documentSnapshot['post'] == 'boss') {
            _post = 'Руководитель';
          } else if (documentSnapshot['post'] == 'cook') {
            _post = 'Повор';
          } else if (documentSnapshot['post'] == 'trainee') {
            _post = 'Стажёр';
          } else if (documentSnapshot['post'] == 'maid') {
            _post = 'Горничная';
          } else if (documentSnapshot['post'] == 'confectioner') {
            _post = 'Кондитер';
          } else if (documentSnapshot['post'] == 'chef-cook') {
            _post = 'Шеф-Повор';
          } else if (documentSnapshot['post'] == 'sous-chef') {
            _post = 'Су-Шеф';
          } else if (documentSnapshot['post'] == '???') {
            _post = '???';
          } else {
            _post = 'Произошла ошибка';
          }
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        isVisible = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    readFirebase();
  }

  @override
  Widget build(BuildContext context) {
    List<_SalesData> dataUser = [
      _SalesData('Jan', 35),
      _SalesData('Feb', 28),
      _SalesData('Mar', 34),
      _SalesData('Apr', 32),
      _SalesData('May', 40)
    ];

    return WillPopScope(
      onWillPop: () async {
        return await false;
      },
      child: Scaffold(
          backgroundColor: color_main_black,
          resizeToAvoidBottomInset: true,
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => AdministratorScreen(
                              value: 3,
                            )));
              });
            },
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: color_main_black,
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_post}',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_postMain == 'boss')
                        if (isVisible)
                          Container(
                            height: MediaQuery.of(context).size.height / 2,
                            child: SfCircularChart(
                              legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom),
                              series: <PieSeries>[
                                PieSeries<_SalesData, String>(
                                    dataSource: dataUser,
                                    xValueMapper: (_SalesData sales, _) =>
                                        sales.name,
                                    yValueMapper: (_SalesData sales, _) =>
                                        sales.time,
                                    dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                        // labelPosition: LabelP,
                                        labelIntersectAction:
                                            LabelIntersectAction.none)),
                              ],
                            ),
                          ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(top: 30, bottom: 20),
                        child: TextFormField(
                          controller: TextEditingController(text: _name),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(
                                  color: Colors.blueAccent, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14)),
                              borderSide: BorderSide(
                                  color: Colors.blueAccent, width: 2.0),
                            ),
                            hintMaxLines: 1,
                            hintText: 'Имя',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(.5),
                            ),
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

                                if (formKey.currentState!.validate()) {
                                  final dockUsers = await FirebaseFirestore
                                      .instance
                                      .collection('User');

                                  final json = {
                                    'name': _name,
                                  };
                                  dockUsers
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update(json);
                                }
                              }
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white),
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
              ),
            ),
          )),
    );
  }
}

class _SalesData {
  final String name;
  final double time;

  _SalesData(this.name, this.time);
}
