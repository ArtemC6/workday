import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import '../../data/user_model.dart';

class InformationUsersScreen extends StatefulWidget {
  var id_user, time;

  InformationUsersScreen(
      {Key? key, @required this.id_user, @required this.time})
      : super(key: key);

  @override
  State<InformationUsersScreen> createState() =>
      _InformationUsersScreen(id_user, time);
}

class _InformationUsersScreen extends State<InformationUsersScreen> {
  var idUser, time;

  _InformationUsersScreen(this.idUser, this.time);

  List<UserModel> listUser = [];
  bool isVisible = false;

  int getUserWorkTime(Timestamp startDate, Timestamp endDate) {
    final DateTime dateTimeStart = startDate.toDate();
    final DateTime dateTimeEnd = endDate.toDate();
    return dateTimeEnd.difference(dateTimeStart).inMinutes;
  }

  String getData(Timestamp startDate) {
    final DateTime dateTimeStart = startDate.toDate();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTimeStart);
    return formattedDate;
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
            if (data['endDate'] == '') {
              listUser.add(UserModel(
                  name: data["name"],
                  email: data["email"],
                  status: data["post"],
                  startUri: data["startUri"],
                  endUri:
                      'https://www.pinclipart.com/picdir/big/59-598920_clock-svg-png-icon-free-download-304848-weblogic.png',
                  startDate: data["startDate"],
                  endDate: data["startDate"],
                  id_user: data["id_user"],
                  id_post: data["id_post"],
                  money: 0.0,
                  workTime: 0));
              setState(() {});
            }
          }
        }

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
              }
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
        _getTitleItemWidget('С', 100),
        _getTitleItemWidget('До', 100),
        _getTitleItemWidget('Время', 100),
        _getTitleItemWidget('Фото', 100),
      ];
    }

    List<Widget> _getTitleWidgetAnalytics() {
      return [
        _getTitleItemWidget('Имя', 100),
        _getTitleItemWidget('С', 100),
        _getTitleItemWidget('До', 100),
        _getTitleItemWidget('Время', 100),
        _getTitleItemWidget('Сумма', 120),
        _getTitleItemWidget('Фото', 100),
      ];
    }

    Widget _generateFirstColumnRow(BuildContext context, int index) {
      return Container(
        child: Text(listUser[index].name, style: TextStyle(fontSize: 16)),
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
            child: Text(
              '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[0]} ',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[1]} ',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
            padding: EdgeInsets.only(left: 14),
            child: listUser[index].workTime <= 60
                ? Text(
                    '${listUser[index].workTime} минут ',
                    style: TextStyle(fontSize: 16),
                  )
                : Text(
                    '${(listUser[index].workTime / 60).toStringAsFixed(1)} часов ',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
          ),
          Container(
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => new AlertDialog(
                    title: new Text(''),
                    content: Column(
                      children: [
                        Container(
                          child: Image(
                            image: NetworkImage(listUser[index].startUri),
                            fit: BoxFit.fitWidth,
                          ),
                          height: MediaQuery.of(context).size.height / 2.8,
                          width: MediaQuery.of(context).size.width / 1,
                          padding: EdgeInsets.all(10),
                        ),
                        Container(
                          child: Image(
                            image: NetworkImage(listUser[index].endUri),
                            fit: BoxFit.fitWidth,
                          ),
                          height: MediaQuery.of(context).size.height / 2.8,
                          width: MediaQuery.of(context).size.width / 1,
                          padding: EdgeInsets.all(10),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Свернуть'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Фото'),
            ),
            width: 120,
            height: 30,
            padding: EdgeInsets.only(left: 40),
          ),
        ],
      );
    }

    Widget _generateRightHandSideColumnRowAnalytics(
        BuildContext context, int index) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
              '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[0]} ',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[1]} ',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
            padding: EdgeInsets.only(left: 14, right: 26),
            child: listUser[index].workTime <= 60
                ? Text(
                    '${listUser[index].workTime} минут ',
                    style: TextStyle(fontSize: 16),
                  )
                : Text(
                    '${(listUser[index].workTime / 60).toStringAsFixed(1)} часов ',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
          ),
          Container(
            child: Text(
              '${listUser[index].money} сом',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => new AlertDialog(
                    title: new Text(''),
                    content: Column(
                      children: [
                        Container(
                          child: Image(
                            image: NetworkImage(listUser[index].startUri),
                            fit: BoxFit.fitWidth,
                          ),
                          height: MediaQuery.of(context).size.height / 2.8,
                          width: MediaQuery.of(context).size.width / 1,
                          padding: EdgeInsets.all(10),
                        ),
                        Container(
                          child: Image(
                            image: NetworkImage(listUser[index].endUri),
                            fit: BoxFit.fitWidth,
                          ),
                          height: MediaQuery.of(context).size.height / 2.8,
                          width: MediaQuery.of(context).size.width / 1,
                          padding: EdgeInsets.all(10),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Свернуть'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Фото'),
            ),
            width: 120,
            height: 30,
            padding: EdgeInsets.only(left: 40),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Информация о сотрудники'),
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Container(
            padding: EdgeInsets.only(top: 20),
            alignment: Alignment.topCenter,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                if (!isVisible)
                  if (listUser.length != 0)
                    Container(
                      padding: EdgeInsets.only(left: 14),
                      alignment: Alignment.centerLeft,
                      child: getTotalTime(listUser) <= 60
                          ? Text(
                              textAlign: TextAlign.center,
                              '${listUser[0].name}: отработал ${getTotalTime(listUser)} минут:  ${getData(listUser[0].startDate)}',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            )
                          : Text(
                              textAlign: TextAlign.center,
                              '${listUser[0].name}: ${(getTotalTime(listUser) / 60).toStringAsFixed(1)} часов: ${getData(listUser[0].startDate)}',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                    ),
                if (isVisible)
                  if (listUser.length != 0)
                    Container(
                      padding: EdgeInsets.only(left: 14),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getTotalTime(listUser) <= 60
                              ? Text(
                                  textAlign: TextAlign.center,
                                  '${listUser[0].name}: отработал ${getTotalTime(listUser)} минут',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  textAlign: TextAlign.center,
                                  '${listUser[0].name}: ${(getTotalTime(listUser) / 60).toStringAsFixed(1)} часов',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                          Padding(padding: EdgeInsets.only(top: 8)),
                          Text(
                            textAlign: TextAlign.center,
                            'Получил: ${getTotalMoney(listUser).toString()} сом: за ${getData(listUser[0].startDate)}',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                if (!isVisible)
                  if (listUser.length != 0)
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      height: MediaQuery.of(context).size.height / 1.6,
                      child: HorizontalDataTable(
                        leftHandSideColumnWidth: 100,
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
                if (isVisible)
                  if (listUser.length != 0)
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      height: MediaQuery.of(context).size.height / 1.6,
                      child: HorizontalDataTable(
                        leftHandSideColumnWidth: 100,
                        rightHandSideColumnWidth: 600,
                        isFixedHeader: true,
                        headerWidgets: _getTitleWidgetAnalytics(),
                        leftSideItemBuilder: _generateFirstColumnRow,
                        rightSideItemBuilder:
                            _generateRightHandSideColumnRowAnalytics,
                        itemCount: listUser.length,
                        rowSeparatorWidget: const Divider(
                          color: Colors.black54,
                          height: 1.0,
                          thickness: 0.0,
                        ),
                      ),
                    ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
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
        // ),
      ),
    );
  }
}
