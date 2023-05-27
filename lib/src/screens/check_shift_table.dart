import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shift/src/font.dart';
import 'package:shift/src/screens/shift_table.dart';
import 'package:shift/src/screens/decorated_table_page.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

var scrollController = ScrollController();

class CheckShiftTable extends StatefulWidget {
  final ShiftTable shiftTable;

  const CheckShiftTable({Key? key, required this.shiftTable}) : super(key: key);
   
  @override
  CheckShiftTableState createState() => CheckShiftTableState();
}

class CheckShiftTableState extends State<CheckShiftTable> {
  
  // ignore: unused_field
  late ScrollController _verticalScrollController;
  // ignore: unused_field
  late ScrollController _horizontalScrollController;

  @override
  Widget build(BuildContext context) {

    widget.shiftTable.generateShiftTable();
    var screenSize   = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("STEP 4", style: MyFont.headlineStyleWhite),
            ),
            const Text("シフト表のテェック", style: MyFont.headlineStyleGreen),
          ],                  
        ),
        SizedBox(height: screenSize.height/30),
        const Text("作成される基本のシフト表を確認してください", style: MyFont.commentStyle),
        SizedBox(height: screenSize.height/30),

        SizedBox(
          width: screenSize.width * 0.9,
          height: screenSize.height * 0.5,
          child: HorizontalDataTable(
            leftHandSideColumnWidth: 100,
            rightHandSideColumnWidth: (widget.shiftTable.workEndDate.difference(widget.shiftTable.workStartDate).inDays+1) * 50,
            isFixedHeader: true,
            headerWidgets: _getTitleWidget(),
            leftSideItemBuilder: _generateFirstColumnsRow,
            rightSideItemBuilder: _generateRightHandSideColumnRow,
            itemCount: widget.shiftTable.timeDivs.length,
            rowSeparatorWidget: const Divider(
              color: MyFont.tableBorderColor,
              height: 1.0,
              thickness: 0.0,
            ),
            leftHandSideColBackgroundColor: MyFont.tableColumnsColor,
            rightHandSideColBackgroundColor: const Color(0xFFFFFFFF),
            onScrollControllerReady: (vertical, horizontal) {
              _verticalScrollController = vertical;
              _horizontalScrollController = horizontal;
            },
          ),
        ),

        SizedBox(height: screenSize.height / 30),
        
        SizedBox(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle
            ),
            child: IconButton(
              icon: const Icon(Icons.add),
              color: Colors.white,
              onPressed: () {
                addTempleteShitTable(widget.shiftTable);
                setState(() {});
              }
            ),
          )
        ),
      ],
    );
  }

  List<Widget> _getTitleWidget(){
    return [
      _getLegendItemWidget('', 100),
      ...
      List<Widget>.generate(widget.shiftTable.workEndDate.difference(widget.shiftTable.workStartDate).inDays+1, (index) => _getTitleItemWidget(index, 50))
    ];
  }
  
  Widget _getLegendItemWidget(String label, double width) {
    return Container(
      width: width,
      height: 50,
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _getTitleItemWidget(int index, double width) {
    return Container(
      width: width,
      height: 50,
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.center,
      child: calenderColumn(index)
    );
  }

  Widget _generateFirstColumnsRow(BuildContext context, int index){
    return Container(
      width: 100,
      height: 50,
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.center,
      child: Text(widget.shiftTable.timeDivs[index].name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
  return Row(
    children: widget.shiftTable.assignTable.map<Widget>(
      (list) => Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: Text(list[index], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ).toList()
    );
  }

  Widget calenderColumn(index){
    DateTime day = widget.shiftTable.workStartDate.add(Duration(days: index));
    switch(day.weekday){
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Text('(月)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
          ]
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Text('(火)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
          ]
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Text('(水)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
          ]
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Text('(木)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
          ]
        );
      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Text('(金)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
          ]
        );
      case 6:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Text('(土)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue))
          ]
        );
      case 7:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Text('(日)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red))
          ]
        );
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const Text('(？)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
          ]
        );
    }
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
