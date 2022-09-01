import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workday/screens/extradition_screen.dart';

import '../data/user_model.dart';
import 'statistics/information_users_screen.dart';

class AnalyticScreen extends StatefulWidget {
  const AnalyticScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  List<UserModel> listUser = [], listUserWork = [], listUserMoney = [];
  String _sum = '0.0';
  final formKey = GlobalKey<FormState>();
  bool isPosition = true, isEmpty = false;

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
      body: SingleChildScrollView(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AnalyticScreen()));
            });
          },
          child: Form(
            key: formKey,
            child: Container(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isPosition)
                    Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 20, bottom: 20, left: 14),
                        child: Text(
                          "Сегодня работали ${listUser.length.toString()}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                  Container(
                    height: MediaQuery.of(context).size.height / 1.8,
                    child: ListView.separated(
                        itemCount: listUser.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            Container(
                              // padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Divider(
                                height: 1.0,
                                color: Colors.black54,
                              ),
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          InformationUsersScreen(
                                            id_user: listUser[index].id_user,
                                          )));
                            },
                            child: listUser[index].workTime <= 60
                                ? Container(
                                    padding: EdgeInsets.all(14),
                                    child: Text(
                                        "${listUser[index].name} ${listUser[index].workTime} минут ",
                                        style: TextStyle(fontSize: 17)))
                                : Container(
                                    padding: EdgeInsets.all(14),
                                    child: Text(
                                        "${listUser[index].name} ${(listUser[index].workTime / 60).toStringAsFixed(1)} часов ",
                                        style: TextStyle(fontSize: 17))),
                          );
                        }),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1,
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10),
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
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ExtraditionScreen(
                                        sum: _sum,
                                      )));
                        }
                      },
                      child: Text('Сделать подчет'),
                    ),
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
