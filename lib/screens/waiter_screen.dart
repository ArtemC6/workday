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
import 'package:workday/screens/signin_screen.dart';

import '../data/User.dart';
import '../data/firedase_api.dart';
import 'administrator_screen.dart';
import 'information_users_screen.dart';

class WaiterScreen extends StatefulWidget {
  const WaiterScreen({Key? key}) : super(key: key);

  @override
  State<WaiterScreen> createState() => _WaiterScreenState();
}

class _WaiterScreenState extends State<WaiterScreen> {
  final ImagePicker _picker = ImagePicker();
  static var countdownDuration = Duration(minutes: 10);
  Duration duration = Duration();
  Timer? timer;
  bool countDown = true;
  String _name = '';
  int _tame = 0;

  UploadTask? task;
  File? startFilePhoto;
  File? endFilePhoto;
  bool isVisible = false;
  bool isVisibleTime = false;
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

  Future makeStartPhoto() async {
    final XFile? photo = await _picker.pickImage(
        imageQuality: 10,
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear);

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
          'status': doc['status'],
        };

        dockUsers.set(json);
      }
    });
  }

  void readUserFirebase() async {
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
          setState(() {
            _name = data['name'];
          });
          if (timeStart == currentTime) {
            if (data['endDate'] != '') {
              var isExist = listUser.indexWhere(
                  (element) => element.id_user == (data['id_user']));

              if (isExist < 0) {
                listUser.add(UserModel(
                    name: data["name"],
                    email: data["email"],
                    status: data["status"],
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

            if (data['endDate'] == '') {
              setState(() {
                _tame = DateTime.now().difference(dateTimeStart).inMinutes;
                isVisible = true;
              });

              var hours;
              var mints;
              var secs;
              hours = int.parse(
                  DateTime.now().difference(dateTimeStart).inHours.toString());
              mints = int.parse(DateTime.now()
                  .difference(dateTimeStart)
                  .inMinutes
                  .toString());
              secs = int.parse(DateTime.now()
                  .difference(dateTimeStart)
                  .inSeconds
                  .toString());
              countdownDuration =
                  Duration(hours: hours, minutes: mints, seconds: secs);
              startTimer();
              reset();
            }
          }
        }
      });
    });

    if (listUser.length != 0) {
      if (!isVisible) {
        var hours;
        var mints;
        var secs;
        hours = int.parse('00');
        mints = listUser[0].workTime;
        secs = int.parse('00');
        countdownDuration =
            Duration(hours: hours, minutes: mints, seconds: secs);
        reset();
      } else {
        var hours;
        var mints;
        var secs;
        hours = int.parse('00');
        mints = listUser[0].workTime + _tame;
        secs = int.parse('00');
        countdownDuration =
            Duration(hours: hours, minutes: mints, seconds: secs);
        reset();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    readUserFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Сотрудник: ${_name}'),
        ),
        body: RefreshIndicator(
          edgeOffset: 20,
          color: Colors.black,
          onRefresh: () async {
            setState(() {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => WaiterScreen()));
            });
          },
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(right: 30, left: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 80),
                    child: buildTime(),
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdministratorScreen()));
                      },
                      child: Text('Администратор'),
                    ),
                  ),
                  if (!isVisible)
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime now = DateTime.now();
                          int formattedDate =
                              int.parse(DateFormat('kk').format(now));
                          // if (formattedDate >= 07 && formattedDate <= 23) {
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
                                          new WaiterScreen()));
                            });
                            // } else {
                            //   setState(() {
                            //     isVisibleTime = true;
                            //   });
                            // }
                        },
                        child: Text('Начать работу'),
                      ),
                    ),
                  if (isVisible)
                    Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            DateTime now = DateTime.now();
                            int formattedDate =
                                int.parse(DateFormat('kk').format(now));
                            // if (formattedDate >= 07 && formattedDate <= 23) {
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
                                          new WaiterScreen()));
                            });
                            // } else {
                            //   setState(() {
                            //     isVisibleTime = true;
                            //   });
                            // }
                          },
                          child: Text('Закончить работу'),
                        )),
                  if (listUser.length != 0)
                    Container(
                      padding: EdgeInsets.only(),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InformationUsersScreen(
                                        id_user: listUser[0].id_user,
                                      )));
                        },
                        child: Text('Информация'),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.only(),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SignInScreen()));
                      },
                      child: Text('Выйти'),
                    ),
                  ),
                  if (isVisibleTime)
                    Container(
                      padding: EdgeInsets.only(top: 30, bottom: 20),
                      child: Text(
                        'Работу можно начать с 07: до 23:',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
