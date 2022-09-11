import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:workday/screens/auth/signin_screen.dart';
import 'package:intl/intl.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:workday/screens/settings/settings_screen.dart';
import 'package:workday/screens/statistics/information_users_screen.dart';

import '../data/const.dart';
import '../data/user_model.dart';
import '../data/variable.dart';
import 'analytics_screen.dart';
import 'statistics/detailed_statistics_screen.dart';

class AdministratorScreen extends StatefulWidget {
  var value;

  AdministratorScreen({Key? key, @required this.value}) : super(key: key);

  @override
  State<AdministratorScreen> createState() => _AdministratorScreenState(value);
}

class _AdministratorScreenState extends State<AdministratorScreen> {
  _AdministratorScreenState(this.value);

  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  List<UserModel> listUser = [], listUserWork = [];
  final formKey = GlobalKey<FormState>();
  double number = 0;
  var value;

  int _page = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String getData(Timestamp startDate) {
    final DateTime dateTimeStart = startDate.toDate();
    String formattedDate = DateFormat('kk:mm').format(dateTimeStart);
    return formattedDate;
  }

  void readFirebase() {
    setState(() {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.push(context, Scale_Transition(SignInScreen()));
      }
    });

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

        if (timeStart == currentTime) {
          if (data['endDate'] == '') {
            setState(() {
              var isExist = listUserWork.indexWhere(
                  (element) => element.id_user == (data['id_user']));

              if (isExist < 0) {
                listUserWork.add(UserModel(
                    name: data["name"],
                    email: data["email"],
                    status: data["post"],
                    startUri: data["startUri"],
                    endUri: '',
                    startDate: data["startDate"],
                    endDate: Timestamp.now(),
                    id_user: data["id_user"],
                    id_post: data["id_post"],
                    money: 0.0,
                    workTime:
                        getUserWorkTime(data["startDate"], Timestamp.now())));
              } else {
                listUserWork[isExist].workTime +=
                    getUserWorkTime(Timestamp.now(), Timestamp.now());
              }
            });
          }
        }

        if (timeStart == currentTime) {
          if (data['endDate'] != '') {

            print(data['name']);
            setState(() {
              var isExist = listUser.indexWhere(
                  (element) => element.id_user == (data['id_user']));

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
              } else {
                listUser[isExist].workTime += getUserWorkTime(
                    listUser[isExist].startDate, listUser[isExist].endDate);
              }
            });
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        if (value != null) {
          final CurvedNavigationBarState? navBarState =
              _bottomNavigationKey.currentState;
          navBarState?.setPage(value);
        }
      });
    });

    readFirebase();
  }

  @override
  Widget build(BuildContext context) {
    Widget administratorMain() {
      return SmartRefresher(

        onRefresh: () async {
          setState(() {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => AdministratorScreen()));
          });
        },
        controller: _refreshController,
        child: Container(
          color: color_main_black,
          height: MediaQuery.of(context).size.height,
          // padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 10, top: 50),
                alignment: Alignment.centerLeft,
                child: Text('Сегодня работали ${listUser.length.toString()}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
              ),
              Container(
                color: color_main_black,
                height: MediaQuery.of(context).size.height / 2.6,
                child: ListView.builder(
                  itemCount: listUser.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InformationUsersScreen(
                                        id_user: listUser[index].id_user,
                                      )));
                        },
                        child: ListTile(
                          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white,),
                          title: Text(
                              "${listUser[index].name} закончил(ла) ${getData(listUser[index].endDate)}",
                              style: TextStyle(fontSize: 17, color: Colors.white)),
                        ),
                      );
                    }),
              ),
              Container(
                padding: EdgeInsets.only(left: 10, top: 50),
                alignment: Alignment.centerLeft,
                child: Text(
                    'Сегодня работают ${listUserWork.length.toString()}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
              ),
              Container(
                color: color_main_black,
                height: MediaQuery.of(context).size.height / 2.6,
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: listUserWork.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InformationUsersScreen(
                                        id_user: listUserWork[index].id_user,
                                        time: listUserWork[index].startDate,
                                      )));
                        },
                        child: ListTile(
                          trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white,),
                          title: Text(
                              "${listUserWork[index].name} начал(ла) ${getData(listUserWork[index].startDate)}",
                              style:
                                  TextStyle(fontSize: 17, color: Colors.green)),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      );
    }

    Widget childAdministrator() {
      var child;
      switch (_page) {
        case 0:
          child = administratorMain();
          break;
        case 1:
          child = AnalyticScreen();
          break;
        case 2:
          child = DetailedStatics();
          break;
        case 3:
          child = SettingsScreen();
          break;
      }
      return child;
    }

    return WillPopScope(
      onWillPop: () async {
        return await false;
      },
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          height: 60.0,
          items: <Widget>[
            Icon(Icons.phone_android_rounded, size: 30),
            Icon(Icons.stacked_bar_chart_sharp, size: 30),
            Icon(Icons.list, size: 30),
            Icon(Icons.perm_identity, size: 30),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: color_main_black,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 700),
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
          letIndexChange: (index) => true,
        ),
        body: childAdministrator(),
      ),
    );
  }
}
