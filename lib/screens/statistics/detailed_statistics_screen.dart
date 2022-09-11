import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:workday/screens/statistics/fine_screen.dart';
import 'package:workday/screens/statistics/money_information_screen.dart';
import 'package:workday/screens/statistics/user_information_period_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../data/const.dart';
import '../../data/money_model.dart';
import '../../data/user_model.dart';
import '../administrator_screen.dart';
import '../extradition_screen.dart';
import 'information_users_screen.dart';

class DetailedStatics extends StatefulWidget {
  const DetailedStatics({Key? key}) : super(key: key);

  @override
  State<DetailedStatics> createState() => _DetailedStatics();
}

class _DetailedStatics extends State<DetailedStatics> {
  Widget _buildBottomSheetMoney(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MoneyInformationScreen(
                                post: 'barista',
                              )));
                },
                child: Text('Бармены'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MoneyInformationScreen(
                                post: 'maid',
                              )));
                },
                child: Text('Горнечные'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MoneyInformationScreen(
                                post: 'concierge',
                              )));
                },
                child: Text('Коньсьерж'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MoneyInformationScreen(
                                post: 'admin',
                              )));
                },
                child: Text('Администраторы'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MoneyInformationScreen(
                                post: 'chef-cook',
                              )));
                },
                child: Text('Шеф-Повор'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MoneyInformationScreen(
                                post: 'sous-chef',
                              )));
                },
                child: Text('Сy-Шеф'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MoneyInformationScreen(
                                post: 'confectioner',
                              )));
                },
                child: Text('Кондитер'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MoneyInformationScreen(
                                post: 'cook',
                              )));
                },
                child: Text('Повора'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetEmployee(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInformationPeriodScreen(
                                post: 'barista',
                              )));
                },
                child: Text('Бармены'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInformationPeriodScreen(
                                post: 'maid',
                              )));
                },
                child: Text('Горнечные'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInformationPeriodScreen(
                                post: 'concierge',
                              )));
                },
                child: Text('Коньсьерж'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInformationPeriodScreen(
                                post: 'admin',
                              )));
                },
                child: Text('Администраторы'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInformationPeriodScreen(
                                post: 'chef-cook',
                              )));
                },
                child: Text('Шеф-Повор'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInformationPeriodScreen(
                                post: 'sous-chef',
                              )));
                },
                child: Text('Сy-Шеф'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInformationPeriodScreen(
                                post: 'confectioner',
                              )));
                },
                child: Text('Кондитер'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInformationPeriodScreen(
                                post: 'cook',
                              )));
                },
                child: Text('Повора'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetFine(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FineScreens(
                                post: 'barista',
                              )));
                },
                child: Text('Бармены'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FineScreens(
                                post: 'maid',
                              )));
                },
                child: Text('Горнечные'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FineScreens(
                                post: 'concierge',
                              )));
                },
                child: Text('Коньсьерж'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FineScreens(
                                post: 'admin',
                              )));
                },
                child: Text('Администраторы'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FineScreens(
                                post: 'chef-cook',
                              )));
                },
                child: Text('Шеф-Повор'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FineScreens(
                                post: 'sous-chef',
                              )));
                },
                child: Text('Сy-Шеф'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FineScreens(
                                post: 'confectioner',
                              )));
                },
                child: Text('Кондитер'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FineScreens(
                                post: 'cook',
                              )));
                },
                child: Text('Повора'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color_main_black,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => AdministratorScreen(
                          value: 2,
                        )));
          });
        },
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MoneyInformationScreen()));
                            },
                            child: Text(
                              'Получить информацию о всех деньгах',
                              style: TextStyle(color: Colors.black),
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.only(),
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white),
                            onPressed: () {
                              showCupertinoModalBottomSheet(
                                topRadius: Radius.circular(30),
                                duration: Duration(milliseconds: 700),
                                backgroundColor: color_main_black,
                                context: context,
                                builder: (context) =>
                                    _buildBottomSheetMoney(context),
                              );
                            },
                            child: Text(
                                'Получить информацию о выдаче денег сотруднику',
                                style: TextStyle(color: Colors.black))),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 30),
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UserInformationPeriodScreen()));
                            },
                            child: Text(
                                'Получить информацию о всех сотрудниках',
                                style: TextStyle(color: Colors.black))),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white),
                            onPressed: () {
                              showCupertinoModalBottomSheet(
                                topRadius: Radius.circular(30),
                                duration: Duration(milliseconds: 700),
                                backgroundColor: color_main_black,
                                context: context,
                                builder: (context) =>
                                    _buildBottomSheetEmployee(context),
                              );
                            },
                            child: Text('Получить информацию о сотрудники',
                                style: TextStyle(color: Colors.black))),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 30),
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FineScreens()));
                            },
                            child: Text('Получить информацию о всех штрафах',
                                style: TextStyle(color: Colors.black))),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white),
                            onPressed: () {
                              showCupertinoModalBottomSheet(
                                topRadius: Radius.circular(30),
                                duration: Duration(milliseconds: 700),
                                backgroundColor: color_main_black,
                                context: context,
                                builder: (context) =>
                                    _buildBottomSheetFine(context),
                              );
                            },
                            child: Text(
                                'Получить информацию о штрафах сотрудника',
                                style: TextStyle(color: Colors.black))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
