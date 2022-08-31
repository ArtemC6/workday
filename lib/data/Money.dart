import 'package:cloud_firestore/cloud_firestore.dart';

class MoneyModel {
  String name;
  Timestamp extraditionMoney;
  int workTime = 0;
  double money;
  String id_user;
  String id_post;

  MoneyModel(
      {required this.name,
      required this.extraditionMoney,
      required this.workTime,
      required this.money,
      required this.id_user,
      required this.id_post});
}
