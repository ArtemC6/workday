import 'dart:async';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:workday/screens/notification/notification_screen.dart';
import 'package:workday/screens/settings/settings_screen.dart';
import 'package:workday/screens/statistics/user_information_screen.dart';
import '../data/const.dart';
import '../data/firedase_api.dart';
import '../data/user_model.dart';

class EmployeeScreen extends StatefulWidget {
  var positionBottomNavigation;

  EmployeeScreen({Key? key, @required this.positionBottomNavigation})
      : super(key: key);

  @override
  State<EmployeeScreen> createState() =>
      _EmployeeScreenState(positionBottomNavigation);
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  var positionBottomNavigation;

  _EmployeeScreenState(this.positionBottomNavigation);

  final ImagePicker _picker = ImagePicker();
  static var countdownDuration = Duration();
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  final DateTime nowDateTime = DateTime.now();
  Duration duration = Duration();

  Timer? timer;
  bool countDown = true,
      isVisible = false,
      isVisibleTimeEmployee = false,
      isVisibleTimeConcierge = false,
      isVisibleText = false,
      isAdmin = false,
      isConcierge = false;
  int _page = 0;
  UploadTask? task;
  File? startFilePhoto, endFilePhoto;
  List<UserModel> listUser = [];

  Future<bool> _onStop() async {
    final isRunning = timer == null ? false : timer!.isActive;
    if (isRunning) {
      timer!.cancel();
    }
    return true;
  }

  void reset() {
    if (countDown) {
      setState(() => duration = countdownDuration);
    } else {
      setState(() => duration = Duration());
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  Widget buildTime(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Container(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        buildTimeCard(time: hours, header: 'Часов'),
        buildTimeCard(time: minutes, header: 'Минут'),
        buildTimeCard(time: seconds, header: 'Секунд'),
      ]),
    );
  }

