import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shift/src/font.dart';
import 'package:shift/src/screens/shift_table.dart';

DateTime now = DateTime.now();
var startWeekday = DateTime(now.year, now.month + 1, 1).weekday;
var lastDay      = DateTime(now.year, now.month + 2, 1).add(const Duration(days: -1)).day;
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
    return _buildSuggestions();
  }

  final myController = TextEditingController();

  Widget _buildSuggestions() {
    widget.shiftTable.regenerateShiftTable(startWeekday, lastDay);
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

        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: screenSize.width * 0.1,
            maxWidth: screenSize.width  * 0.9,
          ),
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            controller: scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              child: Column(
                children: [
                  // カレンダーの日付
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(1),
                        height: 40,
                        width:screenSize.width/8,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: MyFont.tableColumnsColor,
                          border: Border.all(color: MyFont.tableBorderColor, width: 1),
                        ),
                        child: const Text(""),
                      ),
                      for(int i =0 ; i < lastDay; i++)
                      Container(
                        margin: const EdgeInsets.all(1),
                        height: 40,
                        width:40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: MyFont.tableColumnsColor,
                          border: Border.all(color: MyFont.tableBorderColor, width: 1),
                        ),
                        child: (() {
                          switch(DateTime(now.year, now.month + 1, i+1).weekday){
                            case 1:
                              return Text('${i+1}(月)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                            case 2:
                              return Text('${i+1}(火)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                            case 3:
                              return Text('${i+1}(水)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                            case 4:
                              return Text('${i+1}(木)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                            case 5:
                              return Text('${i+1}(金)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                            case 6:
                              return Text('${i+1}(土)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue));
                            case 7:
                              return Text('${i+1}(日)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red));
                            default:
                              return Text('${i+1}(？)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                            }
                          }
                        )(),
                      ),
                    ],
                  ),
                  
                  // シフト表本体
                  for(int i = 0; i < widget.shiftTable.timeDivs.length; i++)
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(1),
                        height: 40,
                        width:screenSize.width/5,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: MyFont.tableColumnsColor,
                          border: Border.all(color: MyFont.tableBorderColor, width: 1),
                        ),
                        child: Text(widget.shiftTable.timeDivs[i], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      for(int j =0 ; j < lastDay; j++)
                      Container(
                        margin: const EdgeInsets.all(1),
                        height: 40,
                        width:40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: MyFont.tableBorderColor, width: 1),
                        ),
                        child: Text('${widget.shiftTable.assignTable[i].timeDivsAssign[j]} 人', style: const TextStyle(fontSize: 10)),           
                      )
                    ]
                  ),
                  const SizedBox(height: 20),
                ],
              )
            ),
          ),
        ),

        IconButton(onPressed: (){addTempleteShitTable(widget.shiftTable);}, icon: const Icon(Icons.add)),
      ],
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