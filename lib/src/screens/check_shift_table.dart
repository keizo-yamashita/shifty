import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/functions/show_modal_window.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';

const double _tableHeight     = 30;
const double _tableWidth      = 40;
const double _tableTitleWidth = 80;

class CheckShiftTable extends StatefulWidget {
  final ShiftTable shiftTable;

  const CheckShiftTable({Key? key, required this.shiftTable}) : super(key: key);
   
  @override
  CheckShiftTableState createState() => CheckShiftTableState();
}

class CheckShiftTableState extends State<CheckShiftTable> {
  
  // ignore: unused_field
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController;

  @override
  Widget build(BuildContext context) {

    widget.shiftTable.generateShiftTable();
    var screenSize = MediaQuery.of(context).size;

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
              child: const Text("STEP 4", style: MyFont.headlineStyleWhite20),
            ),
            const Text("シフト表のチェック", style: MyFont.headlineStyleGreen20),
          ],                  
        ),
        SizedBox(height: screenSize.height/30),
        const Text("作成される基本のシフト表を確認してください", style: MyFont.commentStyle15),
        SizedBox(height: screenSize.height/30),

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
                showModalWindow(context, createShiftTemplate());
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
      _getLegendItemWidget('時間区分', _tableTitleWidth),
      ...
      List<Widget>.generate(widget.shiftTable.shiftDateRange.end.difference(widget.shiftTable.shiftDateRange.start).inDays+1, (index) => _getTitleItemWidget(index, _tableWidth))
    ];
  }
  
  Widget _getLegendItemWidget(String label, double width) {
    return Container(
      width: width,
      height: _tableHeight,
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontSize: 10)),
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
      child: Text(widget.shiftTable.timeDivs[index].name, style: const TextStyle(fontSize: 10)),
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
              print("${list.key} $index")
            },
            child: Text("${list.value[index]} 人", style: const TextStyle(fontSize: 10, color: Colors.black))
          ),
          )
        ).toList()
    );
  }


  Widget calenderColumn(index){
    DateTime day = widget.shiftTable.shiftDateRange.start.add(Duration(days: index));
    switch(day.weekday){
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10)),
            const Text('(月)', style: TextStyle(fontSize: 10))
          ]
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10)),
            const Text('(火)', style: TextStyle(fontSize: 10))
          ]
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10)),
            const Text('(水)', style: TextStyle(fontSize: 10))
          ]
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10)),
            const Text('(木)', style: TextStyle(fontSize: 10))
          ]
        );
      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10)),
            const Text('(金)', style: TextStyle(fontSize: 10))
          ]
        );
      case 6:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10)),
            const Text('(土)', style: TextStyle(fontSize: 10, color: Colors.blue))
          ]
        );
      case 7:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10)),
            const Text('(日)', style: TextStyle(fontSize: 10, color: Colors.red))
          ]
        );
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10)),
            const Text('(？)', style: TextStyle(fontSize: 10))
          ]
        );
    }
  }
  Widget createShiftTemplate(){
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.only(top: 18, right: 10, left: 10, bottom: 15),
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
              color: Colors.black,
              height: 5.0,
              thickness: 0.0,
            ),
            onScrollControllerReady: (vertical, horizontal) {
              _verticalScrollController = vertical;
              _horizontalScrollController = horizontal;
            },
            verticalScrollbarStyle: ScrollbarStyle(
              thumbColor: Colors.green[200],
              isAlwaysShown: true,
              thickness: 5.0,
              radius: const Radius.circular(5.0),
            ),
            horizontalScrollbarStyle: ScrollbarStyle(
              thumbColor: Colors.green[200],
              isAlwaysShown: true,
              thickness: 5.0,
              radius: const Radius.circular(5.0),
            ),
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
