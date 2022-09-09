import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workday/screens/auth/signin_screen.dart';
import 'package:workday/screens/settings/settings_screen.dart';
import 'package:workday/screens/statistics/user_information_period_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../data/user_model.dart';
import '../data/firedase_api.dart';
import 'package:animated_text_kit/animated_text_kit.dart';


class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final ImagePicker _picker = ImagePicker();
  static var countdownDuration = Duration();

  Duration duration = Duration();
  Timer? timer;
  bool countDown = true,
      isVisible = false,
      isVisibleTime = false,
      isVisibleText = false;
  String _name = '';
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

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      buildTimeCard(time: hours, header: 'Часов'),
      SizedBox(
        width: 16,
      ),
      buildTimeCard(time: minutes, header: 'Минут'),
      SizedBox(
        width: 16,
      ),
      buildTimeCard(time: seconds, header: 'Секунд'),
    ]);
  }

  Widget buildTimeCard({required String time, required String header}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
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
            height: 24,
          ),
          Text(header, style: TextStyle(color: Colors.black45)),
        ],
      );

  int getUserWorkTime(Timestamp startDate, Timestamp endDate) {
    final DateTime dateTimeStart = startDate.toDate();
    final DateTime dateTimeEnd = endDate.toDate();
    return dateTimeEnd.difference(dateTimeStart).inMinutes;
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        content: new Container(
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: const Color(0xFFFFFF),
        borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
      ),
      child: Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 18), child: Text("Загрузка...")),
        ],
      ),
    ));
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // void startCamera() async {
  //   cameras = await availableCameras();
  //
  //   cameraController = CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
  //
  //   await cameraController.initialize().then((value) {
  //     if(!mounted) {
  //       return;
  //     }
  //     setState(() {
  //
  //     });
  //   });
  // }

  Future makeStartPhoto() async {
    final XFile? photo = await _picker.pickImage(
        imageQuality: 9,
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
        imageQuality: 9,
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
          'status': doc['post'],
          'post': doc['post'],
        };

        dockUsers.set(json);
      }
    });
  }

  void readUserFirebase() async {
    listUser.clear();
    FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          _name = documentSnapshot['name'];
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

        setState(() {
          isVisibleText = true;
        });

        if (data['id_user'] == FirebaseAuth.instance.currentUser?.uid) {
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
        countdownDuration = Duration(minutes: listUser[0].workTime);
        reset();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // startCamera();
    readUserFirebase();
  }

  @override
  Widget build(BuildContext context) {
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
            color: Colors.blueAccent,
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(right: 30, left: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 100),
                  child: buildTime(),
                ),
                if (!isVisible)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      onPressed: () async {
                        DateTime now = DateTime.now();
                        int formattedDate =
                            int.parse(DateFormat('kk').format(now));
                        if (formattedDate >= 07 && formattedDate <= 23) {
                          isVisibleTime = false;
                          await makeStartPhoto();
                          showAlertDialog(context);

                          setState(() {
                            isVisible = !isVisible;
                            isVisibleTime = false;
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
                            isVisibleTime = true;
                          });
                        }
                      },
                      child: Text(
                        'Начать работу',
                        style: TextStyle(color: Colors.black),
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
                          DateTime now = DateTime.now();
                          int formattedDate =
                              int.parse(DateFormat('kk').format(now));
                          if (formattedDate >= 07 && formattedDate <= 23) {
                            await makeEndPhoto();
                            showAlertDialog(context);

                            setState(() {
                              isVisible = !isVisible;
                              isVisibleTime = false;
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
                              isVisibleTime = true;
                            });
                          }
                        },
                        child: Text(
                          'Закончить работу',
                          style: TextStyle(color: Colors.black),
                        ),
                      )),
                if (!isVisibleTime)
                  if (!isVisible)
                    if (isVisibleText)
                      Container(
                        padding: EdgeInsets.only(top: 20),
                        alignment: Alignment.center,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              textAlign: TextAlign.center,
                              'Пожалуйста начните работу...',
                              speed: Duration(milliseconds: 200),
                              textStyle: TextStyle(
                                fontSize: 22,
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
                if (isVisibleTime)
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
              ],
            ),
          ),
        ),
      );
    }

    //
    // Widget text() {
    //    {
    //     return
    //   }
    //   return Container(
    //   );
    // }

    Widget childEmployee() {
      var child;
      switch (_page) {
        case 0:
          child = employeeMain();
          break;
        case 1:
          child = UserInformationPeriodScreen(
              uid: FirebaseAuth.instance.currentUser!.uid);
          break;
        case 2:
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
          // key: _bottomNavigationKey,
          index: 0,
          height: 60.0,

          items: <Widget>[
            Icon(Icons.access_time_outlined, size: 30),
            Icon(Icons.list, size: 30),
            Icon(Icons.perm_identity, size: 30),
          ],

          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Colors.blueAccent,
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
