import 'package:cloud_firestore/cloud_firestore.dart';

class FineModel {
  String name;
  Timestamp time;
  int lateness;
  int change;
  double money_fine;
  String id_user;
  String id_post;

  FineModel(
      {required this.name,
        required this.lateness,
        required this.time,
        required this.change,
        required this.money_fine,
        required this.id_user,
        required this.id_post});
}