  Widget buildTimeCard({required String time, required String header}) =>
      Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Text(
              time,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 50),
            ),
          ),
          SizedBox(
            height: 26,
          ),
          Text(header, style: TextStyle(color: Colors.white)),
        ],
      );

  Future makeStartPhoto() async {
    final XFile? photo = await _picker.pickImage(
        imageQuality: 10,
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front);

    if (photo != null) {
      setState(() {
        startFilePhoto = File(photo.path);
      });
    }
  }

  Future makeEndPhoto() async {
    final XFile? photo = await _picker.pickImage(
        imageQuality: 10,
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front);

    if (photo != null) {
      setState(() {
        endFilePhoto = File(photo.path);
      });
    }
  }

  Future endWorking() async {
    if (endFilePhoto == null) return;

    final fileName = basename(endFilePhoto!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, endFilePhoto!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        await FirebaseFirestore.instance
            .collection('Work')
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((document) async {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            if (data['id_user'] == FirebaseAuth.instance.currentUser?.uid) {
              if (data['endDate'] == '') {
                final dockUsers =
                    await FirebaseFirestore.instance.collection('Work');

                final json = {
                  'endUri': urlDownload,
                  'endDate': DateTime.now(),
                };

                dockUsers.doc(document.id).update(json);
              }
            }
          });
        });
      }
    });
  }

  Future startWorking() async {
    if (startFilePhoto == null) return;

    final fileName = basename(startFilePhoto!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, startFilePhoto!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        Map<String, dynamic> doc =
            documentSnapshot.data() as Map<String, dynamic>;

        final dockUsers =
            await FirebaseFirestore.instance.collection('Work').doc();

        final json = {
          'name': doc['name'],
          'id_user': doc['uid'],
          'id_post': dockUsers.id,
          'email': doc['email'],
          'startUri': urlDownload,
          'startDate': DateTime.now(),
          'endUri': '',
          'endDate': '',
          'money': 0.0,
          'post': doc['post'],
        };

        dockUsers.set(json);
      }
    });
  }

  void readUserFirebase() async {
    listUser.clear();

    await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        setState(() {
          if (documentSnapshot['post'] == 'admin') {
            isAdmin = true;
          } else if (documentSnapshot['post'] == 'concierge') {
            isConcierge = true;
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
        var currentTime = new DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );

        if (data['id_user'] == FirebaseAuth.instance.currentUser?.uid) {
          if (timeStart == currentTime) {
            if (data['post'] != 'admin' || data['post'] != 'concierge') {
              if (data['endDate'] != '') {
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
                        workTime: getUserWorkTime(
                            data["startDate"], data["endDate"])));
                  } else {
                    listUser[isExist].workTime +=
                        getUserWorkTime(data['startDate'], data['endDate']);
                  }
                });
              }

              if (data['endDate'] == '') {
                setState(() {
                  isVisible = true;
                });

                countdownDuration = Duration(
                    seconds: int.parse(DateTime.now()
                        .difference(dateTimeStart)
                        .inSeconds
                        .toString()));

                reset();
                startTimer();
              }
            }
          }
        }

        if (data['id_user'] == FirebaseAuth.instance.currentUser?.uid) {
          if (data['post'] == 'admin') {
            if (timeStart == currentTime) {
              if (data['endDate'] != '') {
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
                        workTime: getUserWorkTime(
                            data["startDate"], data["endDate"])));
                  } else {
                    listUser[isExist].workTime +=
                        getUserWorkTime(data['startDate'], data['endDate']);
                  }
                });
              }

              if (data['endDate'] == '') {
                setState(() {
                  isVisible = true;
                });

                countdownDuration = Duration(
                    seconds: int.parse(DateTime.now()
                        .difference(dateTimeStart)
                        .inSeconds
                        .toString()));

                reset();
                startTimer();
              }
            }
          }
        }

        if (data['id_user'] == FirebaseAuth.instance.currentUser?.uid) {
          if (data['post'] == 'concierge') {
            if (data['endDate'] != '') {
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
                  listUser[isExist].workTime +=
                      getUserWorkTime(data['startDate'], data['endDate']);
                }
              });
            }

            if (data['endDate'] == '') {
              setState(() {
                isVisible = true;
              });

              countdownDuration = Duration(
                  seconds: int.parse(DateTime.now()
                      .difference(dateTimeStart)
                      .inSeconds
                      .toString()));

              reset();
              startTimer();
            }
          }
        }
      });
    });

    if (listUser.length != 0) {
      if (!isVisible) {
        // if (!isAdmin) {
        countdownDuration = Duration(minutes: listUser[0].workTime);
        reset();
        // }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      if (nowDateTime.hour >= 07 && nowDateTime.hour < 23) {
        isVisibleText = true;
      }
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        if (positionBottomNavigation != null) {
          final CurvedNavigationBarState? navBarState =
              _bottomNavigationKey.currentState;
          navBarState?.setPage(positionBottomNavigation);
        }
      });
    });

    readUserFirebase();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    Widget employeeMain() {
      return RefreshIndicator(
        edgeOffset: 20,
        color: Colors.black,
        onRefresh: () async {
          setState(() {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => EmployeeScreen()));
          });
        },
        child: SingleChildScrollView(
          child: Container(
            color: color_main_black,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(right: _width / 14, left: _width / 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: _height / 8),
                  child: buildTime(context),
                ),
                if (!isVisible)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      onPressed: () async {
                        // 07:23

                        if (!isConcierge) {
                          if (nowDateTime.hour >= 07 && nowDateTime.hour < 23) {
                            await makeStartPhoto();
                            showAlertDialogMy(context);

                            setState(() {
                              isVisible = !isVisible;
                              isVisibleTimeEmployee = false;
                            });

                            await startWorking();

                            setState(() {
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          new EmployeeScreen()));
                            });
                          } else {
                            setState(() {
                              isVisibleTimeEmployee = true;
                            });
                          }
                        }

                        if (isConcierge) {
                          // if (nowDateTime.hour >= 09) {
                          if (true) {
                            await makeStartPhoto();
                            showAlertDialogMy(context);

                            setState(() {
                              isVisible = !isVisible;
                              isVisibleTimeConcierge = false;
                            });

                            await startWorking();

                            setState(() {
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          new EmployeeScreen()));
                            });
                          } else {
                            setState(() {
                              isVisibleTimeConcierge = true;
                            });
                          }
                        }
                      },
                      child: AnimatedTextKit(
                        displayFullTextOnTap: true,
                        isRepeatingAnimation: true,
                        repeatForever: true,
                        stopPauseOnTap: true,
                        animatedTexts: [
                          ColorizeAnimatedText(
                            'Начать работу',
                            textStyle: TextStyle(fontSize: 17),
                            colors: [
                              Colors.black,
                              Colors.black54,
                              Colors.black87,
                              Colors.black,
                            ],
                          ),
                        ],
                        onTap: () {},
                      ),
                    ),
                  ),
                if (isVisible)
                  Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        onPressed: () async {
                          if (nowDateTime.hour >= 07 &&
                              nowDateTime.hour < 23 &&
                              !isConcierge) {
                            await makeEndPhoto();
                            showAlertDialogMy(context);

                            setState(() {
                              isVisible = !isVisible;
                              isVisibleTimeEmployee = false;
                            });

                            _onStop();
                            await endWorking();

                            setState(() {
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          new EmployeeScreen()));
                            });
                          } else {
                            setState(() {
                              isVisibleTimeEmployee = true;
                            });
                          }

                          if (isConcierge) {
                            await makeEndPhoto();
                            showAlertDialogMy(context);

                            setState(() {
                              isVisible = !isVisible;
                            });

                            _onStop();
                            await endWorking();

                            setState(() {
                              Navigator.pushReplacement(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          new EmployeeScreen()));
                            });
                          }
                        },
                        child: Text(
                          'Закончить работу',
                          style: TextStyle(color: Colors.black),
                        ),
                      )),
                if (!isVisibleTimeEmployee)
                  if (!isVisible)
                    if (isVisibleText)
                      Container(
                        padding: EdgeInsets.only(top: 30),
                        alignment: Alignment.center,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              textAlign: TextAlign.center,
                              'Пожалуйста начните работу...',
                              speed: Duration(milliseconds: 200),
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          isRepeatingAnimation: true,
                          repeatForever: true,
                          displayFullTextOnTap: true,
                          stopPauseOnTap: false,
                        ),
                      ),
                if (isVisibleTimeEmployee)
                  Container(
                    padding: EdgeInsets.only(top: 30, bottom: 20),
                    child: Text(
                      'Работу можно начать с 07: до 23:',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                if (isVisibleTimeConcierge)
                  Container(
                    padding: EdgeInsets.only(top: 30, bottom: 20),
                    child: Text(
                      'Работу можно начать с 09',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    Widget childEmployee() {
      var child;
      switch (_page) {
        case 0:
          child = employeeMain();
          break;
        case 1:
          child = UserInformationScreen(
              uid: FirebaseAuth.instance.currentUser!.uid);
          break;
        case 2:
          child = NotificationScreen();
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
        backgroundColor: color_main_black,
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          height: 60.0,
          items: <Widget>[
            Icon(Icons.access_time_outlined, size: 30),
            Icon(Icons.list, size: 30),
            Icon(Icons.notifications_none, size: 30),
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
        body: SizedBox.expand(child: childEmployee()),
      ),
    );
  }
}
