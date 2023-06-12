import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/functions/show_modal_window.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

const double _tableHeight     = 45;
const double _tableWidth      = 45;
const double _tableTitleWidth = 90;

class CheckShiftTable extends StatefulWidget {
  final ShiftTable _shiftTable;

  const CheckShiftTable({Key? key, required ShiftTable shiftTable}) : _shiftTable = shiftTable, super(key: key);
   
  @override
  CheckShiftTableState createState() => CheckShiftTableState();
}

class CheckShiftTableState extends State<CheckShiftTable> {

  @override
  Widget build(BuildContext context) {
    // set input text and cursor positon 
    final TextEditingController textConroller = TextEditingController(text: widget._shiftTable.name);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      textConroller.selection = TextSelection.fromPosition(TextPosition(offset: textConroller.text.length));
    });

    widget._shiftTable.generateShiftTable();
    var appBarHeight = AppBar().preferredSize.height;
    var screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: screenSize.height / 10 + appBarHeight),
          Text("作成される基本のシフト表を確認してください", style: MyFont.defaultStyleGrey15),
          SizedBox(height: screenSize.height/30),
          
          SizedBox(
            width: screenSize.width * 0.7,
            child: TextField(
              controller: textConroller,
              cursorColor: MyFont.primaryColor,
              decoration: InputDecoration(
                prefixIconColor: MyFont.primaryColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: MyFont.primaryColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: MyFont.primaryColor,
                  ),
                ),
                prefixIcon: const Icon(Icons.input),
                hintText: 'シフト表名を入力してください',
                hintStyle: MyFont.defaultStyleGrey15,
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.go,
              onChanged: (value){widget._shiftTable.name = value;},
            ),
          ),
          
          SizedBox(height: screenSize.height/30),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                child: Container(
                  decoration: const BoxDecoration(
                    color: MyFont.primaryColor,
                    shape: BoxShape.circle
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.check),
                    color: MyFont.backgroundColor,
                    onPressed: () {
                      showModalWindow(context, createShiftTemplate());
                    }
                  ),
                )
              ),
              SizedBox(
                child: Container(
                  decoration: const BoxDecoration(
                    color: MyFont.primaryColor,
                    shape: BoxShape.circle
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    color: MyFont.backgroundColor,
                    onPressed: () {
                      if(widget._shiftTable.name.isEmpty){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text('STEP 4 : 入力エラー\n', style: TextStyle(color: Colors.red)),
                              content: const Text('シフト表名を入力してください'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: const Text('OK', style: TextStyle(color: Colors.red)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }else{
                        registerShitTable(widget._shiftTable);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text('STEP : 完了\n', style: TextStyle(color: MyFont.primaryColor)),
                              content: const Text('シフト表を登録しました！'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: const Text('OK', style: TextStyle(color: MyFont.primaryColor)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  ),
                )
              ),
            ],
          ),
          SizedBox(height: screenSize.height / 20 + appBarHeight),
        ],
      ),
    );
  }

  List<Widget> _getTitleWidget(){
    return [
      _getLegendItemWidget('', _tableTitleWidth),
      ...
      List<Widget>.generate(widget._shiftTable.shiftDateRange.end.difference(widget._shiftTable.shiftDateRange.start).inDays+1, (index) => _getTitleItemWidget(index, _tableWidth))
    ];
  }
  
  Widget _getLegendItemWidget(String label, double width) {
    return Container(
      width: width,
      height: _tableHeight,
      alignment: Alignment.center,
      child: Text(label, style: MyFont.tableTitleStyle(Colors.black)),
    );
  }

  Widget _getTitleItemWidget(int index, double width) {
    return Container(
      width: width,
      height: _tableHeight,
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

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
  return Row(
    children: widget._shiftTable.assignTable.asMap().entries.map<Widget>(
      (list) => Container(
          width: _tableWidth,
          height: _tableHeight,
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () => {
              // print("${list.key} $index")
            },
            child: Text("${list.value[index]} 人", style: MyFont.tableDefaultStyle(Colors.black))
          ),
          )
        ).toList()
    );
  }


  Widget calenderColumn(index){
    var weekdayJP = ["月", "火", "水", "木", "金", "土", "日"];
    DateTime  date = widget._shiftTable.shiftDateRange.start.add(Duration(days: index));
    
    final Text day, weekday;

    if(date.weekday < 6){
      day     = Text('${date.month}/${date.day}', style: MyFont.tableTitleStyle(Colors.black)); 
      weekday = Text('(${weekdayJP[date.weekday - 1]})', style: MyFont.tableTitleStyle(Colors.black));
    }else if(date.weekday == 6){
      day     = Text('${date.month}/${date.day}', style: MyFont.tableTitleStyle(Colors.blue)); 
      weekday = Text('(${weekdayJP[date.weekday - 1]})', style: MyFont.tableTitleStyle(Colors.blue));
    }else if(date.weekday == 7){
      day     = Text('${date.month}/${date.day}', style: MyFont.tableTitleStyle(Colors.red)); 
      weekday = Text('(${weekdayJP[date.weekday - 1]})', style: MyFont.tableTitleStyle(Colors.red));
    }else{
      day     = Text('${date.month}/${date.day}', style: MyFont.tableTitleStyle(Colors.black)); 
      weekday = Text('(?)', style: MyFont.tableTitleStyle(Colors.black));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        day,
        weekday
      ]
    );
  }

  Widget createShiftTemplate(){

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 3, left: 3, bottom: 5),
        child: SizedBox(
          child: HorizontalDataTable(
            leftHandSideColumnWidth: _tableTitleWidth,
            rightHandSideColumnWidth: (widget._shiftTable.shiftDateRange.end.difference(widget._shiftTable.shiftDateRange.start).inDays+1) * _tableWidth,
            isFixedHeader: true,
            headerWidgets: _getTitleWidget(),
            leftSideItemBuilder: _generateFirstColumnsRow,
            rightSideItemBuilder: _generateRightHandSideColumnRow,
            itemCount: widget._shiftTable.timeDivs.length,
            rowSeparatorWidget: const Divider(
              color: MyFont.primaryColor,
              height: 5.0,
              thickness: 1.0,
            ),
          ),
        ),
      ),
    );
  }
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
