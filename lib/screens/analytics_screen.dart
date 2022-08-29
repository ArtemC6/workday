import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/User.dart';
import 'information_users_screen.dart';

class AnalyticScreen extends StatefulWidget {
  const AnalyticScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  List<UserModel> listUser = [];
  List<UserModel> listUserWork = [];
  List<UserModel> listUserMoney = [];
  String _sum = '0.0';
  String _percent = '0';

  final formKey = GlobalKey<FormState>();
  bool isPosition = true;
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
          setState(() {
            isEmpty = true;
          });
        } else {
          setState(() {
            isEmpty = true;
          });
        }
      });
    });

    if (isEmpty) {
      Future.delayed(const Duration(milliseconds: 1000), () async {
        await FirebaseFirestore.instance
            .collection('Money')
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((document) async {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            final Timestamp timestampStart =
                data['extraditionMoney'] as Timestamp;
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
              final dockUsers =
                  await FirebaseFirestore.instance.collection('Money');
              dockUsers.doc(document.id).delete();
            }
          });
        });

        if (listUserMoney.length != 0) {
          listUserMoney.forEach((element) {
            final docMoney =
                FirebaseFirestore.instance.collection('Money').doc();
            final json = {
              'money': element.money.toStringAsFixed(1),
              'name': element.name,
              'id_user': element.id_user,
              'id_post': docMoney.id,
              'workTime': element.workTime,
              'extraditionMoney': DateTime.now(),
            };
            docMoney.set(json);
          });
          Navigator.pop(context);
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (listUserMoney.length != 0) {
          listUserMoney.forEach((element) {
            final docMoney =
                FirebaseFirestore.instance.collection('Money').doc();
            final json = {
              'money': element.money.toStringAsFixed(1),
              'name': element.name,
              'id_user': element.id_user,
              'id_post': docMoney.id,
              'workTime': element.workTime,
              'extraditionMoney': DateTime.now(),
            };
            docMoney.set(json);
          });
          Navigator.pop(context);
        }
      });
    }
  }

  void readFirebase() async {
    List<UserModel> listTake = [];
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

  getValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('key_price');
  }

  @override
  Widget build(BuildContext context) {
    // print(getValue());
    // double percent = double.parse(_percent) / 100;
    // double money = double.parse(_sum) * percent;
    double money = double.parse(_sum) * 0.07;

    return Scaffold(
      appBar: AppBar(
        title: Text('Расчет'),
      ),
      body: RefreshIndicator(
        edgeOffset: 20,
        color: Colors.black,
        onRefresh: () async {
          setState(() {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => AnalyticScreen()));
          });
        },
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Container(
              alignment: Alignment.topCenter,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isPosition)
                    Text(
                        "Общаая выручка: ${_sum}\n\nСотрудникам: ${(money).toStringAsFixed(1)}",
                        style: TextStyle(fontSize: 22)),
                  if (isPosition)
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Сегодня отработала: ${listUser.length.toString()}',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (isPosition)
                    Container(
                      padding: EdgeInsets.only(),
                      height: MediaQuery.of(context).size.height / 2.2,
                      child: ListView.builder(
                        itemCount: listUser.length,
                        itemBuilder: (context, index) => Container(
                          padding: EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  InformationUsersScreen(
                                                    id_user:
                                                        listUser[index].id_user,
                                                  )));
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(8),
                                        child: listUser[index].workTime <= 60
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${listUser[index].name}: ${listUser[index].workTime} минут',
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${listUser[index].name}: ${(getTotalTimeJoin(listUserWork) / 60).toStringAsFixed(1)} часов ',
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              )),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (!isPosition)
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      height: MediaQuery.of(context).size.height / 2.1,
                      child: ListView.builder(
                        itemCount: getTotalTime(listUser, money).length,
                        itemBuilder: (context, index) => Container(
                            padding: EdgeInsets.only(top: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  child: getTotalTime(listUser, money)[index]
                                              .workTime <=
                                          60
                                      ? Text(
                                          '${getTotalTime(listUser, money)[index].name} проработал: ${listUser[index].workTime} минут:',
                                          style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : Text(
                                          '${getTotalTime(listUser, money)[index].name} проработал: ${(listUser[index].workTime / 60).toStringAsFixed(1)} часов:',
                                          style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 4, bottom: 8),
                                  child: Text(
                                    '${getTotalTime(listUser, money)[index].money.toStringAsFixed(1)} сом',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                  if (isPosition)
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: TextFormField(
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
                          hintText: 'Введите выручку',
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
                          setState(() {
                            if (value.length >= 1) {
                              _sum = value;
                            }
                          });
                        },
                      ),
                    ),
                  if (isPosition)
                    Container(
                      padding: EdgeInsets.only(top: 40),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              isPosition = false;
                            });
                          }
                        },
                        child: Text('Сделать подчет'),
                      ),
                    ),
                  if (!isPosition)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () async {
                            calculation(getTotalTime(listUserWork, money));
                          },
                          child: Text('Выдать дньги')),
                    ),
                  if (!isPosition)
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
          ),
        ),
      ),
    );
  }
}
