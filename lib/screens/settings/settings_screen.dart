import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workday/screens/employee_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../data/const.dart';
import '../../data/user_model.dart';
import '../administrator_screen.dart';
import '../auth/signin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  final formKey = GlobalKey<FormState>();
  List<UserModel> listUser = [], listUserWork = [], listUserMoney = [];
  List<_SalesData> dataUser = [];
  String _name = '', _post = '', _postMain = '';
  bool isVisible = false, isBoss = false;
  var timeBarista = 0.0,
      timeAdministrator = 0.0,
      timeMaid = 0.0,
      timeConcierge = 0.0,
      timeCookWork = 0.0,
      timeCook = 0.0;

  showAlertDialogSettingUser(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: color_main_black,
      content: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(
          top: 20,
        ),
        child: TextFormField(
          controller: TextEditingController(text: _name),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Colors.blueAccent, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
            ),
            hintMaxLines: 1,
            hintText: 'Имя',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(.5),
            ),
          ),
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
            setState(() async {
              if (value.length >= 3) {
                _name = value;

                if (formKey.currentState!.validate()) {
                  final dockUsers =
                      await FirebaseFirestore.instance.collection('User');

                  final json = {
                    'name': _name,
                  };
                  dockUsers
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .update(json);
                }
              }
            });
          },
        ),
      ),
      actions: [
        Container(
          padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Сохранить',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void readFirebase() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          _name = documentSnapshot['name'];
          _postMain = documentSnapshot['post'];

          if (documentSnapshot['post'] == 'barista') {
            _post = 'Бариста';
          } else if (documentSnapshot['post'] == 'admin') {
            _post = 'Администратор';
          } else if (documentSnapshot['post'] == 'boss') {
            isBoss = true;
            _post = 'Руководитель';
          } else if (documentSnapshot['post'] == 'cook') {
            _post = 'Повор';
          } else if (documentSnapshot['post'] == 'trainee') {
            _post = 'Стажёр';
          } else if (documentSnapshot['post'] == 'maid') {
            _post = 'Горничная';
          } else if (documentSnapshot['post'] == 'confectioner') {
            _post = 'Кондитер';
          } else if (documentSnapshot['post'] == 'chef-cook') {
            _post = 'Шеф-Повор';
          } else if (documentSnapshot['post'] == 'sous-chef') {
            _post = 'Су-Шеф';
          } else if (documentSnapshot['post'] == 'concierge') {
            _post = 'Консьерж';
          } else if (documentSnapshot['post'] == 'workers-cook') {
            _post = 'Кух-работники';
          } else {
            _post = 'Произошла ошибка';
          }
        });
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

        DateTime currentDate = DateTime.now();
        var currentTimeDay = new DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day - 7,
        );

        DateTime start = currentTimeDay;
        DateTime end = timeStart;

        start = start.subtract(Duration(seconds: 1));
        end = end.add(Duration(days: 1));
        end = end.subtract(Duration(seconds: 1));

        if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
          setState(() {
            if (data['post'] == 'barista') {
              print(getUserWorkTime(data["startDate"], data['endDate']));
              timeBarista +=
                  getUserWorkTime(data["startDate"], data['endDate']);
            } else if (data['post'] == 'admin') {
              timeAdministrator +=
                  getUserWorkTime(data["startDate"], data['endDate']);
            } else if (data['post'] == 'cook') {
              timeCook += getUserWorkTime(data["startDate"], data['endDate']);
            } else if (data['post'] == 'maid') {
              timeMaid += getUserWorkTime(data["startDate"], data['endDate']);
            } else if (data['post'] == 'concierge') {
              timeConcierge +=
                  getUserWorkTime(data["startDate"], data['endDate']);
            } else if (data['post'] == 'chef-cook') {
              timeCookWork +=
                  getUserWorkTime(data["startDate"], data['endDate']);
            } else if (data['post'] == 'sous-chef') {
              timeCookWork +=
                  getUserWorkTime(data["startDate"], data['endDate']);
            } else if (data['post'] == 'confectioner') {
              timeCookWork +=
                  getUserWorkTime(data["startDate"], data['endDate']);
            }
          });
        }
      });
    });

    dataUser.add(_SalesData(timeBarista, 'Бармены'));
    dataUser.add(_SalesData(timeCook, 'Повора'));
    dataUser.add(_SalesData(timeAdministrator, 'Администраторы'));
    dataUser.add(_SalesData(timeMaid, 'Горничные'));
    dataUser.add(_SalesData(timeConcierge, 'Консьерж'));
    dataUser.add(_SalesData(timeCookWork, 'Кух-работники'));

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        isVisible = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    readFirebase();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return await false;
      },
      child: Scaffold(
          backgroundColor: color_main_black,
          resizeToAvoidBottomInset: true,
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                if (isBoss) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              AdministratorScreen(
                                positionBottomNavigation: 3,
                              )));
                } else {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => EmployeeScreen(
                                positionBottomNavigation: 3,
                              )));
                }
              });
            },
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: color_main_black,
                  padding:
                      EdgeInsets.only(left: _width / 20, right: _width / 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Text(
                          _post,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // if (_postMain == 'boss')
                      if (isVisible)
                        Container(
                          height: MediaQuery.of(context).size.height / 2.0,
                          width: MediaQuery.of(context).size.width / 1.0,
                          child: SfCircularChart(
                              enableMultiSelection: true,
                              legend: Legend(
                                  overflowMode: LegendItemOverflowMode.wrap,
                                  width: '100%',
                                  textStyle: TextStyle(
                                      color: Colors.white, fontSize: 11),
                                  orientation: LegendItemOrientation.horizontal,
                                  isVisible: true,
                                  position: LegendPosition.bottom),
                              series: <PieSeries>[
                                PieSeries<_SalesData, String>(
                                    enableTooltip: true,
                                    dataSource: dataUser,
                                    xValueMapper: (_SalesData sales, _) =>
                                        sales.name,
                                    yValueMapper: (_SalesData sales, _) =>
                                        sales.time,
                                    dataLabelMapper: (_SalesData sales, _) =>
                                        (printDurationTime(Duration(
                                                minutes: sales.time.toInt())))
                                            .toString(),
                                    radius: '74%',
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      margin: EdgeInsets.zero,
                                      textStyle: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                      connectorLineSettings:
                                          ConnectorLineSettings(
                                              width: 1.5,
                                              type: ConnectorType.curve,
                                              length: '6%'),
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                    )),
                              ]),
                        ),
                      Container(
                        padding: EdgeInsets.only(
                            top: 30, left: _width / 18, right: _width / 18),
                        width: double.infinity,
                        child: TextButton(
                          // style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.white),
                          onPressed: () {
                            showAlertDialogSettingUser(context);
                          },
                          child: Text(
                            'Настройки',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                            left: _width / 14, right: _width / 14, top: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                          ),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            await Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => SignInScreen()));
                          },
                          child: Text(
                            'Выйти с аккаунта',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}

class _SalesData {
  final String name;
  final double time;

  _SalesData(this.time, this.name);
}
