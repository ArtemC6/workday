import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Color color_main_black = Color(0xff212428);

String getName(String post) {
  String position = '';
  if ('barista' == post) {
    position = 'Бириста';
  } else if ('cook' == post) {
    position = 'Повор';
  } else if ('trainee' == post) {
    position = 'Стажёр';
  } else if ('maid' == post) {
    position = 'Горнечная';
  } else if ('Кондитер' == post) {
    position = 'Бириста';
  } else if ('sous-chef' == post) {
    position = 'Су-Шев';
  } else if ('chef-cook' == post) {
    position = 'Шеф-Повор';
  } else if ('confectioner' == post) {
    position = 'Кондитер';
  } else if ('concierge' == post) {
    position = 'Коньсьерж';
  } else if ('admin' == post) {
    position = 'Администратор';
  } else if ('workers-cook' == post) {
    position = 'Кух-работник';
  }
  return position;
}

String getDataPeriod(DateTime startDate) {
  String formattedDate = DateFormat('yyyy-MM-dd').format(startDate);
  return formattedDate;
}

String printDurationTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2);
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  return "${twoDigits(duration.inHours)} : $twoDigitMinutes";
}

String getData(Timestamp startDate) {
  final DateTime dateTimeStart = startDate.toDate();
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTimeStart);
  return formattedDate;
}

int getDataTime(DateTime startDate, DateTime endDate) {
  return endDate.difference(startDate).inMinutes;
}

int getUserWorkTime(Timestamp startDate, Timestamp endDate) {
  final DateTime dateTimeStart = startDate.toDate();
  final DateTime dateTimeEnd = endDate.toDate();
  return dateTimeEnd.difference(dateTimeStart).inMinutes;
}

getUserWorkTimeDouble(Timestamp startDate, Timestamp endDate) {
  final DateTime dateTimeStart = startDate.toDate();
  final DateTime dateTimeEnd = endDate.toDate();
  return dateTimeEnd.difference(dateTimeStart).inMinutes;
}

showAlertDialogMy(BuildContext context) {
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

class Scale_Transition extends PageRouteBuilder {
  final Widget page;

  Scale_Transition(this.page)
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: Duration(milliseconds: 1200),
          reverseTransitionDuration: Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
                curve: Curves.fastLinearToSlowEaseIn,
                parent: animation,
                reverseCurve: Curves.fastOutSlowIn);
            return ScaleTransition(
              alignment: Alignment.center,
              scale: animation,
              child: child,
            );
          },
        );
}

List<String> getUerWorkTimeDifference(Timestamp startDate, Timestamp endDate) {
  List<String> list = [];
  final DateTime dateTimeStart = startDate.toDate();
  final DateTime dateTimeEnd = endDate.toDate();

  String formattedDateStater = DateFormat('kk:mm').format(dateTimeStart);
  String formattedDateEnd = DateFormat('kk:mm').format(dateTimeEnd);
  list.add(formattedDateStater);
  list.add(formattedDateEnd);
  return list;
}
