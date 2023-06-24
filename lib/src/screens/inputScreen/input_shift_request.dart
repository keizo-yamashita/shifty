import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// my package
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/dialog.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/functions/hit_detector.dart';
import 'package:shift/src/functions/undo_redo.dart';
import 'package:shift/src/functions/show_modal_window.dart';
import 'package:shift/src/functions/shift_table_provider.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// 全体で使用する変数
////////////////////////////////////////////////////////////////////////////////////////////

const int _columnCountMax = 20;
const int _rowCountMax    = 32;
const int _columnCountMin = 10;
const int _rowCountMin    = 16;
const int _bufferMax      = 50;

bool _enableEdit    = false;
bool _enablePinch   = false;
int  _inkValue      = 1;


////////////////////////////////////////////////////////////////////////////////////////////
/// シフト表の最終チェックに使用するページ (勤務人数も指定)
////////////////////////////////////////////////////////////////////////////////////////////

class InputShiftRequestWidget extends StatefulWidget {
  
  const InputShiftRequestWidget({Key? key}) : super(key: key);
  
  @override
  State<InputShiftRequestWidget> createState() => InputShiftRequestWidgetState();
}

class InputShiftRequestWidgetState extends State<InputShiftRequestWidget> {

  static UndoRedo<List<List<int>>> undoredoCtrl = UndoRedo(_bufferMax);
  bool initFlag                = false;
  static int firstColumn       = 0;
  static int firstRow          = 0;
  static int lastColumn        = _columnCountMax;
  static int lastRow           = _rowCountMax;
  static Coordinate coordinate = Coordinate(column: 0, row: 0);
  static List<List<List<int>>> requestTableBuffer = [];
  
  ShiftTable _shiftTable = ShiftTable();

