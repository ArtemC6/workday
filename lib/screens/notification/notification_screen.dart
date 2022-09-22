import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workday/data/money_model.dart';
import '../../data/const.dart';
import '../../data/user_model.dart';
import '../employee_screen.dart';
import '../statistics/users_detailed_informaiton_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreen();
}

class _NotificationScreen extends State<NotificationScreen> {
  List<MoneyModel> listUserWork = [];
  bool isPosition = false, isEmpty = false;

  void readFirebase() async {
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

        DateTime currentDate = DateTime.now();
        var currentTimeDay = new DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day - 60,
        );

        DateTime start = currentTimeDay;
        DateTime end = timeStart;

        start = start.subtract(Duration(seconds: 1));
        end = end.add(Duration(days: 1));
        end = end.subtract(Duration(seconds: 1));

        if (timeStart.isAfter(start) && timeStart.isBefore(end)) {
          if (FirebaseAuth.instance.currentUser?.uid == data['id_user']) {
            if (data['endDate'] != '') {
              if (data['money'] != 0.0) {
                listUserWork.add(MoneyModel(
                  extraditionMoneyCurrent: data['extraditionMoneyCurrent'],
                  name: data["name"],
                  extraditionMoney: data['extraditionMoney'],
                  workTime: data['workTime'],
                  id_user: data["id_user"],
                  id_post: data["id_post"],
                  money: data['money'],
                ));
              }
            }
          }
        }
      });
    });
    setState(() {
      isPosition = true;
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

    return Scaffold(
      backgroundColor: color_main_black,
      body: SingleChildScrollView(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => EmployeeScreen(
                            positionBottomNavigation: 2,
                          )));
            });
          },
          child: Container(
            child: Column(
              children: [
                Container(
                  padding:
                      EdgeInsets.only(top: _height / 16, left: 20, bottom: 10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Уведомление',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (isPosition)
                  Container(
                    height: _height,
                    child: AnimationLimiter(
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          top: _height / 28,
                          bottom: _height / 5.5,
                          left: _width / 14,
                          right: _width / 14,
                        ),
                        itemCount: listUserWork.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            delay: Duration(milliseconds: 170),
                            child: SlideAnimation(
                              duration: Duration(milliseconds: 3500),
                              curve: Curves.fastLinearToSlowEaseIn,
                              child: FadeInAnimation(
                                curve: Curves.fastLinearToSlowEaseIn,
                                duration: Duration(milliseconds: 3500),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                EmployeeScreen(
                                                  positionBottomNavigation: 1,
                                                )));
                                  },
                                  child: Container(
                                    height: _height / 5.5,
                                    width: _width / 1,
                                    padding:
                                        EdgeInsets.only(top: 12, bottom: 12),
                                    child: Card(
                                      color: Colors.white24,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 18, top: 20, right: 10),
                                        child: (Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      child: Image.asset(
                                                        'images/ic_green_dot.png',
                                                        height: 8,
                                                        width: 8,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Text(
                                                        ' Вы получили',
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 15),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10, bottom: 6),
                                                  child: Icon(
                                                    Icons.navigate_next_rounded,
                                                    color: Colors.white,
                                                  ),
                                                  // child: ,
                                                  height: 10,
                                                  width: 10,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(top: 14),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        top: 12),
                                                    child: Text(
                                                      ' ${getData(listUserWork[index].extraditionMoneyCurrent)}',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white38),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        child: Text(
                                                          '\$${listUserWork[index].money}',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 6),
                                                        child: Image.asset(
                                                          'images/Ic_green_performed.png',
                                                          height: 15,
                                                          width: 15,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
