import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/functions/show_modal_window.dart';
import 'package:shift/src/functions/trace_detector/hit_detector.dart';

const double _tableHeight      = 15;
const double _tableWidth       = 15;
const double _tableTitleHeight = 30;
const double _tableTitleWidth  = 60;

int x = 0;
int y = 0;

class TestDot extends StatefulWidget {
  final ShiftTable _shiftTable;

  const TestDot({Key? key, required ShiftTable shiftTable}) : _shiftTable = shiftTable, super(key: key);
   
  @override
  TestDotState createState() => TestDotState();
}

class TestDotState extends State<TestDot> {
  
  int tableSize = 15;

  @override
  Widget build(BuildContext context) {

    widget._shiftTable.generateShiftTable();
    var appBarHeight = AppBar().preferredSize.height;
    var screenSize = MediaQuery.of(context).size;

    int tableWidth  = (((screenSize.width  * 0.9) - _tableTitleWidth) ~/ _tableWidth).clamp(1, widget._shiftTable.assignTable.length);
    int tableHeight = (((screenSize.height * 0.87) - 15 - appBarHeight*2 - _tableTitleHeight) ~/ _tableHeight - 1).clamp(1, widget._shiftTable.timeDivs.length);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.height/10 + appBarHeight),
        // Text("作成される基本のシフト表を確認してください", style: MyFont.defaultStyleGrey15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: MyFont.backgroundColor,
                shadowColor: MyFont.hiddenColor, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: const BorderSide(color: MyFont.primaryColor),
              ),
              onPressed: (){ 
                setState(() {
                  tableSize = (tableSize - 1).clamp(10, 20);
                });
              },
              child: const Icon(Icons.zoom_in, color: MyFont.primaryColor)
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: MyFont.backgroundColor,
                shadowColor: MyFont.hiddenColor, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: const BorderSide(color: MyFont.primaryColor),
              ),
              onPressed: (){ 
                setState(() {
                  tableSize = (tableSize + 1).clamp(10, 20);
                });
              },
              child: const Icon(Icons.zoom_out, color: MyFont.primaryColor)
            ),
          ],
        ),

        Matrix(
          selected: Coordinate(column: x, row: y),
          onChangeSelect: (p0){
            setState(() {
              x = p0!.column;
              y = p0.row;
            });
          },
          columnCount: tableSize,
          rowCount: tableSize
        ),
    
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     _getLegendItemWidget("", _tableTitleWidth),
        //     for(int i =0; i < tableWidth; i++)
        //     _getTitleItemWidget(i, _tableWidth)
        //   ],
        // ),
        // for(int i = 0; i < tableHeight; i++)
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     _generateFirstColumnsRow(context, i),
        //     _generateRightHandSideColumnRow(context, i, tableWidth),
        //   ],
        // ),
      ],
    );
  }
  
  Widget _getLegendItemWidget(String label, double width) {
    return Container(
      width: width,
      height: _tableTitleHeight,
      alignment: Alignment.center,
      child: Text(label, style: MyFont.tableTitleStyle(Colors.black)),
    );
  }

  Widget _getTitleItemWidget(int index, double width) {
    return Container(
      width: width,
      height: _tableTitleHeight,
      alignment: Alignment.center,
      child: calenderColumn(index)
    );
  }

  Widget _generateFirstColumnsRow(BuildContext context, int index){
    return Container(
      width: _tableTitleWidth,
      height: _tableHeight,
      alignment: Alignment.center,
      child: Text(widget._shiftTable.timeDivs[index].name, style: MyFont.tableTitleStyle(Colors.black)),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index, int width) {
    
    var dataRange = widget._shiftTable.assignTable[index].getRange(0, width);

    return Row(
      children: [
        for(int indexDate = 0; indexDate < dataRange.length; indexDate++)
        Padding(
          padding: const EdgeInsets.all(1.0),
          child: GestureDetector(
            onPanDown: (data) => setState(() {
              print(data.globalPosition);
              widget._shiftTable.assignTable[index][indexDate] = 1;
            }),
            child: Container(
              width:  13,
              height: 13,
              decoration: BoxDecoration(
                color: (widget._shiftTable.assignTable[index][indexDate] > 0) ? MyFont.primaryColor : MyFont.backgroundColor,
                borderRadius: BorderRadius.circular(3.0)
              ),
            ),
          )
        )
      ]
    );
  }


  Widget calenderColumn(index){
    var weekdayJP = ["月", "火", "水", "木", "金", "土", "日"];
    DateTime  date = widget._shiftTable.shiftDateRange.start.add(Duration(days: index));
    
    final Text day, weekday;

    if(date.weekday < 6){
      day     = Text('${date.day}', style: MyFont.tableTitleStyle(Colors.black)); 
      weekday = Text(weekdayJP[date.weekday - 1], style: MyFont.tableTitleStyle(Colors.black));
    }else if(date.weekday == 6){
      day     = Text('${date.day}', style: MyFont.tableTitleStyle(Colors.blue)); 
      weekday = Text(weekdayJP[date.weekday - 1], style: MyFont.tableTitleStyle(Colors.blue));
    }else if(date.weekday == 7){
      day     = Text('${date.day}', style: MyFont.tableTitleStyle(Colors.red)); 
      weekday = Text(weekdayJP[date.weekday - 1], style: MyFont.tableTitleStyle(Colors.red));
    }else{
      day     = Text('${date.day}', style: MyFont.tableTitleStyle(Colors.black)); 
      weekday = Text('?', style: MyFont.tableTitleStyle(Colors.black));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        day,
        weekday
      ]
    );
  }

  void registerShitTable(ShiftTable shiftTable) async{
    
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth      auth      = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    final uid = user?.uid;

    final table = {
      'user-id'       : uid,
      'name'          : shiftTable.name,
      'request-start' : shiftTable.inputDateRange.start,
      'request-end'   : shiftTable.inputDateRange.end,
      'work-start'    : shiftTable.shiftDateRange.start,
      'work-end'      : shiftTable.shiftDateRange.end,
      'time-division' : FieldValue.arrayUnion(List.generate(shiftTable.timeDivs.length, (index) => {
        'name' : shiftTable.timeDivs[index].name, 'start-time' : shiftTable.timeDivs[index].startTime, 'end-time' : shiftTable.timeDivs[index].endTime
      }))
    };

    var refarence = await firestore.collection('shift-table').add(table);

    final request = {
      'user-id'       : uid,
      'table-refarence' : refarence
    };

    await firestore.collection('shift-request').add(request);
  }
}
