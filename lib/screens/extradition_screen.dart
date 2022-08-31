import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import '../data/User.dart';
import 'analytics_screen.dart';
import 'information_users_screen.dart';

class ExtraditionScreen extends StatefulWidget {
  var sum;

  ExtraditionScreen({Key? key, @required this.sum}) : super(key: key);

  @override
  State<ExtraditionScreen> createState() => _ExtraditionScreenScreenState(sum);
}

class _ExtraditionScreenScreenState extends State<ExtraditionScreen> {
  List<UserModel> listUser = [];
  List<UserModel> listUserWork = [];
  List<UserModel> listUserMoney = [];
  String _sum = '0.0';
  String _percent = '0';

  _ExtraditionScreenScreenState(this._sum);

  final formKey = GlobalKey<FormState>();
  bool isEmpty = false;

  int getUserWorkTime(Timestamp startDate, Timestamp endDate) {
    final DateTime dateTimeStart = startDate.toDate();
    final DateTime dateTimeEnd = endDate.toDate();
    return dateTimeEnd.difference(dateTimeStart).inMinutes;
  }

  void calculation(List<UserModel> listWork) async {
    final dockUsers = FirebaseFirestore.instance.collection('Work');
    listWork.forEach((element) {
      final json = {
        'money': double.parse(element.money.toStringAsFixed(1)),
        'workTime': element.workTime,
        'extraditionMoney': DateTime.now(),
      };
      dockUsers.doc(element.id_post).update(json);
    });

    listUserMoney.clear();

    await FirebaseFirestore.instance
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
          if (data['endDate'] != '') {
            if (data['money'] != '0.0') {
              var isExistMoney = listUserMoney.indexWhere(
                  (element) => element.id_user == (data['id_user']));

              if (isExistMoney < 0) {
                listUserMoney.add(UserModel(
                    name: data["name"],
                    email: data["email"],
                    status: data["status"],
                    startUri: data["startUri"],
                    endUri: data["endUri"],
                    startDate: data["startDate"],
                    endDate: data["endDate"],
                    id_user: data["id_user"],
                    id_post: data["id_post"],
                    money: data['money'],
                    workTime:
                        getUserWorkTime(data["startDate"], data["endDate"])));
                setState(() {});
              } else {
                listUserMoney[isExistMoney].money += data['money'];

                listUserMoney[isExistMoney].workTime +=
                    getUserWorkTime(data['startDate'], data['endDate']);
              }
            }
          }
        }
      });
    });

    await FirebaseFirestore.instance
        .collection('Money')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((document) async {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        final Timestamp timestampStart = data['extraditionMoney'] as Timestamp;
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
          print('object_1');
          final dockUsers =
              await FirebaseFirestore.instance.collection('Money');
          dockUsers.doc(document.id).delete();
        } else {
          print('object_2');
          setState(() {
            isEmpty = false;
          });
        }
      });
    });

    if (!isEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () async {
        listUserMoney.forEach((element) {
          final dockMoney =
              FirebaseFirestore.instance.collection('Money').doc();
          final json = {
            'money': double.parse(element.money.toStringAsFixed(1)),
            'name': element.name,
            'id_user': element.id_user,
            'id_post': dockMoney.id,
            'workTime': element.workTime,
            'extraditionMoney': DateTime.now(),
          };
          dockMoney.set(json);
        });
      });

      showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text(''),
          content: Image.asset('images/ic_check.png'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(); // dismisses only the dialog and returns nothing
              },
              child: new Text(''),
            ),
          ],
        ),
      );

      Future.delayed(const Duration(milliseconds: 1000), () async {
        Navigator.pop(context);
      });
    }
  }

  void readFirebase() async {
    await FirebaseFirestore.instance
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
          if (data['endDate'] != '') {
            if (data['money'] != '0.0') {
              var isExistMoney = listUserMoney.indexWhere(
                  (element) => element.id_user == (data['id_user']));

              if (isExistMoney < 0) {
                listUserMoney.add(UserModel(
                    name: data["name"],
                    email: data["email"],
                    status: data["status"],
                    startUri: data["startUri"],
                    endUri: data["endUri"],
                    startDate: data["startDate"],
                    endDate: data["endDate"],
                    id_user: data["id_user"],
                    id_post: data["id_post"],
                    money: data['money'],
                    workTime:
                        getUserWorkTime(data["startDate"], data["endDate"])));
                setState(() {});
              } else {
                listUserMoney[isExistMoney].money += data['money'];

                listUserMoney[isExistMoney].workTime +=
                    getUserWorkTime(data['startDate'], data['endDate']);
              }
            }

            listUserWork.add(UserModel(
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
                workTime: getUserWorkTime(data["startDate"], data["endDate"])));
            setState(() {});

            var isExist = listUser
                .indexWhere((element) => element.id_user == (data['id_user']));

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
              setState(() {});
            } else {
              listUser[isExist].workTime +=
                  getUserWorkTime(data['startDate'], data['endDate']);
            }
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

  List<UserModel> getTotalTime(List<UserModel> users, double sum) {
    int totalTime = 0;

    users.forEach((user) {
      totalTime += user.workTime;
    });

    users.forEach((user) {
      user.money = user.workTime / totalTime * sum;
    });

    return users;
  }

  double getTotalMoney(List<UserModel> users) {
    double number = 0.0;
    users.forEach((user) {
      number += user.money;
    });

    return number;
  }

  int getTotalTimeJoin(List<UserModel> users) {
    int number = 0;

    users.forEach((user) {
      number += user.workTime;
    });

    return number;
  }

  @override
  Widget build(BuildContext context) {
    // print(getValue());
    // double percent = double.parse(_percent) / 100;
    // double money = double.parse(_sum) * percent;
    double money = double.parse(_sum) * 0.07;

    Widget _getTitleItemWidget(String label, double width) {
      return Container(
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        width: width,
        height: 56,
        padding: EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
      );
    }

    List<Widget> _getTitleWidget() {
      return [
        _getTitleItemWidget('Имя', 100),
        _getTitleItemWidget('Время', 100),
        _getTitleItemWidget('Сумма', 200),
      ];
    }

    Widget _generateFirstColumnRow(BuildContext context, int index) {
      return Container(
        child: Text(listUser[index].name),
        width: 100,
        height: 52,
        padding: EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
      );
    }

    Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
      return Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 14),
            child: listUser[index].workTime <= 60
                ? Text(
                    '${listUser[index].workTime} минут ',
                    style: TextStyle(fontSize: 15),
                  )
                : Text(
                    '${(listUser[index].workTime / 60).toStringAsFixed(1)} часов ',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
          ),
          Container(
            padding: EdgeInsets.only(left: 34),
            child: Text(
                "${getTotalTime(listUser, money)[index].money.toStringAsFixed(1)} сом"),
            width: 200,
            height: 52,
            // padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Расчет'),
      ),
      body: Form(
        key: formKey,
        child: Container(
          alignment: Alignment.topCenter,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Общаая выручка: ${_sum}", style: TextStyle(fontSize: 22)),
              Container(
                padding: EdgeInsets.only(top: 6, bottom: 6),
              ),
              Text("Сотрудникам: ${(money).toStringAsFixed(1)}",
                  style: TextStyle(fontSize: 22)),
              Padding(padding: EdgeInsets.only(top: 30)),
              Container(
                height: MediaQuery.of(context).size.height / 2,
                child: HorizontalDataTable(
                  leftHandSideColumnWidth: 80,
                  rightHandSideColumnWidth: 600,
                  isFixedHeader: true,
                  headerWidgets: _getTitleWidget(),
                  leftSideItemBuilder: _generateFirstColumnRow,
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
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () async {
                            calculation(getTotalTime(listUserWork, money));
                          },
                          child: Text('Выдать дньги')),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Вернуться')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
