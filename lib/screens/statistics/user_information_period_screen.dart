import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import '../../data/money_model.dart';
import '../../data/user_model.dart';
import 'information_users_screen.dart';

class UserInformationPeriodScreen extends StatefulWidget {
  var uid;

  UserInformationPeriodScreen({Key? key, @required this.uid}) : super(key: key);

  @override
  State<UserInformationPeriodScreen> createState() =>
      _UserInformationPeriodScreen(uid);
}

class _UserInformationPeriodScreen extends State<UserInformationPeriodScreen> {
  var uid;

  _UserInformationPeriodScreen(this.uid);

  List<UserModel> listUser = [];
  List<UserModel> listUserFull = [];

  bool isPosition = true;
  bool isPositionVisible = false;
  DateTimeRange? _datePeriod;

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

  String getDataPeriod(DateTime startDate) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
    return formattedDate;
  }

  void readUserFirebase() async {
    listUser.clear();
    listUserFull.clear();

    if (uid == null) {
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

          DateTime start = _datePeriod!.start;
          DateTime end = _datePeriod!.end;

          start = start.subtract(Duration(seconds: 1));
          end = end.add(Duration(days: 1));
          end = end.subtract(Duration(seconds: 1));

          if (data['endDate'] != '') {
            if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
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

              var isExistMoney = listUserFull.indexWhere(
                  (element) => element.id_user == (data['id_user']));

              if (isExistMoney < 0) {
                listUserFull.add(UserModel(
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
                listUserFull[isExistMoney].money += data['money'];

                listUserFull[isExistMoney].workTime +=
                    getUserWorkTime(data['startDate'], data['endDate']);
              }
            }
          }
        });
      });
    } else {
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

          DateTime start = _datePeriod!.start;
          DateTime end = _datePeriod!.end;

          start = start.subtract(Duration(seconds: 1));
          end = end.add(Duration(days: 1));
          end = end.subtract(Duration(seconds: 1));

          if (data['id_user'] == uid) {
            if (data['endDate'] != '') {
              if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
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

                var isExistMoney = listUserFull.indexWhere(
                    (element) => element.id_user == (data['id_user']));

                if (isExistMoney < 0) {
                  listUserFull.add(UserModel(
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
                  listUserFull[isExistMoney].money += data['money'];

                  listUserFull[isExistMoney].workTime +=
                      getUserWorkTime(data['startDate'], data['endDate']);
                }
              }
            }
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void _showDataTimeRange() async {
      final DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2022, 1, 1),
        lastDate: DateTime(2030, 12, 31),
        currentDate: DateTime.now(),
        saveText: 'Выбрать',
      );

      if (result != null) {
        setState(() {
          _datePeriod = result;
          readUserFirebase();
        });
      }
    }

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
        _getTitleItemWidget('Сумма', 100),
        _getTitleItemWidget('Дата', 100),
        _getTitleItemWidget('Подробней', 100),
      ];
    }

    List<Widget> _getTitleWidgetFull() {
      return [
        _getTitleItemWidget('Имя', 100),
        _getTitleItemWidget('Время', 100),
        _getTitleItemWidget('Сумма', 100),
        _getTitleItemWidget('Дата', 100),
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
            padding: EdgeInsets.only(left: 14, right: 14),
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
              '${double.parse((listUser[index].money).toStringAsFixed(1).toString())} сом ',
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
            child: Text(
              '${getData(listUser[index].startDate)}',
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InformationUsersScreen(
                              id_user: listUser[index].id_user,
                              time: listUser[index].startDate,
                            )));
              },
              child: Text('Подробней'),
            ),
            width: 140,
            height: 30,
            padding: EdgeInsets.only(left: 30),
          ),
        ],
      );
    }

    Widget _generateRightHandSideColumnRowFull(
        BuildContext context, int index) {
      return Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 14, right: 14),
            child: listUserFull[index].workTime <= 60
                ? Text(
                    '${listUserFull[index].workTime} минут ',
                    style: TextStyle(fontSize: 16),
                  )
                : Text(
                    '${(listUserFull[index].workTime / 60).toStringAsFixed(1)} часов ',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
          ),
          Container(
            child: Text(
              '${double.parse((listUserFull[index].money).toStringAsFixed(1).toString())} сом ',
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
            child: Text(
              '${getData(listUserFull[index].startDate)}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Информация'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (listUser.length != 0)
                Text(
                  ' С ${getDataPeriod(_datePeriod!.start)} до ${getDataPeriod(_datePeriod!.end)}',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              if (listUser.length == 0)
                Text(
                  'Информации не найденно',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              if (listUser.length != 0)
                Container(
                  height: MediaQuery.of(context).size.height / 2.6,
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
              if (listUserFull.length != 0)
                Container(
                  height: MediaQuery.of(context).size.height / 2.6,
                  child: HorizontalDataTable(
                    leftHandSideColumnWidth: 100,
                    rightHandSideColumnWidth: 600,
                    isFixedHeader: true,
                    headerWidgets: _getTitleWidgetFull(),
                    leftSideItemBuilder: _generateFirstColumnRow,
                    rightSideItemBuilder: _generateRightHandSideColumnRowFull,
                    itemCount: listUserFull.length,
                    rowSeparatorWidget: const Divider(
                      color: Colors.black54,
                      height: 1.0,
                      thickness: 0.0,
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    // Container(
                    //   padding: EdgeInsets.only(bottom: 6),
                    //   width: MediaQuery.of(context).size.width,
                    //   child: ElevatedButton(
                    //       onPressed: () {
                    //         setState(() {
                    //           readUserFirebase();
                    //         });
                    //       },
                    //       child: Text('Получить информацию')),
                    // ),
                    Container(
                      padding: EdgeInsets.only(bottom: 6),
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() async {
                              _showDataTimeRange();
                            });
                          },
                          child: Text('Указать период')),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
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
