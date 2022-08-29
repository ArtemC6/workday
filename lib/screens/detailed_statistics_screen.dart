import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import '../data/User.dart';
import 'information_users_screen.dart';

class DetailedStatics extends StatefulWidget {
  const DetailedStatics({Key? key}) : super(key: key);

  @override
  State<DetailedStatics> createState() => _DetailedStatics();
}

class _DetailedStatics extends State<DetailedStatics> {
  List<UserModel> listUserMoney = [];

  bool isPosition = true;
  bool isPositionVisible = false;
  DateTimeRange? _dateTime;

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

        // print(dateTimeStart.isAfter(_dateTime!.start));
        print(dateTimeStart.isBefore(_dateTime!.start));

        if (dateTimeStart.isAfter(_dateTime!.start) /*&& dateTimeStart.isBefore(_dateTime!.end)*/) {
          // if (timeStart == _dateTime?.start) {
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
        // print(result.start.toString());
        // print(result.end.toString());
        setState(() {
          _dateTime = result;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Подробная информация'),
      ),
      body: RefreshIndicator(
        edgeOffset: 20,
        color: Colors.black,
        onRefresh: () async {
          setState(() {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => DetailedStatics()));
          });
        },
        child: SingleChildScrollView(
          child: Form(
            child: Container(
              alignment: Alignment.topCenter,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (listUserMoney.length == 0)
                    Text(
                      'Информации не найденно',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                  if (listUserMoney.length != 0)
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      height: MediaQuery.of(context).size.height / 2.8,
                      child: ListView.builder(
                        itemCount: listUserMoney.length,
                        itemBuilder: (context, index) => Container(
                            padding: EdgeInsets.only(top: 10),
                            child: Column(
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
                                                  id_user: listUserMoney[index]
                                                      .id_user,
                                                  time: listUserMoney[index]
                                                      .startDate,
                                                )));
                                  },
                                  child: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 1,
                                      color: Colors.blue[100],
                                      padding: EdgeInsets.all(12),
                                      child: listUserMoney[index].workTime <= 60
                                          ? Column(
                                              children: [
                                                Text(
                                                  '${listUserMoney[index].name} проработал: ${listUserMoney[index].workTime} минут:',
                                                  style: TextStyle(
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  'Получил: ${listUserMoney[index].money.toStringAsFixed(1)} сом:',
                                                  style: TextStyle(
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  'Дата: ${getData(listUserMoney[index].startDate)}',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                Text(
                                                  '${listUserMoney[index].name} проработал: ${(listUserMoney[index].workTime / 60).toStringAsFixed(1)} часов:',
                                                  style: TextStyle(
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  'Получил: ${listUserMoney[index].money.toStringAsFixed(1)} сом:',
                                                  style: TextStyle(
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  'Дата: ${getData(listUserMoney[index].startDate)}',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            )),
                                ),
                              ],
                            )),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.only(bottom: 6, top: 6),
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
                    padding: EdgeInsets.only(bottom: 6, top: 6),
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        onPressed: () {
                          _showDataTimeRange();
                        },
                        child: Text('Выбрать дату')),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Вернуться')),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        var currentTime = DateTime.now();

                        var dt1 = currentTime.add(Duration(days: -1));

                        print("Начало ${_dateTime?.start}");
                        print("Конец ${_dateTime?.end} ");

                        print(
                            "До ${_dateTime?.start.isBefore(_dateTime!.end)}");
                        print(
                            "После ${_dateTime?.start.isAfter(_dateTime!.end)}");
                      },
                      child: Text('dsfdsfdsfdsfdsf')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
