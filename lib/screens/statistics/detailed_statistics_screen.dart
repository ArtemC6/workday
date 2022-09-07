import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:workday/screens/statistics/fine_screen.dart';
import 'package:workday/screens/statistics/money_information_screen.dart';
import 'package:workday/screens/statistics/user_information_period_screen.dart';

import '../../data/money_model.dart';
import '../../data/user_model.dart';
import 'information_users_screen.dart';

class DetailedStatics extends StatefulWidget {
  const DetailedStatics({Key? key}) : super(key: key);

  @override
  State<DetailedStatics> createState() => _DetailedStatics();
}

class _DetailedStatics extends State<DetailedStatics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text('Информация'),
      // ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MoneyInformationScreen()));
                          },
                          child: Text('Получить информацию о выдаче денег')),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        UserInformationPeriodScreen()));
                          },
                          child: Text('Получить информацию о сотрудниках')),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FineScreens()));
                          },
                          child: Text('Получить информацию о штрафах')),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Получить информацию о поварах')),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Получить информацию о кух.рабоника')),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Получить информацию о кондитере')),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Получить информацию о администраторе')),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Получить информацию о горничнох')),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Получить информацию о консьержах')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
