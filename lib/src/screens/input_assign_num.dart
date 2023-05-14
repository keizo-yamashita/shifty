import 'package:flutter/material.dart';
import 'package:shift/src/font.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shift/src/screens/shift_table.dart';

int weekSelectIndex       = 0;
int weekdaySelectIndex    = 0;
int timeDivsSelectIndex   = 0;
int assignNumSelectIndex  = 1;

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
    return _buildSuggestions();
  }

  final myController = TextEditingController();

  Widget _buildSuggestions() {
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
              child: const Text("STEP 2", style: MyFont.headlineStyleWhite),
            ),
            const Text("勤務人数の設定", style: MyFont.headlineStyleGreen),
          ],                  
        ),

        SizedBox(height: screenSize.height/30),
        const Text("基本となる勤務人数を設定してください\n※ 後日変更可 \n※ 上の設定から順に上書きされます", style: MyFont.commentStyle),
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
            itemBuilder: (context, i) => buildItem(i, 
              weekSelect[widget.shiftTable.rules[i].week], weekdaySelect[widget.shiftTable.rules[i].weekday], ['すべての区分', ...widget.shiftTable.timeDivs][widget.shiftTable.rules[i].timeDivs], widget.shiftTable.rules[i].assignNum, context
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

        SizedBox(height: screenSize.height/30),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberPicker(
                  infiniteLoop: true,
                  haptics: true,
                  value: weekSelectIndex.clamp(0, 4),
                  itemCount: 3,
                  minValue: 0,
                  maxValue: 4,
                  itemHeight: 30,
                  itemWidth:  120,
                  textStyle: const TextStyle(fontSize: 15),
                  selectedTextStyle: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                  onChanged: (value) => setState(() => weekSelectIndex = value),
                  decoration: BoxDecoration(
                    border: Border.all(color: MyFont.tableBorderColor, width: 2),
                  ),
                  textMapper: (numberText) {
                    return weekSelect[int.parse(numberText)];
                  },
                ),
                const SizedBox(width: 10),
                const Text("の"),
                const SizedBox(width: 10),

                NumberPicker(
                  infiniteLoop: true,
                  haptics: true,
                  value: weekdaySelectIndex.clamp(0, 7),
                  itemCount: 3,
                  minValue: 0,
                  maxValue: 7,
                  itemHeight: 30,
                  itemWidth:  150,
                  textStyle: const TextStyle(fontSize: 15),
                  selectedTextStyle: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                  onChanged: (value) => setState(() => weekdaySelectIndex = value),
                  decoration: BoxDecoration(
                    border: Border.all(color: MyFont.tableBorderColor, width: 2),
                  ),
                  textMapper: (numberText) {
                    return weekdaySelect[int.parse(numberText)];
                  },
                ),

                const SizedBox(width: 10),
                const Text("の"),
                const SizedBox(width: 10),
              
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberPicker(
                  infiniteLoop: true,
                  haptics: true,
                  value: timeDivsSelectIndex.clamp(0, widget.shiftTable.timeDivs.length),
                  itemCount: 3,
                  minValue: 0,
                  maxValue: widget.shiftTable.timeDivs.length,
                  itemHeight: 30,
                  itemWidth: 180,
                  textStyle: const TextStyle(fontSize: 15),
                  selectedTextStyle: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                  onChanged: (value) => setState(() => timeDivsSelectIndex = value),
                  decoration: BoxDecoration(
                    border: Border.all(color: MyFont.tableBorderColor, width: 2),
                  ),
                  textMapper: (numberText) {
                    List<String> selecter =<String>["すべての区分", ... widget.shiftTable.timeDivs];
                    return selecter[int.parse(numberText)];
                  },
                ),

                const SizedBox(width: 10),
                const Text("の勤務人数は"),
                const SizedBox(width: 10),

                NumberPicker(
                  infiniteLoop: true,
                  haptics: true,
                  value: assignNumSelectIndex,
                  itemCount: 3,
                  minValue: 0,
                  maxValue: 5,
                  itemHeight: 30,
                  itemWidth:  40,
                  textStyle: const TextStyle(fontSize: 15),
                  selectedTextStyle: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                  onChanged: (value) => setState(() => assignNumSelectIndex = value),
                  decoration: BoxDecoration(
                    border: Border.all(color: MyFont.tableBorderColor, width: 2),
                  ),
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
                    widget.shiftTable.rules.add(ShiftRule(week: weekSelectIndex, weekday: weekdaySelectIndex, timeDivs: timeDivsSelectIndex, assignNum: assignNumSelectIndex));
                    setState(() {});
                  }
                ),
              )
            ),
          ],
        )
      ],
    );
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
            child: IconButton(
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
