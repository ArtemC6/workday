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

class MoneyInformationScreen extends StatefulWidget {
  const MoneyInformationScreen({Key? key}) : super(key: key);

  @override
  State<MoneyInformationScreen> createState() => _MoneyInformationScreen();
}

class _MoneyInformationScreen extends State<MoneyInformationScreen> {
  List<MoneyModel> listUserMoney = [];
  List<MoneyModel> listUserMoneyFull = [];

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
    listUserMoney.clear();
    listUserMoneyFull.clear();
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

        DateTime start = _datePeriod!.start;
        DateTime end = _datePeriod!.end;

        start = start.subtract(Duration(seconds: 1));
        end = end.add(Duration(days: 1));
        end = end.subtract(Duration(seconds: 1));

        if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
          listUserMoney.add(MoneyModel(
              name: data["name"],
              extraditionMoney: data["extraditionMoney"],
              id_user: data["id_user"],
              id_post: data["id_post"],
              money: data['money'],
              workTime: data['workTime']));
          setState(() {});

          var isExistMoney = listUserMoneyFull
              .indexWhere((element) => element.id_user == (data['id_user']));

          if (isExistMoney < 0) {
            listUserMoneyFull.add(MoneyModel(
                name: data["name"],
                extraditionMoney: data["extraditionMoney"],
                id_user: data["id_user"],
                id_post: data["id_post"],
                money: data['money'],
                workTime: data['workTime']));
            setState(() {});
          } else {
            int valuer = data['workTime'];
            listUserMoneyFull[isExistMoney].money += data['money'];
            listUserMoneyFull[isExistMoney].workTime += valuer;
          }
        }
      });
    });
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
        child: Text(listUserMoney[index].name, style: TextStyle(fontSize: 16)),
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
            child: listUserMoney[index].workTime <= 60
                ? Text(
                    '${listUserMoney[index].workTime} минут ',
                    style: TextStyle(fontSize: 16),
                  )
                : Text(
                    '${(listUserMoney[index].workTime / 60).toStringAsFixed(1)} часов ',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
          ),
          Container(
            child: Text(
              '${double.parse((listUserMoney[index].money).toStringAsFixed(1).toString())} сом ',
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
              '${getData(listUserMoney[index].extraditionMoney)}',
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
                              id_user: listUserMoney[index].id_user,
                              time: listUserMoney[index].extraditionMoney,
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
            child: listUserMoneyFull[index].workTime <= 60
                ? Text(
                    '${listUserMoneyFull[index].workTime} минут ',
                    style: TextStyle(fontSize: 16),
                  )
                : Text(
                    '${(listUserMoneyFull[index].workTime / 60).toStringAsFixed(1)} часов ',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
          ),
          Container(
            child: Text(
              '${double.parse((listUserMoneyFull[index].money).toStringAsFixed(1).toString())} сом ',
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
              '${getData(listUserMoneyFull[index].extraditionMoney)}',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (listUserMoney.length != 0)
                Text(
                  ' С ${getDataPeriod(_datePeriod!.start)} до ${getDataPeriod(_datePeriod!.end)}',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              if (listUserMoney.length == 0)
                Text(
                  'Информации не найденно',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              if (listUserMoney.length != 0)
                Container(
                  height: MediaQuery.of(context).size.height / 2.6,
                  child: HorizontalDataTable(
                    leftHandSideColumnWidth: 100,
                    rightHandSideColumnWidth: 600,
                    isFixedHeader: true,
                    headerWidgets: _getTitleWidget(),
                    leftSideItemBuilder: _generateFirstColumnRow,
                    rightSideItemBuilder: _generateRightHandSideColumnRow,
                    itemCount: listUserMoney.length,
                    rowSeparatorWidget: const Divider(
                      color: Colors.black54,
                      height: 1.0,
                      thickness: 0.0,
                    ),
                  ),
                ),
              if (listUserMoneyFull.length != 0)
                Container(
                  height: MediaQuery.of(context).size.height / 2.6,
                  child: HorizontalDataTable(
                    leftHandSideColumnWidth: 100,
                    rightHandSideColumnWidth: 600,
                    isFixedHeader: true,
                    headerWidgets: _getTitleWidgetFull(),
                    leftSideItemBuilder: _generateFirstColumnRow,
                    rightSideItemBuilder: _generateRightHandSideColumnRowFull,
                    itemCount: listUserMoneyFull.length,
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
