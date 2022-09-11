import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Color color_main_black = Color(0xff212428);
final String name = '';

String getData(Timestamp startDate) {
  final DateTime dateTimeStart = startDate.toDate();
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTimeStart);
  return formattedDate;
}

int getUserWorkTime(Timestamp startDate, Timestamp endDate) {
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
