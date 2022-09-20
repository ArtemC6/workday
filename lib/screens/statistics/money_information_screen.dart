import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import '../../data/const.dart';
import '../../data/money_model.dart';
import 'users_detailed_informaiton_screen.dart';

class MoneyInformationScreen extends StatefulWidget {
  var post;

  MoneyInformationScreen({Key? key, @required this.post}) : super(key: key);

  @override
  State<MoneyInformationScreen> createState() => _MoneyInformationScreen(post);
}

class _MoneyInformationScreen extends State<MoneyInformationScreen> {
  var post;

  _MoneyInformationScreen(this.post);

  List<MoneyModel> listUserMoney = [], listUserMoneyFull = [];
  bool isPositionVisible = false, isVisiblyProgress = false, isPosition = true;
  DateTimeRange? _datePeriod;

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
          if (post == data['post']) {
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
        }

        if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
          if (post == null) {
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
        }
      });
    });
    setState(() {
      isVisiblyProgress = false;
    });
  }

  @override
  void initState() {
    super.initState();
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
        _getTitleItemWidget('Дата', 120),
        _getTitleItemWidget('Подробней', 100),
      ];
    }

    List<Widget> _getTitleWidgetFull() {
      return [
        _getTitleItemWidget('Имя', 100),
        _getTitleItemWidget('Время', 110),
        _getTitleItemWidget('Сумма', 120),
        _getTitleItemWidget('Дата', 100),
      ];
    }

    Widget _generateFirstColumnRow(BuildContext context, int index) {
      return Container(
        child: Text(listUserMoney[index].name,
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
              padding: EdgeInsets.only(left: 14, right: 20),
              child: Text(
                  '${printDurationTime(Duration(minutes: listUserMoney[index].workTime))}',
                  style: TextStyle(fontSize: 16, color: Colors.white))),
          Container(
            // color: Colors.green,

            child: Text(
              '${double.parse((listUserMoney[index].money).toStringAsFixed(1).toString())} сом ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 130,
            height: 52,
            padding: EdgeInsets.only(left: 34),
            alignment: Alignment.centerLeft,
          ),
          Container(
            // color: Colors.green,
            child: Text(
              '${getData(listUserMoney[index].extraditionMoney)}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 130,
            height: 52,
            padding: EdgeInsets.only(left: 30),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UsersDetailedInformationScreen(
                              id_user: listUserMoney[index].id_user,
                          timeStart: listUserMoney[index].extraditionMoney,
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
              child: Text(
                  '${printDurationTime(Duration(minutes: listUserMoneyFull[index].workTime))}',
                  style: TextStyle(fontSize: 16, color: Colors.white))),
          Container(
            child: Text(
              '${double.parse((listUserMoneyFull[index].money).toStringAsFixed(1).toString())} сом ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 150,
            height: 52,
            padding: EdgeInsets.only(left: 40),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${getData(listUserMoneyFull[index].extraditionMoney)}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 120,
            height: 52,
            padding: EdgeInsets.only(left: 30),
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
              if (listUserMoney.length != 0)
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    ' С ${getDataPeriod(_datePeriod!.start)} до ${getDataPeriod(_datePeriod!.end)}',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              if (listUserMoney.length == 0)
                Container(
                  padding: EdgeInsets.only(
                      bottom: 20, top: MediaQuery.of(context).size.height / 2),
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
              if (listUserMoney.length != 0)
                Container(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: HorizontalDataTable(
                    rightHandSideColBackgroundColor: color_main_black,
                    leftHandSideColBackgroundColor: color_main_black,
                    leftHandSideColumnWidth: 110,
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
                        rightHandSideColBackgroundColor: color_main_black,
                        leftHandSideColBackgroundColor: color_main_black,
                        leftHandSideColumnWidth: 110,
                        rightHandSideColumnWidth: 600,
                        isFixedHeader: true,
                        headerWidgets: _getTitleWidgetFull(),
                        leftSideItemBuilder: _generateFirstColumnRow,
                        rightSideItemBuilder:
                            _generateRightHandSideColumnRowFull,
                        itemCount: listUserMoneyFull.length,
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
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
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
