import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workday/screens/administrator_screen.dart';
import 'package:workday/screens/extradition_money_screen.dart';

import '../data/const.dart';
import '../data/user_model.dart';
import 'statistics/users_detailed_informaiton_screen.dart';

class AnalyticScreen extends StatefulWidget {
  const AnalyticScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  List<UserModel> listUser = [], listUserWork = [], listUserMoney = [];
  bool isPosition = true, isEmpty = false;

  void readFirebase() async {
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
        var currentTime = new DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );

        if (timeStart == currentTime) {
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

            var isExist = listUser
                .indexWhere((element) => element.id_user == (data['id_user']));

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
                  workTime:
                      getUserWorkTime(data["startDate"], data["endDate"])));
              setState(() {});
            } else {
              listUser[isExist].workTime +=
                  getUserWorkTime(data['startDate'], data['endDate']);
            }
          }
        }
      });
    });
  }

  Widget _buildBottomSheet(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ExtraditionMoneyScreen(
                                status: 'barista',
                              )));
                },
                child: Text('Выдать барменам'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ExtraditionMoneyScreen(
                                status: 'maid',
                              )));
                },
                child: Text('Выдать горничным'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ExtraditionMoneyScreen(
                                status: 'concierge',
                              )));
                },
                child: Text('Выдать консьержу'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ExtraditionMoneyScreen(
                                status: 'admin',
                              )));
                },
                child: Text('Выдать администратору'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ExtraditionMoneyScreen(
                                status: 'chef-cook',
                              )));
                },
                child: Text('Выдать Шеф-Повору'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ExtraditionMoneyScreen(
                                status: 'sous-chef',
                              )));
                },
                child: Text('Выдать Сy-Шефу'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ExtraditionMoneyScreen(
                                status: 'confectioner',
                              )));
                },
                child: Text('Выдать Кондитеру'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ExtraditionMoneyScreen(
                                status: 'cook',
                              )));
                },
                child: Text('Выдать Поворам'),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ExtraditionMoneyScreen(
                                status: 'workers-cook',
                              )));
                },
                child: Text('Кух-работники'),
              ),
            ),
          ],
        ),
      ),
    );
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

    return Scaffold(
      backgroundColor: color_main_black,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => AdministratorScreen(
                          positionBottomNavigation: 1,
                        )));
          });
        },
        child: SingleChildScrollView(
          child: Container(
            color: color_main_black,
            height: _height,
            child: Column(
              children: [
                if (isPosition)
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 40, left: 14),
                      child: Text(
                        "Сегодня работали ${listUser.length.toString()}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                Container(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: listUser.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UsersDetailedInformationScreen(
                                          id_user: listUser[index].id_user,
                                        )));
                          },
                          child: Container(
                              child: ListTile(
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.white,
                            ),
                            title: Text(
                                "${listUser[index].name} ${printDurationTime(Duration(minutes: listUser[index].workTime))} минут ",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white)),
                          )),
                        );
                      }),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white,),
                    onPressed: () async {
                      showCupertinoModalBottomSheet(
                        topRadius: Radius.circular(30),
                        duration: Duration(milliseconds: 700),
                        backgroundColor: color_main_black,
                        context: context,
                        builder: (context) => _buildBottomSheet(context),
                      );
                    },
                    child: Text(
                      'Выдача',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
