import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

import '../data/Money.dart';
import '../data/User.dart';
import 'information_users_screen.dart';

class DetailedStatics extends StatefulWidget {
  const DetailedStatics({Key? key}) : super(key: key);

  @override
  State<DetailedStatics> createState() => _DetailedStatics();
}

class _DetailedStatics extends State<DetailedStatics> {
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
        start = start.subtract(Duration(seconds: 1))
        end = end.add(Duration(days: 1));
        end = end.subtract(Duration(seconds: 1));

        // print(start);
        // print(end);
        // print(timeStart);
        // print("====");
        // print(timeStart.isAfter(start));
        // print(timeStart.isBefore(end));
        if ( timeStart.isAfter(start) && timeStart.isBefore(end)) {

          listUserMoney.add(MoneyModel(
              name: data["name"],
              extraditionMoney: data["extraditionMoney"],
              id_user: data["id_user"],
              id_post: data["id_post"],
              money: data['money'],
              workTime: data['workTime']));
          setState(() {});

          // var isExistMoney = listUserMoneyFull
          //     .indexWhere((element) => element.id_user == (data['id_user']));
          //
          // if (isExistMoney < 0) {
          //   listUserMoneyFull.add(MoneyModel(
          //       name: data["name"],
          //       extraditionMoney: data["extraditionMoney"],
          //       id_user: data["id_user"],
          //       id_post: data["id_post"],
          //       money: data['money'],
          //       workTime: data['workTime']));
          //   setState(() {});
          // } else {
          //   // listUserMoneyFull[isExistMoney].money += data['money'];
          //   // listUserMoneyFull[isExistMoney].workTime +=
          //   //     int.parse(data['workTime']);
          // }
        }
      });
    });

    // print(_datePeriod);
    // print(_datePeriod!.start);
    // print(_datePeriod!.end);
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
        // _getTitleItemWidget('Начало', 100),
        // _getTitleItemWidget('Конец', 100),
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

          // Container(
          //   child: Image(
          //     image: NetworkImage(listUser[index].startUri),
          //     height: 80,
          //     width: 80,
          //     fit: BoxFit.fill,
          //   ),
          //   width: 100,
          //   height: 52,
          //   padding: EdgeInsets.only(left: 40),
          // ),
          // Container(
          //   child: Image(
          //     image: NetworkImage(listUser[index].endUri),
          //     height: 80,
          //     width: 80,
          //     fit: BoxFit.fill,
          //   ),
          //   width: 100,
          //   height: 52,
          //   padding: EdgeInsets.only(left: 40),
          // ),
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
          Container(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InformationUsersScreen(
                              id_user: listUserMoneyFull[index].id_user,
                              time: listUserMoneyFull[index].extraditionMoney,
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Подробная информация'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    headerWidgets: _getTitleWidget(),
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
                    Container(
                      padding: EdgeInsets.only(bottom: 6),
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              readUserFirebase();
                            });
                          },
                          child: Text('Получить информацию')),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 6),
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {
                            _showDataTimeRange();
                          },
                          child: Text('Выбрать дату')),
                    ),
                    Container(
                      padding: EdgeInsets.only(),
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

              // ElevatedButton(
              //     onPressed: () {
              //       var ATime = DateTime.utc(2020, 12, 22, 23, 22);
              //
              //       // subtract() => BTime
              //       var BTime = ATime.subtract(Duration(days: 2));
              //
              //       // add() => CTime
              //       var CTime = BTime.add(Duration(days: 2));
              //
              //       // Print
              //       print(ATime);
              //       print(BTime);
              //       print(CTime);
              //       print("ATime is before BTime: ${ATime.isBefore(BTime)}");
              //       print("ATime is after BTime: ${ATime.isAfter(BTime)}");
              //       print(
              //           "ATime is equal to CTime: ${ATime.isAtSameMomentAs(CTime)}");
              //
              //       // var currentTime = DateTime.now();
              //       //
              //       // var dt1 = currentTime.add(Duration(days: -1));
              //       //
              //       // print("Начало ${_datePeriod?.start}");
              //       // print("Конец ${_datePeriod?.end} ");
              //       //
              //       // print(
              //       //     "До ${_datePeriod?.start.isBefore(_datePeriod!.end)}");
              //       //
              //       // print(
              //       //     "После ${_datePeriod?.start.isAfter(_datePeriod!.end)}");
              //     },
              //     child: Text('dsfdsfdsfdsfdsf')),
            ],
          ),
        ),
      ),
    );
  }
}
