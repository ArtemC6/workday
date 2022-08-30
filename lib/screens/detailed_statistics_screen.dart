import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

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


        var timeStart2 = new DateTime(
          _dateTime!.start.year,
          _dateTime!.start.month,
          _dateTime!.start.day,
        );


        // print('С базы ${timeStart}');
        // print('С Выбора ${timeStart2}');

        if (dateTimeStart.isAfter(
            _dateTime!.start) /*&& dateTimeStart.isBefore(_dateTime!.end)*/) {

          // print(dateTimeStart.isAfter(
          //     _dateTime!.start));
          // if (timeStart == _dateTime?.start) {
          if (data['endDate'] != '') {
              var isExistMoney = listUserMoney.indexWhere(
                  (element) => element.id_user == (data['id_user']));

              // if (isExistMoney < 0) {
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
              // } else {
              //   listUserMoney[isExistMoney].money += data['money'];
              //
              //   listUserMoney[isExistMoney].workTime +=
              //       getUserWorkTime(data['startDate'], data['endDate']);
              // }
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
              '${listUserMoney[index].money} сом ',
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
              '${getData(listUserMoney[index].startDate)}',
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
                              time: listUserMoney[index].startDate,
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Подробная информация'),
      ),
      body: Container(
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
                height: MediaQuery.of(context).size.height / 1.8,
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

            // Container(
            //   padding: EdgeInsets.only(top: 20),
            //   height: MediaQuery.of(context).size.height / 2.8,
            //   child: ListView.builder(
            //     itemCount: listUserMoney.length,
            //     itemBuilder: (context, index) => Container(
            //         padding: EdgeInsets.only(top: 10),
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             InkWell(
            //               onTap: () {
            //                 Navigator.push(
            //                     context,
            //                     MaterialPageRoute(
            //                         builder: (context) =>
            //                             InformationUsersScreen(
            //                               id_user:
            //                                   listUserMoney[index].id_user,
            //                               time: listUserMoney[index]
            //                                   .startDate,
            //                             )));
            //               },
            //               child: Container(
            //                   width: MediaQuery.of(context).size.width / 1,
            //                   color: Colors.blue[100],
            //                   padding: EdgeInsets.all(12),
            //                   child: listUserMoney[index].workTime <= 60
            //                       ? Column(
            //                           children: [
            //                             Text(
            //                               '${listUserMoney[index].name} проработал: ${listUserMoney[index].workTime} минут:',
            //                               style: TextStyle(
            //                                   fontSize: 19,
            //                                   fontWeight: FontWeight.bold),
            //                             ),
            //                             Text(
            //                               'Получил: ${listUserMoney[index].money.toStringAsFixed(1)} сом:',
            //                               style: TextStyle(
            //                                   fontSize: 19,
            //                                   fontWeight: FontWeight.bold),
            //                             ),
            //                             Text(
            //                               'Дата: ${getData(listUserMoney[index].startDate)}',
            //                               style: TextStyle(
            //                                   fontSize: 17,
            //                                   fontWeight: FontWeight.bold),
            //                             )
            //                           ],
            //                         )
            //                       : Column(
            //                           children: [
            //                             Text(
            //                               '${listUserMoney[index].name} проработал: ${(listUserMoney[index].workTime / 60).toStringAsFixed(1)} часов:',
            //                               style: TextStyle(
            //                                   fontSize: 19,
            //                                   fontWeight: FontWeight.bold),
            //                             ),
            //                             Text(
            //                               'Получил: ${listUserMoney[index].money.toStringAsFixed(1)} сом:',
            //                               style: TextStyle(
            //                                   fontSize: 19,
            //                                   fontWeight: FontWeight.bold),
            //                             ),
            //                             Text(
            //                               'Дата: ${getData(listUserMoney[index].startDate)}',
            //                               style: TextStyle(
            //                                   fontSize: 17,
            //                                   fontWeight: FontWeight.bold),
            //                             )
            //                           ],
            //                         )),
            //             ),
            //           ],
            //         )),
            //   ),
            // ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
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
                    padding: EdgeInsets.only(top: 6),
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
            //       var currentTime = DateTime.now();
            //
            //       var dt1 = currentTime.add(Duration(days: -1));
            //
            //       print("Начало ${_dateTime?.start}");
            //       print("Конец ${_dateTime?.end} ");
            //
            //       print(
            //           "До ${_dateTime?.start.isBefore(_dateTime!.end)}");
            //       print(
            //           "После ${_dateTime?.end.isAfter(_dateTime!.start)}");
            //     },
            //     child: Text('dsfdsfdsfdsfdsf')),
          ],
        ),
      ),
    );
  }
}
