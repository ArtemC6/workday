import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  List<UserModel> listUser = [], listUserWork = [], listUserMoney = [];
  bool isPosition = false, isEmpty = false;

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
        var currentTimeDay = new DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day - 33,
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
                var isExistMoney = listUserWork.indexWhere(
                    (element) => element.id_user == (data['id_user']));

                if (isExistMoney < 0) {
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
                      money: data['money'],
                      workTime:
                          getUserWorkTime(data["startDate"], data["endDate"])));
                  setState(() {});
                } else {
                  listUserWork[isExistMoney].money += data['money'];

                  listUserWork[isExistMoney].workTime +=
                      getUserWorkTime(data['startDate'], data['endDate']);
                }
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
                          left: _width / 10,
                          right: _width / 10,
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
                                                UsersDetailedInformationScreen(
                                                  id_user: listUserWork[index]
                                                      .id_user,
                                                  time: listUserWork[index]
                                                      .startDate,
                                                  screens: 'notification',
                                                )));
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(top: 12, bottom: 12),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(34),
                                        child: Column(
                                          children: [
                                            Container(
                                              child: Text(
                                                ' Вы получили ${listUserWork[index].money} за ${getData(listUserWork[index].startDate)}',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                            )
                                          ],
                                        ),
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
