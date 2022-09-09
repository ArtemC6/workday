import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workday/screens/administrator_screen.dart';
import 'package:workday/screens/extradition_screen.dart';

import '../data/user_model.dart';
import 'statistics/information_users_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AnalyticScreen extends StatefulWidget {
  const AnalyticScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  List<UserModel> listUser = [], listUserWork = [], listUserMoney = [];
  bool isPosition = true, isEmpty = false;

  int getUserWorkTime(Timestamp startDate, Timestamp endDate) {
    final DateTime dateTimeStart = startDate.toDate();
    final DateTime dateTimeEnd = endDate.toDate();
    return dateTimeEnd.difference(dateTimeStart).inMinutes;
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
                    status: data["post"],
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
                status: data["post"],
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
                  status: data["post"],
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

  Widget _buildBottomSheet(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(11.0),
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
                          builder: (BuildContext context) => ExtraditionScreen(
                                status: 'barista',
                              )));
                },
                child: Text('Выдать барменам'),
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
                          builder: (BuildContext context) => ExtraditionScreen(
                                status: 'cook',
                              )));
                },
                child: Text('Выдать поворам'),
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
                          builder: (BuildContext context) => ExtraditionScreen(
                                status: 'maid',
                              )));
                },
                child: Text('Выдать горничным'),
              ),
            ),
            // Container(
            //   padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () async {
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (BuildContext context) => ExtraditionScreen(
            //                     status: 'confectionery',
            //                   )));
            //     },
            //     child: Text('Выдать консьержу'),
            //   ),
            // ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ExtraditionScreen(
                                status: 'admin',
                              )));
                },
                child: Text('Выдать администратору'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    readFirebase();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => AdministratorScreen(
                          value: 1,
                        )));
          });
        },
        child: SingleChildScrollView(
          child: Container(
            height: _height,
            child: Column(
              children: [
                if (isPosition)
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 40, left: 14),
                      child: Text(
                        "Сегодня работали ${listUser.length.toString()}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                Container(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: ListView.separated(
                      physics: BouncingScrollPhysics(),
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
                                  child: ListTile(
                                  trailing:
                                      Icon(Icons.arrow_forward_ios, size: 18),
                                  title: Text(
                                      "${listUser[index].name} ${listUser[index].workTime} минут ",
                                      style: TextStyle(fontSize: 17)),
                                ))
                              : Container(
                                  child: ListTile(
                                  trailing:
                                      Icon(Icons.arrow_forward_ios, size: 18),
                                  title: Text(
                                      "${listUser[index].name} ${(listUser[index].workTime / 60).toStringAsFixed(1)} часов ",
                                      style: TextStyle(fontSize: 17)),
                                )),
                        );
                      }),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      showCupertinoModalBottomSheet(
                        duration: Duration(milliseconds: 700),
                        backgroundColor: Color(0xff212428),
                        context: context,
                        builder: (context) => _buildBottomSheet(context),
                      );
                    },
                    child: Text('Выдача'),
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
