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
              child: const Text("STEP 2", style: MyFont.headlineStyleWhite20),
            ),
            const Text("勤務人数の設定", style: MyFont.headlineStyleGreen20),
          ],                  
        ),

        SizedBox(height: screenSize.height/30),
        const Text("基本となる勤務人数を設定してください\n※ 後日変更可 \n※ 上の設定から順に上書きされます", style: MyFont.commentStyle15),
        SizedBox(height: screenSize.height/30),

        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showList(weekSelect, 0);
                  },
                  child: Text(weekSelect[selectorsIndex[0]])
                ),

                const SizedBox(width: 10),
                const Text("の"),
                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () {
                    showList(weekdaySelect, 1);
                  },
                  child: Text(weekdaySelect[selectorsIndex[1]])
                ),

                const SizedBox(width: 10),
                const Text("の"),
                const SizedBox(width: 10),
              
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showList(List.generate(widget.shiftTable.timeDivs.length + 1, (index) => (index == 0) ? '全ての区分' : widget.shiftTable.timeDivs[index-1].name), 2);
                    setState(() {});
                  },
                  child: Text(List.generate(widget.shiftTable.timeDivs.length + 1, (index) => (index == 0) ? '全ての区分' : widget.shiftTable.timeDivs[index-1].name)[selectorsIndex[2]])
                ),

                const SizedBox(width: 10),
                const Text("の勤務人数は"),
                const SizedBox(width: 10),
                
                ElevatedButton(
                  onPressed: () {
                    showList(List<String>.generate(10, (index) => index.toString()), 3);
                  },
                  child: Text(selectorsIndex[3].toString())
                ),

                const SizedBox(width: 10),
                const Text("人"),
              ],
            ),

            const SizedBox(height: 20),
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
          child: ReorderableListView.builder(
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
      ],
    );
  }

  void showList(List<String> list, int index) {
    var box = SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int result) {
          return ListTile(
            title: Text(list[result]),
            onTap: () {
              selectorsIndex[index] = result;
              setState(() {});
              Navigator.of(context).pop();
            },
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
      color: Colors.green,
      child: ReorderableDragStartListener(
        index: index,
        child: ListTile(
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('"$weekSelect"',        style: const TextStyle(color: Colors.white, fontSize: 15), textHeightBehavior: MyFont.defaultBehavior),
              const Text(' の ',           style:       TextStyle(color: Colors.white, fontSize: 15), textHeightBehavior: MyFont.defaultBehavior),
              Text('"$weekdaySelect"',     style: const TextStyle(color: Colors.white, fontSize: 15), textHeightBehavior: MyFont.defaultBehavior),
              const Text(' の ',           style:       TextStyle(color: Colors.white, fontSize: 15), textHeightBehavior: MyFont.defaultBehavior),
              Text('"$timeDivsSelect"',    style: const TextStyle(color: Colors.white, fontSize: 15), textHeightBehavior: MyFont.defaultBehavior),
              const Text(' の勤務人数は ', style:       TextStyle(color: Colors.white, fontSize: 15), textHeightBehavior: MyFont.defaultBehavior),
              Text('"$assignNumSelect"',   style: const TextStyle(color: Colors.white, fontSize: 15), textHeightBehavior: MyFont.defaultBehavior),
              const Text(' 人',            style:       TextStyle(color: Colors.white, fontSize: 15), textHeightBehavior: MyFont.defaultBehavior),
            ],
          ),
          leading: Text('${index+1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20), textHeightBehavior: MyFont.defaultBehavior),
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
