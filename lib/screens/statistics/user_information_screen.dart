import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import '../../data/const.dart';
import '../../data/user_model.dart';
import 'users_detailed_informaiton_screen.dart';

class UserInformationScreen extends StatefulWidget {
  var uid, post;

  UserInformationScreen({Key? key, @required this.uid, @required this.post})
      : super(key: key);

  @override
  State<UserInformationScreen> createState() =>
      _UserInformationScreen(uid, post);
}

class _UserInformationScreen extends State<UserInformationScreen> {
  var uid, post;

  _UserInformationScreen(this.uid, this.post);

  List<UserModel> listUser = [], listUserFull = [];
  bool isPositionVisible = false, isVisiblyProgress = false, isPosition = true;
  late DateTimeRange _datePeriod;
  var timeMain = 0;

  String getDataPeriod(DateTime startDate) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
    return formattedDate;
  }

  void readUserFirebase() async {
    listUser.clear();
    listUserFull.clear();

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

        DateTime start = _datePeriod.start;
        DateTime end = _datePeriod.end;

        start = start.subtract(Duration(seconds: 1));
        end = end.add(Duration(days: 1));
        end = end.subtract(Duration(seconds: 1));

        if (uid == null) {
          if (post != null) {
            if (data['post'] == post) {
              if (data['endDate'] != '') {
                if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
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

                  var isExistMoney = listUserFull.indexWhere(
                      (element) => element.id_user == (data['id_user']));

                  if (isExistMoney < 0) {
                    listUserFull.add(UserModel(
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
                        workTime: getUserWorkTime(
                            data["startDate"], data["endDate"])));
                    setState(() {});
                  } else {
                    listUserFull[isExistMoney].money += data['money'];

                    listUserFull[isExistMoney].workTime +=
                        getUserWorkTime(data['startDate'], data['endDate']);
                  }
                }
              }
            }
          }
        }

        if (uid == null) {
          if (post == null) {
            if (data['endDate'] != '') {
              if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
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

                var isExistMoney = listUserFull.indexWhere(
                    (element) => element.id_user == (data['id_user']));

                if (isExistMoney < 0) {
                  listUserFull.add(UserModel(
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
                  listUserFull[isExistMoney].money += data['money'];

                  listUserFull[isExistMoney].workTime +=
                      getUserWorkTime(data['startDate'], data['endDate']);
                }
              }
            }
          }
        }

        if (uid != null) {
          if (data['id_user'] == uid) {
            if (data['endDate'] != '') {
              if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
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

                var isExistMoney = listUserFull.indexWhere(
                    (element) => element.id_user == (data['id_user']));

                if (isExistMoney < 0) {
                  listUserFull.add(UserModel(
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
                  listUserFull[isExistMoney].money += data['money'];

                  listUserFull[isExistMoney].workTime +=
                      getUserWorkTime(data['startDate'], data['endDate']);
                }
              }
            }
          }
        }
      });
    });

    setState(() {
      isVisiblyProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var durationTime = Duration(minutes: timeMain);

    void _showDataTimeRange() async {
      final DateTimeRange? result = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2022, 1, 1),
          lastDate: DateTime(2030, 12, 31),
          currentDate: DateTime.now(),
          saveText: 'Выбрать');

      if (result != null) {
        setState(() {
          _datePeriod = result;
          isVisiblyProgress = true;
          readUserFirebase();
        });
      }
    }

    Widget _getTitleItemWidget(String label, double width) {
      return Container(
        child: Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        _getTitleItemWidget('Сумма', 120),
        _getTitleItemWidget('Дата', 110),
        _getTitleItemWidget('Подробней', 100),
      ];
    }

    List<Widget> _getTitleWidgetFull() {
      return [
        _getTitleItemWidget('Имя', 100),
        _getTitleItemWidget('Время', 100),
        _getTitleItemWidget('Сумма', 130),
        _getTitleItemWidget('Дата', 100),
      ];
    }

    Widget _generateFirstColumnRow(BuildContext context, int index) {
      return Container(
        child: Text(listUser[index].name,
            style: TextStyle(fontSize: 16, color: Colors.white)),
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
              child: Text(
                '${printDurationTime(Duration(minutes: listUser[index].workTime))}',
                style: TextStyle(fontSize: 16, color: Colors.white),
              )),
          Container(
            child: Text(
              '${double.parse((listUser[index].money).toStringAsFixed(1).toString())} сом ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 140,
            height: 52,
            padding: EdgeInsets.only(left: 40),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${getData(listUser[index].startDate)}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 120,
            height: 52,
            padding: EdgeInsets.only(left: 30),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UsersDetailedInformationScreen(
                              id_user: listUser[index].id_user,
                              timeStart: listUser[index].startDate,
                            )));
              },
              child: Text(
                'Подробней',
                style: TextStyle(color: Colors.black),
              ),
            ),
            width: 140,
            height: 30,
            padding: EdgeInsets.only(left: 40),
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
              child: Text(
                '${printDurationTime(Duration(minutes: listUserFull[index].workTime))}',
                style: TextStyle(fontSize: 16, color: Colors.white),
              )),
          Container(
            child: Text(
              '${double.parse((listUserFull[index].money).toStringAsFixed(1).toString())} сом ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 130,
            height: 52,
            padding: EdgeInsets.only(left: 40),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${getData(listUserFull[index].startDate)}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 130,
            height: 52,
            padding: EdgeInsets.only(left: 40),
            alignment: Alignment.centerLeft,
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: color_main_black,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (listUser.length != 0)
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    ' С ${getDataPeriod(_datePeriod.start)} до ${getDataPeriod(_datePeriod.end)}',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              if (listUser.length == 0)
                Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 2),
                  child: Text(
                    'Информации не найденно',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              if (isVisiblyProgress)
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: LinearProgressIndicator(
                      color: Colors.blueAccent,
                      backgroundColor: color_main_black),
                ),
              if (listUser.length != 0)
                Container(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: HorizontalDataTable(
                    leftHandSideColBackgroundColor: color_main_black,
                    rightHandSideColBackgroundColor: color_main_black,
                    leftHandSideColumnWidth: 110,
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
                ExpansionTile(
                  title: Text(
                    'Суммировать',
                    style: TextStyle(color: Colors.white),
                  ),
                  collapsedIconColor: Colors.white,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 2.0,
                      child: HorizontalDataTable(
                        leftHandSideColBackgroundColor: color_main_black,
                        rightHandSideColBackgroundColor: color_main_black,
                        leftHandSideColumnWidth: 110,
                        rightHandSideColumnWidth: 600,
                        isFixedHeader: true,
                        headerWidgets: _getTitleWidgetFull(),
                        leftSideItemBuilder: _generateFirstColumnRow,
                        rightSideItemBuilder:
                            _generateRightHandSideColumnRowFull,
                        itemCount: listUserFull.length,
                        rowSeparatorWidget: const Divider(
                          color: Colors.black54,
                          height: 1.0,
                          thickness: 0.0,
                        ),
                      ),
                    ),
                  ],
                ),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    if (uid != null)
                      Container(
                        padding: EdgeInsets.only(bottom: 40, top: 20),
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                            onPressed: () {
                              setState(() async {
                                _showDataTimeRange();
                              });
                            },
                            child: Text(
                              'Указать период',
                              style: TextStyle(color: Colors.black),
                            )),
                      ),
                    if (uid == null)
                      Container(
                        padding: EdgeInsets.only(bottom: 10, top: 20),
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                            onPressed: () {
                              setState(() async {
                                _showDataTimeRange();
                              });
                            },
                            child: Text(
                              'Указать период',
                              style: TextStyle(color: Colors.black),
                            )),
                      ),
                    if (uid == null)
                      Container(
                        padding: EdgeInsets.only(bottom: 20),
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Вернуться',
                              style: TextStyle(color: Colors.black),
                            )),
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
