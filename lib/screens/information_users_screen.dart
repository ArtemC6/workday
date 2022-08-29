import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../data/User.dart';

class InformationUsersScreen extends StatefulWidget {
  var id_user;
  var time;

  InformationUsersScreen(
      {Key? key, @required this.id_user, @required this.time})
      : super(key: key);

  @override
  State<InformationUsersScreen> createState() =>
      _InformationUsersScreen(id_user, time);
}

class _InformationUsersScreen extends State<InformationUsersScreen> {
  var idUser;

  var time;

  _InformationUsersScreen(this.idUser, this.time);

  List<UserModel> listUser = [];
  bool isVisible = false;

  int getUserWorkTime(Timestamp startDate, Timestamp endDate) {
    final DateTime dateTimeStart = startDate.toDate();
    final DateTime dateTimeEnd = endDate.toDate();
    return dateTimeEnd.difference(dateTimeStart).inMinutes;
  }

  List<String> getUerWorkTimeDifference(
      Timestamp startDate, Timestamp endDate) {
    List<String> list = [];
    final DateTime dateTimeStart = startDate.toDate();
    final DateTime dateTimeEnd = endDate.toDate();

    String formattedDateStater = DateFormat('kk:mm').format(dateTimeStart);
    String formattedDateEnd = DateFormat('kk:mm').format(dateTimeEnd);
    list.add(formattedDateStater);
    list.add(formattedDateEnd);
    return list;
  }

  @override
  void initState() {
    super.initState();
    listUser.clear();
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

        if (idUser == data['id_user']) {
          if (timeStart == currentTime) {
            if (data['endDate'] != '') {
              if (time == null) {
                setState(() {
                  isVisible = false;
                });
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
              } else {}
            }
          }

          if (time != null) {
            setState(() {
              isVisible = true;
            });

            final DateTime dateTimeStartCame = time.toDate();
            var timeStartCame = new DateTime(
              dateTimeStartCame.year,
              dateTimeStartCame.month,
              dateTimeStartCame.day,
            );

            if (timeStart == timeStartCame) {
              // print(data['money'));

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
                  money: data['money'],
                  workTime:
                      getUserWorkTime(data["startDate"], data["endDate"])));
              setState(() {});
            }
          }
        }
      });
    });
  }

  int getTotalTime(List<UserModel> users) {
    int number = 0;

    users.forEach((user) {
      number += user.workTime;
    });

    return number;
  }

  double getTotalMoney(List<UserModel> users) {
    double number = 0;

    users.forEach((user) {
      number += user.money;
    });

    return number;
  }

  getValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('key_price');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Информация о сотрудники'),
      ),
      body: RefreshIndicator(
        edgeOffset: 20,
        color: Colors.black,
        onRefresh: () async {
          setState(() {
            Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                    builder: (context) => new InformationUsersScreen(
                          id_user: idUser,
                          time: time,
                        )));
          });
        },
        child: SingleChildScrollView(
          child: Form(
            child: Container(
              alignment: Alignment.topCenter,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(left: 20, right: 10, bottom: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isVisible)
                    if (listUser.length != 0)
                      Container(
                        alignment: Alignment.centerLeft,
                        child: getTotalTime(listUser) <= 60
                            ? Text(
                                '${listUser[0].name}: отработал ${getTotalTime(listUser)} минут',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              )
                            : Text(
                                '${listUser[0].name}: ${(getTotalTime(listUser) / 60).toStringAsFixed(1)} часов',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                      ),
                  if (isVisible)
                    if (listUser.length != 0)
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            getTotalTime(listUser) <= 60
                                ? Text(
                                    '${listUser[0].name}: отработал ${getTotalTime(listUser)} минут',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )
                                : Text(
                                    '${listUser[0].name}: ${(getTotalTime(listUser) / 60).toStringAsFixed(1)} часов',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                            Padding(padding: EdgeInsets.only(top: 8)),
                            Text(
                              'Получил: ${getTotalMoney(listUser).toString()} сом',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  if (!isVisible)
                    if (listUser.length != 0)
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        height: MediaQuery.of(context).size.height / 1.6,
                        width: MediaQuery.of(context).size.width,
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
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3.0,
                                        child: listUser[index].workTime <= 60
                                            ? Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[0]} ',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[1]}',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '${listUser[index].workTime} м',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ],
                                              )
                                            : Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[0]} ',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[1]}',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '${(listUser[index].workTime / 60).toStringAsFixed(1)} ч',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              )),
                                    Image(
                                      image: NetworkImage(
                                          listUser[index].startUri),
                                      height: 80,
                                      width: 100,
                                      fit: BoxFit.fill,
                                    ),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Image(
                                      image:
                                          NetworkImage(listUser[index].endUri),
                                      height: 80,
                                      width: 100,
                                      fit: BoxFit.fill,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                  if (isVisible)
                    if (listUser.length != 0)
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        height: MediaQuery.of(context).size.height / 1.6,
                        width: MediaQuery.of(context).size.width,
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
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3.0,
                                        child: listUser[index].workTime <= 60
                                            ? Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[0]} ',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[1]}',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        '${listUser[index].workTime} м',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        '${listUser[index].money} сом',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[0]} ',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[1]}',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        '${(listUser[index].workTime / 60).toStringAsFixed(1)} ч',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        '${listUser[index].money} сом',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )),
                                    Image(
                                      image: NetworkImage(
                                          listUser[index].startUri),
                                      height: 80,
                                      width: 100,
                                      fit: BoxFit.fill,
                                    ),
                                    Padding(padding: EdgeInsets.only(left: 10)),
                                    Image(
                                      image:
                                          NetworkImage(listUser[index].endUri),
                                      height: 80,
                                      width: 100,
                                      fit: BoxFit.fill,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
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
          ),
        ),
      ),
    );
  }
}
