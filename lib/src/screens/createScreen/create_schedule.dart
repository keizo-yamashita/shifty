import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/screens/createScreen/input_time_division.dart';
import 'package:shift/src/screens/createScreen/make_rules.dart';
import 'package:shift/src/screens/createScreen/input_date_duration.dart';
import 'package:shift/src/screens/createScreen/check_shift_table.dart';

// シフト表の作成に必要な変数
ShiftTable _shiftTable = ShiftTable();
int _selectedIndex     = 0;

class CreateScheduleWidget extends StatefulWidget {
  const CreateScheduleWidget({Key? key}) : super(key: key);
  @override
  State<CreateScheduleWidget> createState() => CreateScheduleWidgetState();
}

class CreateScheduleWidgetState extends State<CreateScheduleWidget> {

  @override
  Widget build(BuildContext context) {

    var screenSize = MediaQuery.of(context).size;
    
    final screens = [
      InputTimeDivisions(shiftTable:    _shiftTable),
      InputAssignNum(shiftTable:        _shiftTable),
      InputDeadlineDuration(shiftTable: _shiftTable),
      CheckShiftTable(shiftTable:       _shiftTable),
    ];

    return Scaffold(
      //AppBar
      appBar: AppBar(
        title: Text("シフト表の作成",style: MyFont.headlineStyleGreen20),
        backgroundColor: MyFont.backGroundColor,
        foregroundColor: MyFont.primaryColor,
        bottomOpacity: 2.0,
        elevation: 2.0,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:  CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: screenSize.height/20),
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: screenSize.width * 0.6,
                maxWidth: screenSize.width * 1.0,
              ),
              child: screens[_selectedIndex], 
            ),
            SizedBox(height: screenSize.height / 20),
          ],
        ),
      ),
      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ]),
        child: BottomNavigationBar(
          backgroundColor: MyFont.backGroundColor,
          selectedItemColor: MyFont.primaryColor,
          unselectedItemColor: MyFont.hiddenColor,
          currentIndex: _selectedIndex,
          onTap: _onCreateScheduleItemTapped,
          iconSize: 30,
          selectedFontSize: 13,
          unselectedFontSize: 10,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.access_time_filled_sharp), label: 'STEP1'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt),               label: 'STEP2'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined),  label: 'STEP3'),
            BottomNavigationBarItem(icon: Icon(Icons.check),                    label: 'STEP4'),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  void _onCreateScheduleItemTapped(int index) {
    if(index != 0 && _shiftTable.timeDivs.isEmpty){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('STEP 1 : 入力エラー\n', style: TextStyle(color: Colors.red)),
            content: const Text('1つ以上の時間区分を入力してください'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.pop(context);
                  _selectedIndex = 0; 
                  setState(() {});
                },
              ),
            ],
          );
        },
      );
    }else{
      setState(() {});
      _selectedIndex = index;
    }
  }
}