  @override
  Widget build(BuildContext context) {

    var screenSize = MediaQuery.of(context).size;
    
    _shiftTable = Provider.of<InputShiftRequestProvider>(context, listen: false).shiftTable;
    if(undoredoCtrl.buffer.isEmpty){
      insertBuffer(_shiftTable.requestTable);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("シフト希望の入力",style: MyFont.headlineStyleGreen20),
        backgroundColor: MyFont.backgroundColor.withOpacity(0.9),
        foregroundColor: MyFont.primaryColor,
        bottomOpacity: 2.0,
        elevation: 2.0,
      ),
    
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: screenSize.height * 0.02),
          
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// ツールボタン
          ////////////////////////////////////////////////////////////////////////////////////////////
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildIconButton( Icons.pinch, _enablePinch, (){_enablePinch = !_enablePinch; _enableEdit = false;}, (){}),
              buildIconButton(
                Icons.draw_rounded, _enableEdit,
                (){_enableEdit = !_enableEdit; _enablePinch = false;},
                (){ buildInkChangeModaleWindow(List<String>.generate(10, (index) => index.toString()));}
              ),
              buildIconButton( Icons.hdr_auto_outlined, true, (){ buildAutoFillModalWindow(context); }, (){}),
              buildIconButton( Icons.undo,  undoredoCtrl.enableUndo(), (){paintUndoRedo(true);}, (){}),
              buildIconButton( Icons.redo,  undoredoCtrl.enableRedo(), (){paintUndoRedo(false);}, (){}),
              buildIconButton( Icons.check, true, (){
                showConfirmDialog(
                  context, "確認", "このシフト希望を登録しますか？", "シフト希望を登録しました", (){
                  Navigator.pop(context);
                  // _shiftTable.pushShitTable();
                });
              }, (){}),
            ],
          ),
          
          SizedBox(height: screenSize.height * 0.01),
          
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// メインテーブル
          ////////////////////////////////////////////////////////////////////////////////////////////
          
          ColoringSheet(
            enableEdit:       _enableEdit,
            enablePinch:      _enablePinch,
            sheetWidth:       screenSize.width * 0.9,
            sheetHeight:      screenSize.height * 0.7,
            tableColumnTitle: List<Widget>.generate(_shiftTable.requestTable[0].length, (index) => buildColunTitleWidget(index)),
            tableRowTitle:    List<Widget>.generate(_shiftTable.requestTable.length, (index) => buildRowTitleWidget(context, index)),
            tableCell:        _shiftTable.requestTable,
            colorTable:       colorTable,
            selected:         coordinate,
            onChangeSelect:   (p0){
              setState(() {
                coordinate = p0!;
                _shiftTable.requestTable[coordinate.row][coordinate.column] = _inkValue;
              });
            },
            onSwipeRight:     (value){moveRightAction(value!);},
            onSwipeLeft:      (value){moveLeftAction(value!);},
            onSwipeUp:        (value){moveUpAction(value!);},
            onSwipeBottom:    (value){moveBottomAction(value!);},
            onPinch:          (value){pinchAction(value!);},
            onInputEnd:       (){ insertBuffer(_shiftTable.requestTable); },
            columnFirstIndex: firstColumn,
            rowFirstIndex:    firstRow,
            columnCount:      lastColumn - firstColumn,
            rowCount:         lastRow    - firstRow
          )
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  ページ上部のツールボタン作成に使用 (onPress OnLongPress 2つの関数を使用)
  ///  OnLongPress に 0.5 秒の検出時間がかかるので，GestureDetector で検出したほうがいいかも
  ////////////////////////////////////////////////////////////////////////////////////////////
  Widget buildIconButton(IconData icon, bool flag, Function onPressed, Function onLongPressed){
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: SizedBox(
        width: 50,
        height: 40,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: MyFont.backgroundColor,
            shadowColor: MyFont.hiddenColor, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: BorderSide(color: (flag) ? MyFont.primaryColor : MyFont.hiddenColor),
          ),
          onPressed: (){ 
            setState(() {
              onPressed();
            });
          },
          onLongPress: (){
            setState(() {
              onLongPressed();
            });
          },
          child: Icon(icon, color: (flag) ? MyFont.primaryColor : MyFont.hiddenColor, size: 20)
        ),
      ),
    );
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  ピンチアクションによるピンチアウト・ピンチインの実装
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void pinchAction(double scale){
    
    var shiftRowLength    = _shiftTable.requestTable.length;
    var shiftColumnLength = _shiftTable.requestTable[0].length;

    if(scale > 1.0){
      if(lastColumn - firstColumn != _columnCountMin){
        var lastColumnPrev = lastColumn;
        lastColumn  = (lastColumn - 5).clamp(_columnCountMin, max(_columnCountMax, shiftColumnLength));
        firstColumn = (firstColumn + lastColumn - lastColumnPrev + 5).clamp(0, max(0, shiftColumnLength - lastColumn + firstColumn));
      }
      if(lastRow - firstRow != _rowCountMin){
        var lastRowPrev = lastRow;
        lastRow  = (lastRow - 8).clamp(_rowCountMin, max(_rowCountMax, shiftRowLength));
        firstRow = (firstRow + lastRow - lastRowPrev + 8).clamp(0, max(0, shiftRowLength - lastRow + firstRow));
      }
    }else{
      if(lastColumn - firstColumn != _columnCountMax){
        var lastColumnPrev = lastColumn;
        lastColumn  = (lastColumn + 5).clamp(0, max(_columnCountMax, shiftColumnLength));
        firstColumn = (firstColumn + lastColumn - lastColumnPrev - 5).clamp(0, _columnCountMax);
      }
      if(lastRow - firstRow != _rowCountMax){
        var lastRowPrev = lastRow;
        lastRow  = (lastRow + 8).clamp(0, max(_rowCountMax, shiftRowLength));
        firstRow = (firstRow + lastRow - lastRowPrev - 8).clamp(0, max(0, shiftRowLength - lastRow + firstRow));
      }
    }
    setState(() {
      
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  スクロールによる上下左右移動の実装
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void moveUpAction(double value){
    setState(() {
      var firstRowPrev = firstRow;
      firstRow = (firstRow - 1).clamp(0, lastRow);
      lastRow  = lastRow + firstRow - firstRowPrev;
    });
  }

  void moveBottomAction(double value){
    setState(() {
      var rowSize = lastRow - firstRow;
      var lastRowPrev = lastRow;
      if(rowSize < _shiftTable.assignTable.length){
        lastRow  = (lastRow + 1).clamp(0, _shiftTable.assignTable.length);
        firstRow = firstRow+lastRow-lastRowPrev;
      }else{
        lastRow  = rowSize;
        firstRow = 0;
      }
    });
  } 
  
  void moveRightAction(double value){
    setState(() {
      var columnSize = lastColumn - firstColumn;
      var lastColumnPrev = lastColumn;
      if(columnSize < _shiftTable.assignTable[0].length){
        lastColumn  = (lastColumn + 1).clamp(0, _shiftTable.assignTable[0].length);
        firstColumn = firstColumn+lastColumn-lastColumnPrev;
      }else{
        lastColumn  = columnSize;
        firstColumn = 0;
      }
    });
  } 
  
  void moveLeftAction(double value){
    setState(() {
      var firstColumnPrev = firstColumn;
      firstColumn = (firstColumn - 1).clamp(0, lastColumn);
      lastColumn  = lastColumn + firstColumn - firstColumnPrev;
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  redo undo 機能の実装
  ////////////////////////////////////////////////////////////////////////////////////////////
  void insertBuffer(List<List<int>> table){
    setState(() {
      undoredoCtrl.insertBuffer(table.map((e) => List.from(e).cast<int>()).toList());
      for(int i =0; i < undoredoCtrl.buffer.length; i++){
        print("${undoredoCtrl.buffer.length} ${undoredoCtrl.bufferIndex} ${undoredoCtrl.buffer[i][0][0]}");
      }
    });
  }

  void paintUndoRedo(bool undo){
    setState(() {
      if(undo){
        _shiftTable.requestTable = undoredoCtrl.undo().map((e) => List.from(e).cast<int>()).toList();
      }else{
        _shiftTable.requestTable = undoredoCtrl.redo().map((e) => List.from(e).cast<int>()).toList();
      }
      print("${undoredoCtrl.buffer.length} ${undoredoCtrl.bufferIndex} ${_shiftTable.requestTable[0][0]}");
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  テーブルの要素のビルダー
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  Widget buildColunTitleWidget(int index) {
    
    List<String> weekdayJP = ["月", "火", "水", "木", "金", "土", "日"];
    DateTime     date = _shiftTable.shiftDateRange[0].start.add(Duration(days: index));
    Text         day, weekday;

    if(date.weekday == 6){
      day     = Text('${date.day}', style: MyFont.tableTitleStyle(Colors.blue)); 
      weekday = Text(weekdayJP[date.weekday - 1], style: MyFont.tableTitleStyle(Colors.blue));
    }else if(date.weekday == 7){
      day     = Text('${date.day}', style: MyFont.tableTitleStyle(Colors.red)); 
      weekday = Text(weekdayJP[date.weekday - 1], style: MyFont.tableTitleStyle(Colors.red));
    }else{
      day     = Text('${date.day}', style: MyFont.tableTitleStyle(Colors.black)); 
      weekday = Text(weekdayJP[date.weekday - 1], style: MyFont.tableTitleStyle(Colors.black));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          day,
          weekday
        ]
      ),
    );
  }

  Widget buildRowTitleWidget(BuildContext context, int index){
    return Padding(
      padding: const EdgeInsets.only(right: 5, bottom: 2.0),
      child: Text(_shiftTable.timeDivs[index].name, style: MyFont.tableTitleStyle(Colors.black), textHeightBehavior: MyFont.defaultBehavior),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  作成したシフト表をFirebaseへ登録
  ////////////////////////////////////////////////////////////////////////////////////////////

  void registerShitTable() async{

    // ShiftTable shiftTable = _shiftTable;

    // FirebaseFirestore firestore = FirebaseFirestore.instance;
    // FirebaseAuth      auth      = FirebaseAuth.instance;

    // final User? user = auth.currentUser;
    // final uid = user?.uid;

    // final table = {
    //   'user-id'       : uid,
    //   'name'          : shiftTable.name,
    //   'request-start' : shiftTable.shiftDateRange[1].start,
    //   'request-end'   : shiftTable.shiftDateRange[1].end,
    //   'work-start'    : shiftTable.shiftDateRange[0].start,
    //   'work-end'      : shiftTable.shiftDateRange[0].end,
    //   'time-division' : FieldValue.arrayUnion(List.generate(shiftTable.timeDivs.length, (index) => {
    //     'name' : shiftTable.timeDivs[index].name, 'start-time' : shiftTable.timeDivs[index].startTime, 'end-time' : shiftTable.timeDivs[index].endTime
    //   })),
    //   'assignment'    : shiftTable.requestTable.asMap().map((index, value) => MapEntry(index.toString(), value))
    // };

    // var refarence = await firestore.collection('shift-table').add(table);

    // final request = {
    //   'user-id'       : uid,
    //   'table-refarence' : refarence
    // };

    // await firestore.collection('shift-request').add(request);
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表に塗る色を選択する
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void buildInkChangeModaleWindow(List<String> list) {
    var box = SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: [
                    Container(width: 25, height: 25, decoration: BoxDecoration(color: colorTable[index][0], border: Border.all(color: MyFont.defaultColor))),
                    const SizedBox(width: 30),
                    Text("${list[index]} 人", style: MyFont.defaultStyleBlack13,textAlign: TextAlign.center),
                  ],
                ),
                onTap: () {
                  _inkValue = index;
                  Navigator.of(context).pop();
                },
              ),
              const Divider(thickness: 2)
            ],
          );
        },
      ),
    );
    showModalWindow(context, 0.35, box);
  }

  void buildAutoFillModalWindow(BuildContext context){
    showModalWindow(
      context,
      0.5,
      AutoFillWidget(shiftTable: _shiftTable)
    ).then((value) {
      if(value != null){
        setState(() {});
        insertBuffer(_shiftTable.requestTable);
      }
    });
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
///  シフト表の Auto-Fill 機能のためのクラス (モーダルウィンドウとして使用)
////////////////////////////////////////////////////////////////////////////////////////////

class AutoFillWidget extends StatefulWidget {
  
  final ShiftTable _shiftTable;
  const AutoFillWidget({Key? key, required ShiftTable shiftTable}) : _shiftTable = shiftTable, super(key: key);

  @override
  AutoFillWidgetState createState() => AutoFillWidgetState();
}

class AutoFillWidgetState extends State<AutoFillWidget> {
  
  bool viewHistry = false;
  var selectorsIndex = [0, 0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    print("");
    var table        = widget._shiftTable;
    var timeDivs1List = List.generate(table.timeDivs.length + 1, (index) => (index == 0) ? '全て' : table.timeDivs[index-1].name);
    var timeDivs2List = List.generate(table.timeDivs.length + 1, (index) => (index == 0) ? '-' : table.timeDivs[index-1].name);

    ////////////////////////////////////////////////////////////////////////////////////////////
    /// Auto-Fillの引数の入力UI (viewHistoryがTrueであれば，履歴表示画面を表示)
    ////////////////////////////////////////////////////////////////////////////////////////////
    
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTextButton( weekSelect[selectorsIndex[0]], false, 100, (){ buildSelectorModaleWindow(weekSelect, 0); } ),
              Text("の", style: MyFont.defaultStyleGrey15),
              buildTextButton( weekdaySelect[selectorsIndex[1]], false, 110, (){ buildSelectorModaleWindow(weekdaySelect, 1); }),
              Text("の", style: MyFont.defaultStyleGrey15),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  buildTextButton( timeDivs1List[selectorsIndex[2]], false, 120, (){ buildSelectorModaleWindow(timeDivs1List, 2); }),
                  buildTextButton( timeDivs2List[selectorsIndex[3]], false, 120, (){ buildSelectorModaleWindow(timeDivs2List, 3); }),
                ],
              ),
              Text("の区分は", style: MyFont.defaultStyleGrey15),
              buildTextButton( selectorsIndex[4].toString(), false, 50, (){ buildSelectorModaleWindow(List<String>.generate(10, (index) => index.toString()), 4); }),
              Text("人", style: MyFont.defaultStyleGrey15),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment:  MainAxisAlignment.end,
            children: [
              buildTextButton(
                "OK", false, 60,
                (){
                  var rule = RequestRule(
                    week:      selectorsIndex[0],
                    weekday:   selectorsIndex[1],
                    timeDivs1: selectorsIndex[2],
                    timeDivs2: selectorsIndex[3],
                    request:   selectorsIndex[4]
                  );
                  widget._shiftTable.applyRuleToRequestTable(rule);
                  Navigator.pop(context, rule); // これだけでModalWindowのFuture<dynamic>から返せる
                  setState(() {});
                }
              ),
              const SizedBox(width: 45)
            ],
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Auto-Fill UI作成に使用するテキストボタンを構築
  ////////////////////////////////////////////////////////////////////////////////////////////

  Widget buildTextButton(String text, bool flag, double width, Function action){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: SizedBox(
        width: width,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: MyFont.backgroundColor,
            shadowColor: MyFont.hiddenColor, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: BorderSide(color: (flag) ? MyFont.primaryColor : MyFont.hiddenColor),
          ),
          onPressed: (){ 
            setState(() {
              action();
            });
          },
          child: Text(text, style: MyFont.headlineStyleGreen15)
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  buildTextButtonさらに選択モーダルウィンドウを表示するための実装
  ////////////////////////////////////////////////////////////////////////////////////////////

  void buildSelectorModaleWindow(List<String> list, int resultIndex) {
    var box = SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.maxFinite,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              ListTile(
                title: Text(list[index], style: MyFont.headlineStyleBlack15,textAlign: TextAlign.center),
                onTap: () {
                  selectorsIndex[resultIndex] = index;
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
    showModalWindow(context, 0.35, box);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Auto-Fill条件を登録
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  Widget registerAutoFill(int index, String weekSelect, String weekdaySelect, String timeDivs1Select, String timeDivs2Select,  String assignNumSelect, BuildContext context) {
    return ReorderableDragStartListener(
      key: Key(index.toString()),
      index: index,
      child: Container(
        width: 300,
        height: 80,
        decoration: BoxDecoration(
          color: MyFont.backgroundColor,
          border: Border.all(
            color: MyFont.hiddenColor
          ),
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 170,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(weekSelect,      style: MyFont.defaultStyleGrey13, textHeightBehavior: MyFont.defaultBehavior),
                  Text(' の ',          style: MyFont.defaultStyleGrey13, textHeightBehavior: MyFont.defaultBehavior),
                  Text(weekdaySelect,   style: MyFont.defaultStyleGrey13, textHeightBehavior: MyFont.defaultBehavior),
                  Text(' の ',          style: MyFont.defaultStyleGrey13, textHeightBehavior: MyFont.defaultBehavior),
                  Text(timeDivs1Select, style: MyFont.defaultStyleGrey13, textHeightBehavior: MyFont.defaultBehavior),
                  Text(' - ',           style: MyFont.defaultStyleGrey13, textHeightBehavior: MyFont.defaultBehavior),
                  Text(timeDivs2Select, style: MyFont.defaultStyleGrey13, textHeightBehavior: MyFont.defaultBehavior),
                  Text(' の勤務人数は ',  style: MyFont.defaultStyleGrey13, textHeightBehavior: MyFont.defaultBehavior),
                  Text(assignNumSelect, style: MyFont.defaultStyleGrey13, textHeightBehavior: MyFont.defaultBehavior),
                  Text(' 人',           style: MyFont.defaultStyleGrey13, textHeightBehavior: MyFont.defaultBehavior),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // widget._shiftTable.requestRules.remove(widget._shiftTable.requestRules[index]);
                setState(() {});
              },
              icon: const Icon(Icons.delete, size: 20),
              color: MyFont.hiddenColor,
            ),
          ],
        ),
      ),
    );
  }
}