import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:workday/screens/auth/signin_screen.dart';
import 'package:intl/intl.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:workday/screens/settings/settings_screen.dart';

import '../data/user_model.dart';
import 'analytics_screen.dart';
import 'statistics/detailed_statistics_screen.dart';

class AdministratorScreen extends StatefulWidget {
  const AdministratorScreen({Key? key}) : super(key: key);

  @override
  State<AdministratorScreen> createState() => _AdministratorScreenState();
}

class _AdministratorScreenState extends State<AdministratorScreen> {
  List<UserModel> listUser = [], listUserWork = [];
  final formKey = GlobalKey<FormState>();
  double number = 0;
  int _page = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  int getUserWorkTime(Timestamp startDate, Timestamp endDate) {
    final DateTime dateTimeStart = startDate.toDate();
    final DateTime dateTimeEnd = endDate.toDate();
    return dateTimeEnd.difference(dateTimeStart).inMinutes;
  }

  String getData(Timestamp startDate) {
    final DateTime dateTimeStart = startDate.toDate();
    String formattedDate = DateFormat('kk:mm').format(dateTimeStart);
    return formattedDate;
  }

  void readFirebase() {
    FirebaseFirestore.instance
        .collection('Work')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((document) async {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        final Timestamp timestampStart = data['startDate'] as Timestamp;
        final DateTime dateTimeStart = timestampStart.toDate();

        var timeStart = new DateTime(
          dateTimeStart.year,
          dateTimeStart.month,
          dateTimeStart.day,
        );

        DateTime currentDate = DateTime.now();
        var currentTime = new DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );

        if (timeStart == currentTime) {
          if (data['endDate'] == '') {
            setState(() {
              var isExist = listUserWork.indexWhere(
                  (element) => element.id_user == (data['id_user']));

              if (isExist < 0) {
                listUserWork.add(UserModel(
                    name: data["name"],
                    email: data["email"],
                    status: data["status"],
                    startUri: data["startUri"],
                    endUri: '',
                    startDate: data["startDate"],
                    endDate: Timestamp.now(),
                    id_user: data["id_user"],
                    id_post: data["id_post"],
                    money: 0.0,
                    workTime:
                        getUserWorkTime(data["startDate"], Timestamp.now())));
              } else {
                listUserWork[isExist].workTime +=
                    getUserWorkTime(Timestamp.now(), Timestamp.now());
              }
            });
          }
        }

        if (timeStart == currentTime) {
          if (data['endDate'] != '') {
            setState(() {
              var isExist = listUser.indexWhere(
                  (element) => element.id_user == (data['id_user']));

              if (isExist < 0) {
                listUser.add(UserModel(
                    name: data["name"],
                    email: data["email"],
                    status: data["status"],
                    startUri: data["startUri"],
                    endUri: data["endUri"],
                    startDate: data["startDate"],
                    endDate: data["endDate"],
                    id_user: data["id_user"],
                    id_post: data["id_post"],
                    money: 0.0,
                    workTime:
                        getUserWorkTime(data["startDate"], data["endDate"])));
              } else {
                listUser[isExist].workTime += getUserWorkTime(
                    listUser[isExist].startDate, listUser[isExist].endDate);
              }
            });
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    readFirebase();
  }

  List<Widget> _getTitleWidgetWorkedUsers() {
    return [
      Container(
        child: Text('Сегодня работали ${listUser.length.toString()}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        width: 200,
        height: 56,
        padding: EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
      ),
    ];
  }

  List<Widget> _getTitleWidgetWork() {
    return [
      Container(
        child: Text('Сейчас работают ${listUserWork.length.toString()}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        width: 200,
        height: 56,
        padding: EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
      ),
    ];
  }

  Widget _generateFirstColumnRowWorkedUsers(BuildContext context, int index) {
    return Container(
      child: Text(
          "${listUser[index].name} закончил(ла) ${getData(listUser[index].endDate)}",
          style: TextStyle(fontSize: 17)),
      width: 100,
      height: 52,
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateFirstColumnRowWork(BuildContext context, int index) {
    return Container(
      child: Text(
          "${listUserWork[index].name} начал(ла) ${getData(listUserWork[index].startDate)}",
          style: TextStyle(color: Colors.green, fontSize: 17)),
      width: 100,
      height: 52,
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[],
    );
  }

  void _settingWindow() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Настройки'),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: formKey,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                    child: TextFormField(
                      controller:
                          TextEditingController(text: number.toString()),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            final text = newValue.text;
                            if (text.isNotEmpty) double.parse(text);
                            return newValue;
                          } catch (e) {}
                          return oldValue;
                        }),
                      ],
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
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
                          if (value.length >= 1) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('key_price', value);
                          }
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Сохнонить')),
                ),
              ],
            ),
          ),
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    Widget administratorMain() {
      return SmartRefresher(
        onRefresh: () async {
          setState(() {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => AdministratorScreen()));
          });
        },
        controller: _refreshController,
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          // padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 2,
                child: HorizontalDataTable(
                  leftHandSideColumnWidth: MediaQuery.of(context).size.width,
                  rightHandSideColumnWidth: 600,
                  isFixedHeader: true,
                  headerWidgets: _getTitleWidgetWorkedUsers(),
                  leftSideItemBuilder: _generateFirstColumnRowWorkedUsers,
                  rightSideItemBuilder: _generateRightHandSideColumnRow,
                  itemCount: listUser.length,
                  rowSeparatorWidget: const Divider(
                    color: Colors.black54,
                    height: 1.0,
                    thickness: 0.0,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 2,
                child: HorizontalDataTable(
                  leftHandSideColumnWidth: MediaQuery.of(context).size.width,
                  rightHandSideColumnWidth: 600,
                  isFixedHeader: true,
                  headerWidgets: _getTitleWidgetWork(),
                  leftSideItemBuilder: _generateFirstColumnRowWork,
                  rightSideItemBuilder: _generateRightHandSideColumnRow,
                  itemCount: listUserWork.length,
                  rowSeparatorWidget: const Divider(
                    color: Colors.black54,
                    height: 1.0,
                    thickness: 0.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget childAdministrator() {
      var child;
      switch (_page) {
        case 0:
          child = administratorMain();
          break;
        case 1:
          child = AnalyticScreen();
          break;
        case 2:
          child = DetailedStatics();
          break;
        case 3:
          child = SettingsScreen();
          break;
      }
      return child;
    }

    return WillPopScope(
      onWillPop: () async {
        return await false;
      },
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          index: 0,
          height: 60.0,
          items: <Widget>[
            Icon(Icons.phone_android_rounded, size: 30),
            Icon(Icons.stacked_bar_chart_sharp, size: 30),
            Icon(Icons.list, size: 30),
            Icon(Icons.perm_identity, size: 30),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Colors.blueAccent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 700),
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
          letIndexChange: (index) => true,
        ),
        body: childAdministrator(),
      ),
    );
  }
}
