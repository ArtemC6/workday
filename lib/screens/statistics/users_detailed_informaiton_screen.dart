import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/const.dart';
import '../../data/user_model.dart';
import '../employee_screen.dart';

class UsersDetailedInformationScreen extends StatefulWidget {
  var id_user, time, screens;

  UsersDetailedInformationScreen(
      {Key? key,
      @required this.id_user,
      @required this.time,
      @required this.screens})
      : super(key: key);

  @override
  State<UsersDetailedInformationScreen> createState() =>
      _UsersDetailedInformationScreen(id_user, time, screens);
}

class _UsersDetailedInformationScreen
    extends State<UsersDetailedInformationScreen> {
  var idUser, time, screens;

  _UsersDetailedInformationScreen(this.idUser, this.time, this.screens);

  List<UserModel> listUser = [];
  bool isVisible = false;

  void _showPhotoFull(String uri) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return Scaffold(
        backgroundColor: color_main_black,
        body: Center(
          child: InteractiveViewer(child: Image.network(uri)),
        ),
      );
    }));
  }

  @override
  void initState() {
    super.initState();
    listUser.clear();
    FirebaseFirestore.instance
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
        var currentTime = new DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );

        if (idUser == data['id_user']) {
          if (timeStart == currentTime) {
            if (data['endDate'] == '') {
              listUser.add(UserModel(
                  name: data["name"],
                  email: data["email"],
                  status: data["post"],
                  startUri: data["startUri"],
                  endUri:
                      'https://media.baamboozle.com/uploads/images/59634/1591055175_32403',
                  startDate: data["startDate"],
                  endDate: data["startDate"],
                  id_user: data["id_user"],
                  id_post: data["id_post"],
                  money: 0.0,
                  workTime: 0));
              setState(() {});
            }
          }
        }

        if (idUser == data['id_user']) {
          if (timeStart == currentTime) {
            if (data['endDate'] != '') {
              if (time == null) {
                setState(() {
                  isVisible = false;
                });
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
                    workTime:
                        getUserWorkTime(data["startDate"], data["endDate"])));
                setState(() {});
              }
            }
          }

          if (time != null) {
            setState(() {
              isVisible = true;
            });

            final DateTime dateTimeStartCame = time.toDate();
            var timeStartCame = new DateTime(
              dateTimeStartCame.year,
              dateTimeStartCame.month,
              dateTimeStartCame.day,
            );

            if (timeStart == timeStartCame) {
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
            }
          }
        }
      });
    });
  }

  int getTotalTime(List<UserModel> users) {
    int number = 0;

    users.forEach((user) {
      number += user.workTime;
    });

    return number;
  }

  double getTotalMoney(List<UserModel> users) {
    double number = 0;

    users.forEach((user) {
      number += user.money;
    });

    return number;
  }

  getValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('key_price');
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
        _getTitleItemWidget('С', 100),
        _getTitleItemWidget('До', 100),
        _getTitleItemWidget('Время', 120),
        _getTitleItemWidget('Фото', 100),
      ];
    }

    List<Widget> _getTitleWidgetAnalytics() {
      return [
        _getTitleItemWidget('Имя', 100),
        _getTitleItemWidget('С', 94),
        _getTitleItemWidget('До', 100),
        _getTitleItemWidget('Время', 110),
        _getTitleItemWidget('Сумма', 140),
        _getTitleItemWidget('Фото', 100),
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
            child: Text(
              '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[0]} ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[1]} ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 100,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              '${printDurationTime(Duration(minutes: listUser[index].workTime))}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          Container(
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => new AlertDialog(
                    backgroundColor: color_main_black,
                    title: new Text(''),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showPhotoFull(listUser[index].startUri);
                            },
                            child: Container(
                              child: Image(
                                image: NetworkImage(listUser[index].startUri),
                                fit: BoxFit.fitWidth,
                              ),
                              height: MediaQuery.of(context).size.height / 2.8,
                              width: MediaQuery.of(context).size.width / 1,
                              padding: EdgeInsets.all(10),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _showPhotoFull(listUser[index].endUri);
                            },
                            child: Container(
                              child: Image(
                                image: NetworkImage(listUser[index].endUri),
                                fit: BoxFit.fitWidth,
                              ),
                              height: MediaQuery.of(context).size.height / 2.8,
                              width: MediaQuery.of(context).size.width / 1,
                              padding: EdgeInsets.all(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Свернуть'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Фото'),
            ),
            width: 120,
            height: 30,
            padding: EdgeInsets.only(left: 40),
          ),
        ],
      );
    }

    Widget _generateRightHandSideColumnRowAnalytics(
        BuildContext context, int index) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
              '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[0]} ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 90,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: Text(
              '${getUerWorkTimeDifference(listUser[index].startDate, listUser[index].endDate)[1]} ',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 90,
            height: 52,
            padding: EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
          ),
          Container(
              width: 90,
              padding: EdgeInsets.only(left: 20),
              child: Text(
                '${printDurationTime(Duration(minutes: listUser[index].workTime))}',
                style: TextStyle(fontSize: 16, color: Colors.white),
              )),
          Container(
            child: Text(
              '${listUser[index].money} сом',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            width: 124,
            height: 52,
            padding: EdgeInsets.only(left: 30),
            alignment: Alignment.centerLeft,
          ),
          Container(
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => new AlertDialog(
                    backgroundColor: color_main_black,
                    title: new Text(''),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              _showPhotoFull(listUser[index].startUri);
                            },
                            child: Container(
                              child: Image(
                                image: NetworkImage(listUser[index].startUri),
                                fit: BoxFit.fitWidth,
                              ),
                              height: MediaQuery.of(context).size.height / 2.8,
                              width: MediaQuery.of(context).size.width / 1,
                              padding: EdgeInsets.all(10),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              _showPhotoFull(listUser[index].endUri);
                            },
                            child: Container(
                              child: Image(
                                image: NetworkImage(listUser[index].endUri),
                                fit: BoxFit.fitWidth,
                              ),
                              height: MediaQuery.of(context).size.height / 2.8,
                              width: MediaQuery.of(context).size.width / 1,
                              padding: EdgeInsets.all(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Свернуть'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Фото'),
            ),
            width: 120,
            height: 30,
            padding: EdgeInsets.only(left: 40),
          ),
        ],
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (screens != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => EmployeeScreen(
                        positionBottomNavigation: 2,
                      )));
        }
        return await true;
      },
      child: Scaffold(
        backgroundColor: color_main_black,
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isVisible)
                  if (listUser.length != 0)
                    Container(
                        padding: EdgeInsets.only(left: 14, top: 20, right: 14),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          textAlign: TextAlign.center,
                          '${listUser[0].name}: отработал(ла) ${printDurationTime(Duration(minutes: getTotalTime(listUser)))} минут:  ${getData(listUser[0].startDate)}',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                if (isVisible)
                  if (listUser.length != 0)
                    Container(
                      padding: EdgeInsets.only(left: 14, top: 20),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            textAlign: TextAlign.center,
                            '${listUser[0].name}: ${printDurationTime(Duration(minutes: getTotalTime(listUser)))} минут',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Padding(padding: EdgeInsets.only(top: 8)),
                          Text(
                            textAlign: TextAlign.center,
                            'Получил: ${getTotalMoney(listUser).toString()} сом: за ${getData(listUser[0].startDate)}',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                if (!isVisible)
                  if (listUser.length != 0)
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      height: MediaQuery.of(context).size.height / 1.3,
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
                          color: Colors.black54,
                          height: 1.0,
                          thickness: 0.0,
                        ),
                      ),
                    ),
                if (isVisible)
                  if (listUser.length != 0)
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: HorizontalDataTable(
                        leftHandSideColBackgroundColor: color_main_black,
                        rightHandSideColBackgroundColor: color_main_black,
                        leftHandSideColumnWidth: 100,
                        rightHandSideColumnWidth: 600,
                        isFixedHeader: true,
                        headerWidgets: _getTitleWidgetAnalytics(),
                        leftSideItemBuilder: _generateFirstColumnRow,
                        rightSideItemBuilder:
                            _generateRightHandSideColumnRowAnalytics,
                        itemCount: listUser.length,
                        rowSeparatorWidget: const Divider(
                          color: Colors.black54,
                          height: 1.0,
                          thickness: 0.0,
                        ),
                      ),
                    ),
                Container(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      onPressed: () {
                        if (screens == null) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      EmployeeScreen(
                                        positionBottomNavigation: 2,
                                      )));
                        }
                      },
                      child: Text('Вернуться')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
