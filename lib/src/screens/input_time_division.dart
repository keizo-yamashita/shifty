import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shift/src/font.dart';
import 'package:shift/src/screens/create_schedule.dart';
import 'package:shift/src/screens/shift_table.dart';

class InputTimeDivisions extends StatefulWidget {
  final ShiftTable shiftTable;
  const InputTimeDivisions({Key? key, required this.shiftTable}) : super(key: key);
   
  @override
  TimeDivisionState createState() => TimeDivisionState();
}

class TimeDivisionState extends State<InputTimeDivisions> {
  
  @override
  Widget build(BuildContext context) {
    return _buildSuggestions();
  }

  final myController = TextEditingController();

  Widget _buildSuggestions() {
    
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
              child: const Text("STEP 1", style: MyFont.headlineStyleWhite),
            ),
            const Text("時間区分の設定", style: MyFont.headlineStyleGreen),
          ],             
        ),
        
        SizedBox(height: screenSize.height/30),
        const Text("基本となる時間区分を入力してください\n※ 後日変更可 \n※ 後日特定の日付のみ特別な時間区分に変更可", style: MyFont.commentStyle),
        SizedBox(height: screenSize.height/30),

        // 登録した時間区分一覧
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: screenSize.width * 0.1,
            maxWidth: screenSize.width * 0.8,
          ),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            itemCount: widget.shiftTable.timeDivs.length,
            itemBuilder: (context, i) => buildItem(widget.shiftTable.timeDivs[i], i, context),
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                shiftTable.sortTimeDivision(oldIndex, newIndex);
              });
            }
          ),
        ),
        
        SizedBox(height: screenSize.height/30),

        // 時間区分の入力欄と登録ボタン
         Row(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: screenSize.width * 0.1,
                maxWidth: screenSize.width  * 0.6,
              ),
              child: TextField(
                controller: myController,
                decoration: const InputDecoration(
                  hintText: '時間区分入力欄',
                ),
              ),
            ),

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
                    final input = myController.text;
                    if(input.isNotEmpty){
                      setState(() {
                        myController.clear();
                        if(!widget.shiftTable.addTimeDivison(input)){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: const Text('STEP 1 : 入力エラー\n', style: TextStyle(color: Colors.red)),
                                content: const Text('すでに使用されている時間区分名です'),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      });
                    }
                  }
                ),
              )
            )
          ]
        ),
      ],
    );
  }

  Widget buildItem(String item, int index, BuildContext context) {
    return Card(
      key: Key(index.toString()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),      
      ),
      color: Colors.green,
      child: ReorderableDragStartListener(
        index: index,
        child: ListTile(
          title: Text(item, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textHeightBehavior: MyFont.defaultBehavior),
          leading: SizedBox(
            child: Text('${index+1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20), textHeightBehavior: MyFont.defaultBehavior),
          ),
          trailing: IconButton(
            onPressed: () {
              widget.shiftTable.removeTimeDivision(index);
              setState(() {});
            },
            icon: const Icon(Icons.delete),
            color: Colors.white,
          ),
          onTap: () {
            setState(() {
              myController.text = item;
            });
          },
        ),
      ),
    );
  }
}
