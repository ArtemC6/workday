import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workday/screens/auth/signin_screen.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:workday/screens/statistics/users_detailed_informaiton_screen.dart';
import '../data/const.dart';
import '../data/user_model.dart';

class ExtraditionMoneyScreen extends StatefulWidget {
  var status;

  ExtraditionMoneyScreen({Key? key, @required this.status}) : super(key: key);

  @override
  State<ExtraditionMoneyScreen> createState() =>
      _ExtraditionScreenScreenState(status);
}

class _ExtraditionScreenScreenState extends State<ExtraditionMoneyScreen> {
  List<UserModel> listUser = [],
      listUserWork = [],
      listUserMoney = [],
      listWorkFull = [];
  ButtonState stateTextWithIcon = ButtonState.idle;
  String _sum = '0.0', _percent = '0', _work_price = '0';
  bool isEmpty = false;
  String status = '', statusName = '';
  double money = 0.0;
  DateTimeRange _datePeriod =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  _ExtraditionScreenScreenState(this.status);

  void calculation(List<UserModel> listWork, DateTimeRange datePeriod) async {
    listUserMoney.clear();
    final dockUsers = FirebaseFirestore.instance.collection('Work');
    listWork.forEach((element) {
      final json = {
        'money': double.parse(element.money.toStringAsFixed(1)),
        'workTime': element.workTime,
        'extraditionMoney': DateTime.now(),
      };
      dockUsers.doc(element.id_post).update(json);
    });

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

        if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
          if (data['endDate'] != '') {
            if (data['money'] != '0.0') {
              var isExistMoney = listUserMoney.indexWhere(
                  (element) => element.id_user == (data['id_user']));

              if (isExistMoney < 0) {
                listUserMoney.add(UserModel(
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
                listUserMoney[isExistMoney].money += data['money'];
                listUserMoney[isExistMoney].workTime +=
                    getUserWorkTime(data['startDate'], data['endDate']);
              }
            }
          }
        }
      });
    });

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

        DateTime start = _datePeriod.start;
        DateTime end = _datePeriod.end;

        start = start.subtract(Duration(seconds: 1));
        end = end.add(Duration(days: 1));
        end = end.subtract(Duration(seconds: 1));

        if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
          final dockUsers =
              await FirebaseFirestore.instance.collection('Money');
          dockUsers.doc(document.id).delete();
        } else {
          setState(() {
            isEmpty = false;
          });
        }
      });
    });

    if (!isEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        listUserMoney.forEach((element) {
          if (element.money != 0.0) {
            final dockMoney =
                FirebaseFirestore.instance.collection('Money').doc();
            final json = {
              'money': double.parse(element.money.toStringAsFixed(1)),
              'money_full': double.parse(_sum),
              'name': element.name,
              'id_user': element.id_user,
              'id_post': dockMoney.id,
              'workTime': element.workTime,
              'extraditionMoney': element.startDate,
              'post': element.status,
            };
            dockMoney.set(json);
          }
        });
      });

      if (listUserWork.length != 0) {
        setState(() {
          stateTextWithIcon = ButtonState.success;
        });
      } else {
        setState(() {
          stateTextWithIcon = ButtonState.fail;
        });
      }
    }
  }

  void listEntry(Map<String, dynamic> data) {
    listUserWork.add(UserModel(
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
        workTime: getUserWorkTime(data["startDate"], data["endDate"])));
    setState(() {});

    listWorkFull.add(UserModel(
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
        workTime: getUserWorkTime(data["startDate"], data["endDate"])));
    setState(() {});

    var isExist =
        listUser.indexWhere((element) => element.id_user == (data['id_user']));

    if (isExist < 0) {
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
          workTime: getUserWorkTime(data["startDate"], data["endDate"])));
      setState(() {});
    } else {
      listUser[isExist].workTime +=
          getUserWorkTime(data['startDate'], data['endDate']);
    }
  }

  void readFirebase() async {
    listUser.clear();
    listUserWork.clear();

    setState(() {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.push(context, Scale_Transition(SignInScreen()));
      }
    });

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

        if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
          if (data['endDate'] != '') {
            if (data['post'] == status) {
              listEntry(data);
            }
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    statusName = getName(status);
  }

  List<UserModel> getTotalTime(List<UserModel> users, double sum) {
    int totalTime = 0;

    users.forEach((user) {
      totalTime += user.workTime;
    });

    if (status == 'barista') {
      users.forEach((user) {
        user.money = user.workTime / totalTime * sum;
      });
    } else {
      users.forEach((user) {
        double time = double.parse((user.workTime / 60).toStringAsFixed(1));
        user.money = time * sum;
      });
    }

    return users;
  }

  void onPressedIconWithText() async {
    switch (stateTextWithIcon) {
      case ButtonState.idle:
        stateTextWithIcon = ButtonState.loading;

        if (money == 0) {
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              stateTextWithIcon = ButtonState.fail;
            });
          });
        } else {
          if (listWorkFull.length != 0) {
            calculation(getTotalTime(listWorkFull, money), _datePeriod);
          }
        }

        break;
      case ButtonState.loading:
        break;

      case ButtonState.success:
        stateTextWithIcon = ButtonState.idle;
        break;

      case ButtonState.fail:
        stateTextWithIcon = ButtonState.idle;
        break;
    }
    setState(() {
      stateTextWithIcon = stateTextWithIcon;
    });
  }

  Widget buildButton() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      padding: EdgeInsets.only(top: 20, bottom: 50),
      child: ProgressButton.icon(iconedButtons: {
        ButtonState.idle: IconedButton(
            text: "Выдать",
            icon: Icon(Icons.send, color: Colors.white),
            color: Colors.blueAccent),
        ButtonState.loading:
            IconedButton(text: "Загрузка...", color: Colors.blue),
        ButtonState.fail: IconedButton(
            text: "Ошибка",
            icon: Icon(Icons.cancel, color: Colors.white),
            color: Colors.red.shade300),
        ButtonState.success: IconedButton(
            text: "Успешно",
            icon: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            color: Colors.green.shade400)
      }, onPressed: onPressedIconWithText, state: stateTextWithIcon),
    );
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    if (status == 'barista') {
      double percent = double.parse(_percent) / 100;
      money = double.parse(_sum) * percent;
    } else {
      money = double.parse(_work_price);
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
        _getTitleItemWidget('Имя', 120),
        _getTitleItemWidget('Время', 120),
        _getTitleItemWidget('Сумма', 120),
        _getTitleItemWidget('Дата', 110),
        _getTitleItemWidget('Подробней', 100),
      ];
    }

    Widget _generateFirstColumnRow(BuildContext context, int index) {
      return Container(
        child: Text(
          listUser[index].name,
          style: TextStyle(color: Colors.white),
        ),
        width: 100,
        height: 52,
        padding: EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
      );
    }

    Widget _generateRightHandSideColumnRow(BuildContext context, int index) {

      return InkWell(
        onLongPress: () {
          listWorkFull.clear();
          setState(() {
            listUser.removeAt(index);
            listUser.forEach((elementMain) {
              getTotalTime(listUserWork, money).forEach((element) {
                if (elementMain.id_user == element.id_user) {
                  listWorkFull.add(element);
                }
              });
            });
          });
        },
        child: Row(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  '${printDurationTime(Duration(minutes: listUser[index].workTime))} минут ',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                )),
            Container(
              padding: EdgeInsets.only(left: 44),
              child: Text(
                "${getTotalTime(listUser, money)[index].money.toStringAsFixed(1)} сом",
                style: TextStyle(color: Colors.white),
              ),
              width: 120,
              height: 52,
              alignment: Alignment.centerLeft,
            ),
            Container(
              padding: EdgeInsets.only(left: 40),
              child: Text(
                "${getData(listUser[index].startDate)}",
                style: TextStyle(color: Colors.white),
              ),
              width: 150,
              height: 52,
              // padding: EdgeInsets.only(left: 10),
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
                                timeStart: _datePeriod.start,
                                timeEnd: _datePeriod.end,
                              )));
                },
                child: Text(
                  'Подробней',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              width: 140,
              height: 30,
              padding: EdgeInsets.only(left: 10),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: color_main_black,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${statusName}",
                  style: TextStyle(fontSize: 22, color: Colors.white)),
              Container(
                height: MediaQuery.of(context).size.height / 1.9,
                child: HorizontalDataTable(
                  rightHandSideColBackgroundColor: color_main_black,
                  leftHandSideColBackgroundColor: color_main_black,
                  leftHandSideColumnWidth: 100,
                  rightHandSideColumnWidth: 600,
                  isFixedHeader: true,
                  headerWidgets: _getTitleWidget(),
                  leftSideItemBuilder: _generateFirstColumnRow,
                  rightSideItemBuilder: _generateRightHandSideColumnRow,
                  itemCount: listUser.length,
                  rowSeparatorWidget: const Divider(
                    // color: Colors.black54,
                    height: 1.0,
                    thickness: 0.0,
                  ),
                ),
              ),
              if (_datePeriod.end.hour !=
                  DateTimeRange(start: DateTime.now(), end: DateTime.now())
                      .end
                      .hour)
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                  child: Text(
                    ' С ${getDataPeriod(_datePeriod.start)} до ${getDataPeriod(_datePeriod.end)}',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              Container(
                padding: EdgeInsets.only(
                    top: 10, left: _width / 20, right: _width / 20, bottom: 10),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent,
                    ),
                    onPressed: () {
                      _showDataTimeRange();
                    },
                    child: Text('Выбрать дни оплаты',
                        style: TextStyle(color: Colors.white))),
              ),
              if (status == 'barista')
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.only(
                          top: 20,
                          left: _width / 20,
                          right: _width / 20,
                          bottom: 20),
                      child: TextFormField(
                        decoration: InputDecoration(
                          // hintText: 'Ведите выручку',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 2.0),
                          ),

                          hintMaxLines: 1,
                          hintText: 'Ведите вырочку',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            try {
                              final text = newValue.text;
                              if (text.isNotEmpty) double.parse(text);
                              return newValue;
                            } catch (e) {}
                            return oldValue;
                          }),
                        ],
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Постое поле';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            if (value.length >= 1) {
                              _sum = value;
                            }
                          });
                        },
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: TextFormField(
                        decoration: InputDecoration(
                          // hintText: 'Ведите выручку',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 2.0),
                          ),

                          hintMaxLines: 1,
                          hintText: 'Ведите процент',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            try {
                              final text = newValue.text;
                              if (text.isNotEmpty) double.parse(text);
                              return newValue;
                            } catch (e) {}
                            return oldValue;
                          }),
                        ],
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Постое поле';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            if (value.length >= 1) {
                              _percent = value;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              if (status != 'barista')
                Container(
                  width: MediaQuery.of(context).size.width / 1,
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                  child: TextFormField(
                    decoration: InputDecoration(
                      // hintText: 'Ведите выручку',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide:
                            BorderSide(color: Colors.blueAccent, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide:
                            BorderSide(color: Colors.blueAccent, width: 2.0),
                      ),

                      hintMaxLines: 1,
                      hintText: 'Ведите час работы',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        try {
                          final text = newValue.text;
                          if (text.isNotEmpty) double.parse(text);
                          return newValue;
                        } catch (e) {}
                        return oldValue;
                      }),
                    ],
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Постое поле';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        if (value.length >= 1) {
                          _work_price = value;
                        }
                      });
                    },
                  ),
                ),
              buildButton(),
            ],
          ),
        ),
      ),
    );
  }
}
