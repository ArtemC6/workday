import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String name;
  String email;
  String status;
  String startUri;
  String endUri;
  Timestamp startDate;
  Timestamp endDate;
  int workTime = 0;
  double money;
  String id_user;
  String id_post;

  UserModel(
      {required this.name,
      required this.email,
      required this.status,
      required this.startUri,
      required this.endUri,
      required this.startDate,
      required this.endDate,
      required this.workTime,
      required this.money,
      required this.id_user,
      required this.id_post});
}
