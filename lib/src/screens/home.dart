import 'package:flutter/material.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/screens/createScreen/create_schedule.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);
  @override
  State<HomeWidget> createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {

  @override
  Widget build(BuildContext context) {

    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FloatingActionButton(
          foregroundColor: MyFont.backGroundColor,
          backgroundColor: MyFont.primaryColor,
          child: const Icon(Icons.add, size: 40),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateScheduleWidget()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.height/20),
              Text("登録されているシフト表はありません", style: MyFont.defaultStyleGrey15),
            ],
          ),
        ),
      )
    );
  }
}