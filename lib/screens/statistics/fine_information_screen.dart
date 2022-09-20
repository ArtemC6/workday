import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:workday/data/fine_model.dart';
import '../../data/const.dart';
import 'users_detailed_informaiton_screen.dart';

class FineScreens extends StatefulWidget {
  var post;

  FineScreens({Key? key, @required this.post}) : super(key: key);

  @override
  State<FineScreens> createState() => _FineScreens(post);
}

class _FineScreens extends State<FineScreens> {
  var post;

  _FineScreens(this.post);

  List<FineModel> listFine = [],
      listFineFull = [],
      listFineComplete = [],
      listFineFullDownloaded = [];

  bool isPosition = true,
      isPositionVisible = false,
      isEmpty = true,
      isVisiblyProgress = false;

  DateTimeRange? _datePeriod;

  String getDataPeriod(DateTime startDate) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
    return formattedDate;
  }

  void calculationFine() async {
    listFine.clear();
    listFineFullDownloaded.clear();

    await FirebaseFirestore.instance
        .collection('Work')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((document) async {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        final Timestamp timestampStart = data['startDate'] as Timestamp;
        final DateTime dateTimeStart = timestampStart.toDate();

        var timeStart = new DateTime(dateTimeStart.year, dateTimeStart.month,
            dateTimeStart.day, dateTimeStart.hour, dateTimeStart.minute);

        DateTime dateOver_7 =
            DateTime.parse("${DateFormat('yyyy-MM-dd').format(timeStart)} 07");

        DateTime dateOver_15 =
            DateTime.parse("${DateFormat('yyyy-MM-dd').format(timeStart)} 15");

        setState(() {
          if ('admin' != data['post']) {
            if (timeStart.hour >= dateOver_7.hour && timeStart.hour < 15) {
              if (timeStart.minute <= 10) {
                if (timeStart.minute >= 1) {
                  listFine.add(FineModel(
                      name: data['name'],
                      post: data['post'],
                      lateness: timeStart.minute,
                      time: data['startDate'],
                      money_fine: 50,
                      id_user: data['id_user'],
                      id_post: '',
                      change: 1));
                }
              } else if (timeStart.minute <= 20) {
                listFine.add(FineModel(
                    name: data['name'],
                    post: data['post'],
                    lateness: timeStart.minute,
                    time: data['startDate'],
                    money_fine: 150,
                    id_user: data['id_user'],
                    id_post: '',
                    change: 1));
              } else if (timeStart.minute <= 30) {
                listFine.add(FineModel(
                    name: data['name'],
                    post: data['post'],
                    lateness: timeStart.minute,
                    time: data['startDate'],
                    money_fine: 250,
                    id_user: data['id_user'],
                    id_post: '',
                    change: 1));
              } else if (timeStart.minute <= 45) {
                listFine.add(FineModel(
                    name: data['name'],
                    post: data['post'],
                    lateness: timeStart.minute,
                    time: data['startDate'],
                    money_fine: 400,
                    id_user: data['id_user'],
                    id_post: '',
                    change: 1));
              } else if (timeStart.minute <= 60) {
                listFine.add(FineModel(
                    name: data['name'],
                    post: data['post'],
                    lateness: timeStart.minute,
                    time: data['startDate'],
                    money_fine: 500,
                    id_user: data['id_user'],
                    id_post: '',
                    change: 1));
              }

              if (getDataTime(dateOver_7, timeStart) > 60) {
                if (data['endDate'] != "") {
                  listFine.add(FineModel(
                      name: data['name'],
                      post: data['post'],
                      lateness: getDataTime(dateOver_7, timeStart),
                      time: data['startDate'],
                      money_fine: 600,
                      id_user: data['id_user'],
                      id_post: '',
                      change: 1));
                } else {
                  // listFine.add(FineModel(
                  //     name: data['name'],
                  //     post: data['post'],
                  //     lateness: getDataTime(dateOver_7, DateTime.now()),
                  //     time: data['startDate'],
                  //     money_fine: 600,
                  //     id_user: data['id_user'],
                  //     id_post: '',
                  //     change: 1));
                }
              }
            }

            // 15
            if (timeStart.hour >= dateOver_15.hour && timeStart.hour < 23) {
              if (timeStart.minute <= 10) {
                if (timeStart.minute >= 1) {
                  listFine.add(FineModel(
                      name: data['name'],
                      post: data['post'],
                      lateness: timeStart.minute,
                      time: data['startDate'],
                      money_fine: 50,
                      id_user: data['id_user'],
                      id_post: '',
                      change: 2));
                }
              } else if (timeStart.minute <= 20) {
                listFine.add(FineModel(
                    name: data['name'],
                    post: data['post'],
                    lateness: timeStart.minute,
                    time: data['startDate'],
                    money_fine: 150,
                    id_user: data['id_user'],
                    id_post: '',
                    change: 2));
              } else if (timeStart.minute <= 30) {
                listFine.add(FineModel(
                    name: data['name'],
                    post: data['post'],
                    lateness: timeStart.minute,
                    time: data['startDate'],
                    money_fine: 250,
                    id_user: data['id_user'],
                    id_post: '',
                    change: 2));
              } else if (timeStart.minute <= 45) {
                listFine.add(FineModel(
                    name: data['name'],
                    post: data['post'],
                    lateness: timeStart.minute,
                    time: data['startDate'],
                    money_fine: 400,
                    id_user: data['id_user'],
                    id_post: '',
                    change: 2));
              } else if (timeStart.minute <= 60) {
                listFine.add(FineModel(
                    name: data['name'],
                    post: data['post'],
                    lateness: timeStart.minute,
                    time: data['startDate'],
                    money_fine: 500,
                    id_user: data['id_user'],
                    id_post: '',
                    change: 2));
              }

              if (getDataTime(dateOver_15, timeStart) > 60) {
                if (data['endDate'] != "") {
                  listFine.add(FineModel(
                      name: data['name'],
                      post: data['post'],
                      lateness: getDataTime(dateOver_15, timeStart),
                      time: data['startDate'],
                      money_fine: 600,
                      id_user: data['id_user'],
                      id_post: '',
                      change: 2));
                }
              }
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

        setState(() {
          isEmpty = false;

          listFineFullDownloaded.add(FineModel(
              name: data['name'],
              post: data['post'],
              lateness: data['lateness'],
              time: data['time'],
              money_fine: data['money_fine'],
              id_user: data['id_user'],
              id_post: data['id_post'],
              change: data['change']));
        });
      });
    });

    if (isEmpty) {
      listFine.forEach((element) async {
        final dockFine =
            await FirebaseFirestore.instance.collection('Fine').doc();

        final json = {
          'name': element.name,
          'post': element.post,
          'id_user': element.id_user,
          'id_post': dockFine.id,
          'lateness': element.lateness,
          'change': element.change,
          'time': element.time,
          'money_fine': element.money_fine,
        };
        dockFine.set(json);
      });
    } else {
      listFine.forEach((elementMain) {
        final DateTime dateTimeStartMain = elementMain.time.toDate();
        var timeStartMain = new DateTime(
          dateTimeStartMain.year,
          dateTimeStartMain.month,
          dateTimeStartMain.day,
        );

        listFineFullDownloaded.forEach((element) {
          final DateTime dateTimeStart = element.time.toDate();
          var timeStart = new DateTime(
            dateTimeStart.year,
            dateTimeStart.month,
            dateTimeStart.day,
          );

          if (timeStartMain == timeStart &&
              element.lateness == elementMain.lateness &&
              element.id_user == elementMain.id_user) {
            elementMain.id_post = element.id_post;
          }
        });
      });

      Future.delayed(const Duration(milliseconds: 1300), () {
        listFine.forEach((element) async {
          if (element.id_post == '') {
            final dockFine =
                await FirebaseFirestore.instance.collection('Fine').doc();

            final json = {
              'name': element.name,
              'id_user': element.id_user,
              'id_post': dockFine.id,
              'change': element.change,
              'lateness': element.lateness,
              'post': element.post,
              'time': element.time,
              'money_fine': element.money_fine,
            };
            dockFine.set(json);
          }
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
        isVisiblyProgress = true;
        readFirebase();
      });
    }
  }

  void readFirebase() async {
    listFineComplete.clear();
    listFineFull.clear();

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

        if (post != null) {
          if (post == data['post']) {
            if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
              setState(() {
                listFineFull.add(FineModel(
                    post: data['post'],
                    name: data['name'],
                    lateness: data['lateness'],
                    time: data['time'],
                    money_fine: data['money_fine'],
                    id_user: data['id_user'],
                    id_post: 'id_post',
                    change: data['change']));

                var isExistMoney = listFineComplete.indexWhere(
                    (element) => element.id_user == (data['id_user']));

                if (isExistMoney < 0) {
                  listFineComplete.add(FineModel(
                      post: data['post'],
                      name: data['name'],
                      lateness: data['lateness'],
                      time: data['time'],
                      money_fine: data['money_fine'],
                      id_user: data['id_user'],
                      id_post: 'id_post',
                      change: data['change']));
                } else {
                  int valuer = data['lateness'];
                  listFineComplete[isExistMoney].money_fine +=
                      data['money_fine'];
                  listFineComplete[isExistMoney].lateness += valuer;
                }
              });
            }
          }
        }

        if (post == null) {
          if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
            setState(() {
              listFineFull.add(FineModel(
                  post: data['post'],
                  name: data['name'],
                  lateness: data['lateness'],
                  time: data['time'],
                  money_fine: data['money_fine'],
                  id_user: data['id_user'],
                  id_post: 'id_post',
                  change: data['change']));

              var isExistMoney = listFineComplete.indexWhere(
                  (element) => element.id_user == (data['id_user']));

              if (isExistMoney < 0) {
                listFineComplete.add(FineModel(
                    post: data['post'],
                    name: data['name'],
                    lateness: data['lateness'],
                    time: data['time'],
                    money_fine: data['money_fine'],
                    id_user: data['id_user'],
                    id_post: 'id_post',
                    change: data['change']));
              } else {
                int valuer = data['lateness'];
                listFineComplete[isExistMoney].money_fine += data['money_fine'];
                listFineComplete[isExistMoney].lateness += valuer;
              }
            });
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
    calculationFine();
  }

  @override
  Widget build(BuildContext context) {
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
        _getTitleItemWidget('Штраф', 100),
        _getTitleItemWidget('Дата', 120),
        _getTitleItemWidget('Смена', 100),
        _getTitleItemWidget('Подробней', 100),
      ];
    }

    Widget _generateFirstColumnRow(BuildContext context, int index) {
      return Container(
        child: Text(listFineFull[index].name,
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
            child: Text(
              '${printDurationTime(Duration(minutes: listFineFull[index].lateness))}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${listFineFull[index].money_fine.toString()}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${getData(listFineFull[index].time)}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 120,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${listFineFull[index].change.toString()}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 80,
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
                              id_user: listFineFull[index].id_user,
                          timeStart: listFineFull[index].time,
                            )));
              },
              child: Text('Подробней'),
            ),
            width: 140,
            height: 30,
            padding: EdgeInsets.only(left: 10),
          ),
        ],
      );
    }

    Widget _generateRightHandSideColumnRowFull(
        BuildContext context, int index) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
              '${printDurationTime(Duration(minutes: listFineComplete[index].lateness))}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${listFineComplete[index].money_fine.toString()}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${getData(listFineComplete[index].time)}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${listFineComplete[index].change.toString()}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 100,
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
                              id_user: listFineComplete[index].id_user,
                          timeStart: listFineComplete[index].time,
                            )));
              },
              child: Text('Подробней'),
            ),
            width: 140,
            height: 30,
            padding: EdgeInsets.only(left: 10),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: color_main_black,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20),
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (listFineFull.length != 0)
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
              if (listFineFull.length == 0)
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
              if (listFineFull.length != 0)
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
                    itemCount: listFineFull.length,
                    rowSeparatorWidget: const Divider(
                      color: Colors.black54,
                      height: 1.0,
                      thickness: 0.0,
                    ),
                  ),
                ),
              if (listFineComplete.length != 0)
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
                        headerWidgets: _getTitleWidget(),
                        leftSideItemBuilder: _generateFirstColumnRow,
                        rightSideItemBuilder:
                            _generateRightHandSideColumnRowFull,
                        itemCount: listFineComplete.length,
                        rowSeparatorWidget: const Divider(
                          color: Colors.black54,
                          height: 1.0,
                          thickness: 0.0,
                        ),
                      ),
                    ),
                  ],
                ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 6, top: 10),
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
            ],
          ),
        ),
      ),
    );
  }
}
