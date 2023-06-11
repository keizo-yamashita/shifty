import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/screens/createScreen/screens/input_time_division.dart';
import 'package:shift/src/screens/createScreen/screens/input_rules.dart';
import 'package:shift/src/screens/createScreen/screens/input_date_duration.dart';
import 'package:shift/src/screens/createScreen/screens/register_shift_table.dart';

// シフト表の作成に必要な変数
ShiftTable _shiftTable = ShiftTable();
int _selectedIndex     = 0;

class CreateShiftTableWidget extends StatefulWidget {
  const CreateShiftTableWidget({Key? key}) : super(key: key);
  @override
  State<CreateShiftTableWidget> createState() => CreateShiftTableWidgetState();
}

class CreateShiftTableWidgetState extends State<CreateShiftTableWidget> {

  @override
  Widget build(BuildContext context) {
    
    final screens = [
      InputTimeDivisions(shiftTable:    _shiftTable),
      InputAssignNum(shiftTable:        _shiftTable),
      InputDeadlineDuration(shiftTable: _shiftTable),
      CheckShiftTable(shiftTable:       _shiftTable),
    ];

    return GestureDetector(
        onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        //AppBar
        appBar: AppBar(
          title: Text("シフト表の作成",style: MyFont.headlineStyleGreen20),
          backgroundColor: MyFont.backgroundColor.withOpacity(0.9),
          foregroundColor: MyFont.primaryColor,
          bottomOpacity: 2.0,
          elevation: 2.0,
        ),
        
        extendBody: true,
        extendBodyBehindAppBar: true,
    
        body: screens[_selectedIndex],
    
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: MyFont.backgroundColor.withOpacity(0.9),
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