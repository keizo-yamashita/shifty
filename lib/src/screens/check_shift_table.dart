import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shift/src/font.dart';
import 'package:shift/src/screens/shift_table.dart';
import 'package:shift/src/screens/decorated_table_page.dart';

var scrollController = ScrollController();

class CheckShiftTable extends StatefulWidget {
  final ShiftTable shiftTable;

  const CheckShiftTable({Key? key, required this.shiftTable}) : super(key: key);
   
  @override
  CheckShiftTableState createState() => CheckShiftTableState();
}

class CheckShiftTableState extends State<CheckShiftTable> {
  
  @override
  Widget build(BuildContext context) {

    widget.shiftTable.generateShiftTable();
    var screenSize   = MediaQuery.of(context).size;
    
    double tableHeight = screenSize.height * 0.45;
    double tableWidth  = screenSize.width * 0.9;
    
    const double cellHeight        = 40.0;
    const double cellWidth         = 40.0;
    const double rowTitleCellWidth = 80.0;
    
    BoxDecoration cellDecoration = const BoxDecoration(
      border: Border(
        top:    BorderSide(color: MyFont.tableBorderColor, width: 0.5),
        right:  BorderSide(color: MyFont.tableBorderColor, width: 0.5),
        bottom: BorderSide(color: MyFont.tableBorderColor, width: 0.5),
        left:   BorderSide(color: MyFont.tableBorderColor, width: 0.5),
      ),
    );
    
    BoxDecoration titleDecoration =  const BoxDecoration(
      border: Border(
        top:    BorderSide(color: MyFont.tableBorderColor, width: 0.5),
        right:  BorderSide(color: MyFont.tableBorderColor, width: 0.5),
        bottom: BorderSide(color: MyFont.tableBorderColor, width: 0.5),
        left:   BorderSide(color: MyFont.tableBorderColor, width: 0.5),
      ),
      color: MyFont.tableColumnsColor
    );

    Widget topLeft = Container(
      height: cellHeight,
      width: rowTitleCellWidth,
      alignment: Alignment.center,
      decoration: titleDecoration,
      child: const Text(''),
    );

    Widget colTitles = Row(
      children: List<int>.generate(widget.shiftTable.workEndDate.difference(widget.shiftTable.workStartDate).inDays+1,(index) => index)
        .map<Widget>(
          (n) => Container(
            height: cellHeight,
            width: cellWidth,
            alignment: Alignment.center,
            decoration: titleDecoration,
            child: calenderColumn(n),
          )
        ).toList()
    );

    Widget rowTitles = Column(
      children: widget.shiftTable.timeDivs
      .map<Widget>(
        (n) => Container(
          height: cellHeight,
          width:  rowTitleCellWidth,
          alignment: Alignment.center,
          decoration: titleDecoration,
          child: Text(n.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ).toList()
    );

    Widget body = Row(
      children: 
        widget.shiftTable.assignTable.map<Widget>(
          (list) => Column(
            children: list.map<Widget>(
              (n) => Container(
                height: cellHeight,
                width: cellWidth,
                alignment: Alignment.center,
                decoration: cellDecoration,
                child: Text(n, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ).toList(),
          ),
        )
        .toList(),
    );

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

        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.green,
              width: 3.0
            ),
          ),
          child: FixedTitlesView(
            key: const ValueKey('Test1'),
            height:       tableHeight,
            width:        tableWidth,
            fixedHeight:  cellHeight,
            fixedWidth:   rowTitleCellWidth,
            origin:       topLeft,
            colTitles:    colTitles,
            rowTitles:    rowTitles,
            body:         body
          ),
        ),

        SizedBox(height: screenSize.height / 30),
        IconButton(
          color: Colors.white,
          
          onPressed: (){addTempleteShitTable(widget.shiftTable);},
          icon: const Icon(Icons.add)
        ),
      ],
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
