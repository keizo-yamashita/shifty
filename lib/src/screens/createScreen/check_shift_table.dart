import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/functions/show_modal_window.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

const double _tableHeight     = 45;
const double _tableWidth      = 45;
const double _tableTitleWidth = 90;

class CheckShiftTable extends StatefulWidget {
  final ShiftTable shiftTable;

  const CheckShiftTable({Key? key, required this.shiftTable}) : super(key: key);
   
  @override
  CheckShiftTableState createState() => CheckShiftTableState();
}

class CheckShiftTableState extends State<CheckShiftTable> {
  
  // ignore: unused_field
  late ScrollController _verticalScrollController;
  // late ScrollController _horizontalScrollController;

  @override
  Widget build(BuildContext context) {

    widget.shiftTable.generateShiftTable();
    var appBarHeight = AppBar().preferredSize.height;
    var screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenSize.height / 20 + appBarHeight),
          Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: MyFont.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("STEP 4", style: MyFont.headlineStyleWhite20),
              ),
              Text("シフト表のチェック", style: MyFont.headlineStyleGreen20),
            ],                  
          ),
          SizedBox(height: screenSize.height/30),
          Text("作成される基本のシフト表を確認してください", style: MyFont.defaultStyleGrey15),
          SizedBox(height: screenSize.height/30),
    
          SizedBox(
            child: Container(
              decoration: const BoxDecoration(
                color: MyFont.primaryColor,
                shape: BoxShape.circle
              ),
              child: IconButton(
                icon: const Icon(Icons.add),
                color: MyFont.backGroundColor,
                onPressed: () {
                  showModalWindow(context, createShiftTemplate());
                  setState(() {});
                }
              ),
            )
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
      List<Widget>.generate(widget.shiftTable.shiftDateRange.end.difference(widget.shiftTable.shiftDateRange.start).inDays+1, (index) => _getTitleItemWidget(index, _tableWidth))
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
      child: Text(widget.shiftTable.timeDivs[index].name, style: MyFont.tableTitleStyle(Colors.black)),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
  return Row(
    children: widget.shiftTable.assignTable.asMap().entries.map<Widget>(
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
    DateTime  date = widget.shiftTable.shiftDateRange.start.add(Duration(days: index));
    
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
            rightHandSideColumnWidth: (widget.shiftTable.shiftDateRange.end.difference(widget.shiftTable.shiftDateRange.start).inDays+1) * _tableWidth,
            isFixedHeader: true,
            headerWidgets: _getTitleWidget(),
            leftSideItemBuilder: _generateFirstColumnsRow,
            rightSideItemBuilder: _generateRightHandSideColumnRow,
            itemCount: widget.shiftTable.timeDivs.length,
            rowSeparatorWidget: const Divider(
              color: MyFont.primaryColor,
              height: 5.0,
              thickness: 1.0,
            ),
            onScrollControllerReady: (vertical, horizontal) {
              _verticalScrollController = vertical;
              // _horizontalScrollController = horizontal;
            },
            // verticalScrollbarStyle: const ScrollbarStyle(
            //   thumbColor: MyFont.primaryColor,
            //   isAlwaysShown: true,
            //   thickness: 4.0,
            //   radius: Radius.circular(5.0),
            // ),
            // horizontalScrollbarStyle: const ScrollbarStyle(
            //   thumbColor: MyFont.primaryColor,
            //   isAlwaysShown: true,
            //   thickness: 4.0,
            //   radius: Radius.circular(5.0),
            // ),
          ),
        ),
      ),
    );
  }
}

void addTempleteShitTable(ShiftTable shiftTable) async{
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final data = {
    'table-id' : 80,
    'user-id' : 60,
    'input-start-time' : "2023/01/01",
    'input-end-time' : "2023/01/01",
    'start-time' : "2023/01/01",
    'end-time' : "2023/01/01",
    'time-divison' : "朝，昼，夜",
    'rules': "1111, 1111, 1111",
  };
  await firestore.collection('template-shift-table').add(data);
}
