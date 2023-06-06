import 'package:flutter/material.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/functions/show_modal_window.dart';

// 0 : weekSelectIndex 1 : weekdaySelectIndex 2 : timeDivsSelectIndex  3 : assignNumSelectIndex
List<int> selectorsIndex  = [0, 0, 0, 0];

DateTime now = DateTime.now();
var startWeekday = DateTime(now.year, now.month + 1, 1).weekday;
var lastDay      = DateTime(now.year, now.month + 2, 1).add(const Duration(days: -1)).day;
var scrollController = ScrollController();

class InputAssignNum extends StatefulWidget {
  final ShiftTable shiftTable;

  const InputAssignNum({Key? key, required this.shiftTable}) : super(key: key);
   
  @override
  InputAssignNumState createState() => InputAssignNumState();
}

class InputAssignNumState extends State<InputAssignNum> {
  
  @override
  Widget build(BuildContext context) {
    
    var appBarHeight = AppBar().preferredSize.height;
    var screenSize   = MediaQuery.of(context).size;

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
                child: Text("STEP 2", style: MyFont.headlineStyleWhite20),
              ),
              Text("勤務人数の設定", style: MyFont.headlineStyleGreen20),
            ],                  
          ),
    
          SizedBox(height: screenSize.height/30),
          Text("基本となる勤務人数を設定してください\n※ 後日変更可 \n※ 上の設定から順に上書きされます", style: MyFont.defaultStyleGrey15),
          SizedBox(height: screenSize.height/30),
    
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MyFont.primaryColor)),
                    onPressed: () {
                      showList(weekSelect, 0);
                    },
                    child: Text(weekSelect[selectorsIndex[0]], style: MyFont.defaultStyleWhite15)
                  ),
    
                  const SizedBox(width: 10),
                  Text("の", style: MyFont.defaultStyleGrey15),
                  const SizedBox(width: 10),
    
                  ElevatedButton(
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MyFont.primaryColor)),
                    onPressed: () {
                      showList(weekdaySelect, 1);
                    },
                    child: Text(weekdaySelect[selectorsIndex[1]], style: MyFont.defaultStyleWhite15)
                  ),
    
                  const SizedBox(width: 10),
                  Text("の", style: MyFont.defaultStyleGrey15),
                  const SizedBox(width: 10),
                
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MyFont.primaryColor)),
                    onPressed: () {
                      showList(List.generate(widget.shiftTable.timeDivs.length + 1, (index) => (index == 0) ? '全ての区分' : widget.shiftTable.timeDivs[index-1].name), 2);
                      setState(() {});
                    },
                    child: Text(List.generate(widget.shiftTable.timeDivs.length + 1, (index) => (index == 0) ? '全ての区分' : widget.shiftTable.timeDivs[index-1].name)[selectorsIndex[2]], style: MyFont.defaultStyleWhite15)
                  ),
    
                  const SizedBox(width: 10),
                  Text("の勤務人数は", style: MyFont.defaultStyleGrey15),
                  const SizedBox(width: 10),
                  
                  ElevatedButton(
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MyFont.primaryColor)),
                    onPressed: () {
                      showList(List<String>.generate(10, (index) => index.toString()), 3);
                    },
                    child: Text(selectorsIndex[3].toString(), style: MyFont.defaultStyleWhite15)
                  ),
    
                  const SizedBox(width: 10),
                  Text("人", style: MyFont.defaultStyleGrey15),
                ],
              ),
    
              const SizedBox(height: 20),
              SizedBox(
                child: Container(
                  decoration: const BoxDecoration(
                    color: MyFont.primaryColor,
                    shape: BoxShape.circle
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                    onPressed: () {
                      widget.shiftTable.rules.add(ShiftRule(week: selectorsIndex[0], weekday: selectorsIndex[1], timeDivs: selectorsIndex[2], assignNum: selectorsIndex[3]));
                      setState(() {});
                    }
                  ),
                )
              ),
            ],
          ),
    
          SizedBox(height: screenSize.height/30),
    
          // 登録した勤務人数ルール一覧
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenSize.width * 0.1,
              maxWidth: screenSize.width  * 0.8,
            ),
            child: (widget.shiftTable.rules.isEmpty) ? Text("登録されているルールがありません", style: MyFont.defaultStyleGrey15) : ReorderableListView.builder(
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              itemCount: widget.shiftTable.rules.length,
              itemBuilder: (context, i) => buildItem(
                i, 
                weekSelect[widget.shiftTable.rules[i].week], 
                weekdaySelect[widget.shiftTable.rules[i].weekday],
                List.generate(widget.shiftTable.timeDivs.length + 1, (index) => (index == 0) ? '全ての区分' : widget.shiftTable.timeDivs[index-1].name)[widget.shiftTable.rules[i].timeDivs],
                widget.shiftTable.rules[i].assignNum,
                context
              ),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final ShiftRule item = widget.shiftTable.rules.removeAt(oldIndex);
                  widget.shiftTable.rules.insert(newIndex, item);
                });
              }),
          ),
          SizedBox(height: screenSize.height / 20 + appBarHeight),
        ],
      ),
    );
  }

  void showList(List<String> list, int index) {
    var box = SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int result) {
          return Column(
            children: [
              ListTile(
                title: Text(list[result], style: MyFont.headlineStyleBlack15,textAlign: TextAlign.center),
                onTap: () {
                  selectorsIndex[index] = result;
                  setState(() {});
                  Navigator.of(context).pop();
                },
              ),
              const Divider(thickness: 2)
            ],
          );
        },
      ),
    );
    showModalWindow(context, box);
  }

  Widget buildItem(int index, String weekSelect, String weekdaySelect, String timeDivsSelect, int assignNumSelect, BuildContext context) {
    return Card(
      key: Key(index.toString()),
      shape: RoundedRectangleBorder( 
        borderRadius: BorderRadius.circular(8),
      ),
      color: MyFont.primaryColor,
      child: ReorderableDragStartListener(
        index: index,
        child: ListTile(
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('"$weekSelect"',      style: MyFont.defaultStyleWhite13, textHeightBehavior: MyFont.defaultBehavior),
              Text(' の ',               style: MyFont.defaultStyleWhite13, textHeightBehavior: MyFont.defaultBehavior),
              Text('"$weekdaySelect"',   style: MyFont.defaultStyleWhite13, textHeightBehavior: MyFont.defaultBehavior),
              Text(' の ',               style: MyFont.defaultStyleWhite13, textHeightBehavior: MyFont.defaultBehavior),
              Text('"$timeDivsSelect"',  style: MyFont.defaultStyleWhite13, textHeightBehavior: MyFont.defaultBehavior),
              Text(' の勤務人数は ',     style: MyFont.defaultStyleWhite13, textHeightBehavior: MyFont.defaultBehavior),
              Text('"$assignNumSelect"', style: MyFont.defaultStyleWhite13, textHeightBehavior: MyFont.defaultBehavior),
              Text(' 人',                style: MyFont.defaultStyleWhite13, textHeightBehavior: MyFont.defaultBehavior),
            ],
          ),
          leading: Text('ルール ${index+1}', style: MyFont.defaultStyleWhite15, textHeightBehavior: MyFont.defaultBehavior),
          trailing: SizedBox(
            height: double.infinity,
            child:  IconButton(
              onPressed: () {
                widget.shiftTable.rules.remove(widget.shiftTable.rules[index]);
                setState(() {});
              },
              icon: const Icon(Icons.delete),
              color: Colors.white,
            )
          ),
        ),
      ),
    );
  }
}
