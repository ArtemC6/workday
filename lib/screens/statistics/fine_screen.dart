import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:workday/data/fine_model.dart';

import '../../data/money_model.dart';
import '../../data/user_model.dart';
import 'information_users_screen.dart';

class FineScreens extends StatefulWidget {
  const FineScreens({Key? key}) : super(key: key);

  @override
  State<FineScreens> createState() => _FineScreens();
}

class _FineScreens extends State<FineScreens> {
  List<FineModel> listFine = [], listFineFull = [];

  bool isPosition = true, isPositionVisible = false, isEmpty = false;
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

  void calculation() async {
    await FirebaseFirestore.instance
        .collection('Fine')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((document) async {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        final Timestamp timestampStart = data['time'] as Timestamp;

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
        }
      });
    });

    if (!isEmpty) {
      Future.delayed(const Duration(milliseconds: 200), () async {
        listFine.forEach((element) {
          final dockMoney = FirebaseFirestore.instance.collection('Fine').doc();
          final json = {
            'name': element.name,
            'id_user': element.id_user,
            'id_post': dockMoney.id,
            'lateness': element.lateness,
            'time': element.time,
            'money_fine': element.money_fine,
          };
          dockMoney.set(json);
        });
      });
    }
  }

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
        readFirebase();
      });
    }
  }

  void readFirebase() async {
    // listFineFull.clear();
    // listFine.clear();
    await FirebaseFirestore.instance
        .collection('Work')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((document) async {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        final Timestamp timestampStart = data['startDate'] as Timestamp;
        final DateTime dateTimeStart = timestampStart.toDate();

        int formattedDate = int.parse(DateFormat('mm').format(dateTimeStart));
        String formattedDateHour = DateFormat('kk').format(dateTimeStart);

        setState(() {
          if (formattedDateHour == '07') {
            if (formattedDate <= 5) {
              listFine.add(FineModel(
                  name: data['name'],
                  lateness: formattedDate,
                  time: data['startDate'],
                  money_fine: 100,
                  id_user: data['id_user'],
                  id_post: ''));
            } else if (formattedDate <= 15) {
              listFine.add(FineModel(
                  name: data['name'],
                  lateness: formattedDate,
                  time: data['startDate'],
                  money_fine: 200,
                  id_user: data['id_user'],
                  id_post: ''));
            } else {
              listFine.add(FineModel(
                  name: data['name'],
                  lateness: formattedDate,
                  time: data['startDate'],
                  money_fine: 300,
                  id_user: data['id_user'],
                  id_post: ''));
            }
          }
        });
      });
    });

    await FirebaseFirestore.instance
        .collection('Fine')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((document) async {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        final Timestamp timestampStart = data['time'] as Timestamp;
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
          listFineFull.add(FineModel(
              name: data['name'],
              lateness: data['lateness'],
              time: data['time'],
              money_fine: data['money_fine'],
              id_user: data['id_user'],
              id_post: 'id_post'));
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readFirebase();
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
        _getTitleItemWidget('Время', 100),
        _getTitleItemWidget('Штраф', 100),
        _getTitleItemWidget('Дата', 100),
        _getTitleItemWidget('Подробней', 100),
      ];
    }

    List<Widget> _getTitleWidgetFull() {
      return [
        _getTitleItemWidget('Имя', 100),
        _getTitleItemWidget('Время', 100),
        _getTitleItemWidget('Штраф', 100),
        _getTitleItemWidget('Дата', 100),
        _getTitleItemWidget('Подробней', 100),
      ];
    }

    Widget _generateFirstColumnRow(BuildContext context, int index) {
      return Container(
        child: Text(listFineFull[index].name, style: TextStyle(fontSize: 16)),
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
              '${listFineFull[index].lateness.toString()}',
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
              '${listFineFull[index].money_fine.toString()}',
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
              '${getData(listFineFull[index].time)}',
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
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InformationUsersScreen(
                              id_user: listFineFull[index].id_user,
                              time: listFineFull[index].time,
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
          // Container(
          //   padding: EdgeInsets.only(left: 14, right: 14),
          //   child: listUser[index].workTime <= 60
          //       ? Text(
          //           '${listUser[index].workTime} минут ',
          //           style: TextStyle(fontSize: 16),
          //         )
          //       : Text(
          //           '${(listUser[index].workTime / 60).toStringAsFixed(1)} часов ',
          //           style: TextStyle(
          //             fontSize: 16,
          //           ),
          //         ),
          // ),
          // Container(
          //   child: Text(
          //     '${double.parse((listUser[index].money).toStringAsFixed(1).toString())} сом ',
          //     style: TextStyle(
          //       fontSize: 16,
          //     ),
          //   ),
          //   width: 100,
          //   height: 52,
          //   padding: EdgeInsets.only(left: 20),
          //   alignment: Alignment.centerLeft,
          // ),
          Container(
            child: Text(
              '${getData(listFineFull[index].time)}',
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
              if (listFineFull.length != 0)
                Text(
                  ' С ${getDataPeriod(_datePeriod!.start)} до ${getDataPeriod(_datePeriod!.end)}',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              if (listFineFull.length == 0)
                Text(
                  'Информации не найденно',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              if (listFineFull.length != 0)
                Container(
                  height: MediaQuery.of(context).size.height / 2.6,
                  child: HorizontalDataTable(
                    leftHandSideColumnWidth: 100,
                    rightHandSideColumnWidth: 600,
                    isFixedHeader: true,
                    headerWidgets: _getTitleWidget(),
                    leftSideItemBuilder: _generateFirstColumnRow,
                    rightSideItemBuilder: _generateRightHandSideColumnRow,
                    itemCount: listFineFull.length,
                    rowSeparatorWidget: const Divider(
                      color: Colors.black54,
                      height: 1.0,
                      thickness: 0.0,
                    ),
                  ),
                ),
              // if (listUser.length != 0)
              //   Container(
              //     height: MediaQuery.of(context).size.height / 2.6,
              //     child: HorizontalDataTable(
              //       leftHandSideColumnWidth: 100,
              //       rightHandSideColumnWidth: 600,
              //       isFixedHeader: true,
              //       headerWidgets: _getTitleWidgetFull(),
              //       leftSideItemBuilder: _generateFirstColumnRow,
              //       rightSideItemBuilder: _generateRightHandSideColumnRowFull,
              //       itemCount: listUser.length,
              //       rowSeparatorWidget: const Divider(
              //         color: Colors.black54,
              //         height: 1.0,
              //         thickness: 0.0,
              //       ),
              //     ),
              //   ),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
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
                    // Container(
                    //   padding: EdgeInsets.only(bottom: 20),
                    //   width: MediaQuery.of(context).size.width,
                    //   child: ElevatedButton(
                    //       onPressed: () {
                    //         calculation();
                    //       },
                    //       child: Text('Вернутdfdsfsfdsfься')),
                    // ),
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
