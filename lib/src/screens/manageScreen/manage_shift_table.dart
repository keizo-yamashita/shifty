////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';

// my package
import 'package:shift/main.dart';
import 'package:shift/src/components/style/pop_icons.dart';
import 'package:shift/src/components/shift/shift_request.dart';
import 'package:shift/src/components/form/shift_editor/editor_appbar.dart';
import 'package:shift/src/components/style/style.dart';
import 'package:shift/src/components/form/utility/dialog.dart';
import 'package:shift/src/components/shift/shift_frame.dart';
import 'package:shift/src/components/shift/shift_table.dart';
import 'package:shift/src/components/form/shift_editor/table.dart';
import 'package:shift/src/components/form/shift_editor/table_title.dart';
import 'package:shift/src/components/form/shift_editor/coordinate.dart';
import 'package:shift/src/components/undo_redo.dart';
import 'package:shift/src/components/form/utility/modal_window.dart';
import 'package:shift/src/components/form/utility/button.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// 全体で使用する変数
////////////////////////////////////////////////////////////////////////////////////////////

// editor のセルサイズ設定
double cellHeight     = 20;
double cellWidth      = 20;
double titleMargin    = 3;
double cellSizeMax    = 30;
double cellSizeMin    = 10;
double zoomDiv        = 1;
int    bufferMax      = 50;

// editor の設定変数
bool enableZoomIn          = true;
bool enableZoomOut         = true;
Size screenSize            = const Size(0, 0);
bool isDark                = false;
List<bool> displayInfoFlag = [true, true, true];

// 自動入力パラメータ
Duration baseDuration       = const Duration(hours: 7);
Duration minDuration        = const Duration(hours: 4);
int      baseConDay         = 0;
var inputConDayList         = List<String>.generate(31, (index) => "${index+1} 日");

int  requestInputValue  = 1;
bool registered         = true;

////////////////////////////////////////////////////////////////////////////////////////////
/// シフトの作成・最終チェックに使用するページ (勤務人数も指定)
////////////////////////////////////////////////////////////////////////////////////////////

class ManageShiftTableWidget extends ConsumerStatefulWidget {
  
  const ManageShiftTableWidget({Key? key}) : super(key: key);
  
  @override
  ManageShiftTableWidgetState createState() => ManageShiftTableWidgetState();
}

class ManageShiftTableWidgetState extends ConsumerState<ManageShiftTableWidget> {

  // undo / redo
  UndoRedo<List<List<List<Candidate>>>> undoredoCtrl = UndoRedo(bufferMax);
  List<List<List<Candidate>>>           shiftTableBuffer = [];  
  
  // selected corrdinate
  Coordinate?     selectedCoodinate;
  late ShiftTable shiftTable;
  int             selectedIndex      = 0;
  bool            enableResponseEdit = false;
  GlobalKey       editorKey          = GlobalKey<TableEditorState>();

  @override
  Widget build(BuildContext context) {

    // 画面サイズの取得
    screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top  - MediaQuery.of(context).padding.bottom);

    // Provider 処理
    shiftTable = ref.read(shiftTableProvider).shiftTable;
    isDark     = ref.read(settingProvider).enableDarkTheme;
    ref.read(settingProvider).loadPreferences();

    if(undoredoCtrl.buffer.isEmpty){
      registered = true;
      insertBuffer(shiftTable.shiftTable);
    }
    
    int columnLength = shiftTable.shiftFrame.getDateLen();
    int rowLength    = shiftTable.shiftFrame.getTimeDivsLen();

    // Firestoreからシフト表に対するシフト希望表を取ってくる           
    return EditorAppBar(
      context: context,
      ref: ref, 
      registered: registered,
      title: "[シフト管理画面]  ${shiftTable.shiftFrame.shiftName}",
      handleInfo: (){
        showInfoDialog(isDark);
      },
      handleRegister: (){
        var now = DateTime.now();
        // リクエスト期間ではないことを確認
        if(!(now.compareTo(shiftTable.shiftFrame.dateTerm[1].start) >= 0 && now.compareTo(shiftTable.shiftFrame.dateTerm[1].end) <= 0)){
          if(registered){
            showAlertDialog(context, ref, "注意", "シフトは変更されていないため、登録できません。", true,);
          }else{
            // シフト期間ではないことを確認
            if(!(now.compareTo(shiftTable.shiftFrame.dateTerm[0].start) >= 0 && now.compareTo(shiftTable.shiftFrame.dateTerm[0].end) <= 0)){
              showConfirmDialog(
                context, ref, "確認", "このシフトを登録しますか？", "シフトを登録しました。", (){
                  registered = true;
                  shiftTable.pushShiftTable();
                },
                true,
                false,
              );
            }else{
              showConfirmDialog(
                context, ref, "確認", "現在はシフト期間中です\nこのシフトを登録しますか？", "シフトを登録しました。", (){
                  registered = true;
                  shiftTable.pushShiftTable();
                },
                true,
                false,
              );
            }
          }
        }else{
          showAlertDialog(context, ref, "注意", "リクエスト期間内であるため、登録できません。", true,);
        }
      },
      content: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ////////////////////////////////////////////////////////////////////////////////////////////
              /// ツールボタン
              ////////////////////////////////////////////////////////////////////////////////////////////
              // height 30 + 16
              Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 2.0, left: 2.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ToolButton(icon: Icons.zoom_in,                pressEnable: enableZoomIn,              width: screenSize.width/8, onPressed: handleZoomIn,),
                    ToolButton(icon: Icons.zoom_out,               pressEnable: enableZoomOut,             width: screenSize.width/8, onPressed: handleZoomOut,),
                    ToolButton(icon: Icons.auto_fix_high_outlined, pressEnable: true,                      width: screenSize.width/8, onPressed: handleAutoFill,),
                    ToolButton(icon: Icons.filter_alt_outlined,    pressEnable: true,                      width: screenSize.width/8, onPressed: handleRangeFill,),
                    ToolButton(icon: Icons.touch_app_outlined,     pressEnable: selectedIndex!=0, offEnable: !enableResponseEdit, width: screenSize.width/8, onPressed: handleTouchEdit, onLongPressed: handleChangeInputValue,),
                    ToolButton(icon: Icons.undo,                   pressEnable: undoredoCtrl.enableUndo(), width: screenSize.width/8, onPressed: handleUndo,),
                    ToolButton(icon: Icons.redo,                   pressEnable: undoredoCtrl.enableRedo(), width: screenSize.width/8, onPressed: handleRedo,),
                  ],
                ),
              ),
              
              ////////////////////////////////////////////////////////////////////////////////////////////
              /// メインテーブル
              ////////////////////////////////////////////////////////////////////////////////////////////
              
              (selectedIndex == 0)
              ?
              TableEditor(
                editorKey:   editorKey,
                tableHeight: screenSize.height * 1.0 - 45 - 55,
                tableWidth:  screenSize.width,
                cellHeight:  cellHeight,
                cellWidth:   cellWidth,
                titleHeight: cellHeight*2,
                titleWidth:  cellWidth*3.5,
                titleMargin: titleMargin,
                onChangeSelect: (p0) async {
                  selectedCoodinate = p0!;
                  setState(() {});
                  buildAssignSelectModaleWindow(p0.column, p0.row);
                  setState(() {});
                },
                onInputEnd: null,
                enableEdit: false,
                selected: selectedCoodinate,
                isDark: isDark,
                columnTitles: getColumnTitles(cellHeight*2, cellWidth, shiftTable.shiftFrame.dateTerm[0].start, shiftTable.shiftFrame.dateTerm[0].end, isDark),
                rowTitles:    getRowTitles(cellHeight, cellWidth*3.5, shiftTable.shiftFrame.timeDivs, isDark),
                cells: List<List<Widget>>.generate(
                  rowLength, 
                  (i){
                    return List.generate(
                      columnLength,
                      (j){
                        return shiftCell( i, j, shiftTable.shiftFrame.assignTable[i][j] != 0, j == selectedCoodinate?.column && i == selectedCoodinate?.row);
                      }
                    );
                  },
                ),
              )
              : TableEditor(
                editorKey:   editorKey,
                tableHeight: screenSize.height * 1.0 - 45 - 55,
                tableWidth:  screenSize.width,
                cellHeight:  cellHeight,
                cellWidth:   cellWidth,
                titleHeight: cellHeight*2,
                titleWidth:  cellWidth*3.5,
                titleMargin: titleMargin,
                onChangeSelect: (p0) async {
                  selectedCoodinate = p0!;
                  if(enableResponseEdit && shiftTable.requests[selectedIndex-1].reqTable[p0.row][p0.column] == 1){
                    shiftTable.requests[selectedIndex-1].respTable[p0.row][p0.column] = requestInputValue;
                    for(int i = 0; i < shiftTable.shiftTable[p0.row][p0.column].length; i++){
                      if(shiftTable.shiftTable[p0.row][p0.column][i].userIndex == selectedIndex -1){
                        shiftTable.shiftTable[p0.row][p0.column][i].assign = (requestInputValue == 1) ? true : false;
                        break;
                      }
                    }
                    shiftTable.calcFitness(baseDuration.inMinutes, minDuration.inMinutes, baseConDay);
                  }
                  setState(() {});
                },
                onInputEnd: (){
                  registered = false;
                  insertBuffer(shiftTable.shiftTable);
                },
                columnTitles: getColumnTitles(cellHeight*2, cellWidth, shiftTable.shiftFrame.dateTerm[0].start, shiftTable.shiftFrame.dateTerm[0].end, isDark),
                rowTitles: getRowTitles(cellHeight, cellWidth*3.5, shiftTable.shiftFrame.timeDivs, isDark),
                cells: List<List<Widget>>.generate(
                  rowLength, 
                  (i){
                    return List.generate(
                      columnLength,
                      (j){
                        return responseCell( i, j, selectedIndex-1, shiftTable.shiftFrame.assignTable[i][j] != 0, j == selectedCoodinate?.column && i == selectedCoodinate?.row);
                      }
                    );
                  },
                ),
                enableEdit: enableResponseEdit,
                selected: selectedCoodinate,
                isDark: isDark,
              ),
              
              ////////////////////////////////////////////////////////////////////////////////////////////
              /// 切り替えボタン
              ////////////////////////////////////////////////////////////////////////////////////////////
              
              // height : 55
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(right: 5.0, left: 5.0, top: 15.0, bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      BottomButton(
                        content: Text("      全体      ", style: (selectedIndex == 0) ? Styles.defaultStyleGreen13 : Styles.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                        enable: selectedIndex == 0,
                        width: 100,
                        height: 40,
                        onPressed: (){
                          setState(() {
                            selectedIndex = 0;
                          });
                        },
                      ),
                      for(int requesterIndex = 0; requesterIndex < shiftTable.requests.length; requesterIndex++)
                      BottomButton(
                        content: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(shiftTable.requests[requesterIndex].displayName, style: (selectedIndex == requesterIndex+1) ? Styles.defaultStyleGreen13 : Styles.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                            Text("${(shiftTable.fitness[requesterIndex][1]/60).toStringAsFixed(1)} h / ${(shiftTable.fitness[requesterIndex][0]/60).toStringAsFixed(1)} h ( ${(shiftTable.fitness[requesterIndex][2]*100).toStringAsFixed(1)} % )", style: (selectedIndex == requesterIndex+1) ? Styles.defaultStyleGreen10 : Styles.defaultStyleGrey10, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                        enable: selectedIndex == requesterIndex+1,
                        width: 150,
                        height: 40,
                        onPressed: (){
                          setState(() {
                            selectedIndex = requesterIndex + 1; enableResponseEdit = false;
                          });
                        },
                      ),
                      if(shiftTable.requests.isEmpty)
                      BottomButton(
                        content: Text("フォロワーがいません", style: Styles.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                        enable: false,
                        width: 150,
                        height: 40
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Cell
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  // Matrix Cell Class Instance
  Widget shiftCell(int row, int column, bool editable, bool selected) {

    int assignNum = 0;
    for(int i = 0; i < shiftTable.shiftTable[row][column].length; i++){
      if(shiftTable.shiftTable[row][column][i].assign){
        assignNum++;
      }
    }

    var value = (assignNum / shiftTable.shiftFrame.assignTable[row][column]);

    Icon cellValue = Icon(PopIcons.ok, size: 14 * cellWidth / 20, color: Styles.primaryColor);
    if(value == 0){
      cellValue = Icon(PopIcons.cancel, size: 14 * cellWidth / 20, color: Colors.red); 
    }
    else if(value < 0.3){
      cellValue = Icon(PopIcons.cancel, size: 14 * cellWidth / 20, color: Colors.yellow[800]); 
    }
    else if(value < 0.7){
      cellValue = Icon(PopIcons.attention_alt, size: 14 * cellWidth / 20, color: Colors.red);
    }
    else if(value < 1.0){
      cellValue = Icon(PopIcons.attention_alt, size: 14 * cellWidth / 20, color: Colors.yellow[800]);
    }
    else if(value > 1.0){
      cellValue = Icon(PopIcons.ok, size: 14 * cellWidth / 20, color: Colors.yellow[800]);
    }
    
    Color cellColor =  selected ? cellValue.color!.withAlpha(150) : cellValue.color!.withAlpha(50);
    var cellBoaderWdth = 1.0;

    return Container(
      width: cellWidth,
      height: cellHeight,
      decoration: BoxDecoration(
        border: Border(
          top:    row == 0 ? BorderSide(width: cellBoaderWdth, color: Colors.grey) : BorderSide.none,
          bottom: BorderSide(width: cellBoaderWdth, color: Colors.grey),
          left:   column == 0 ? BorderSide(width: cellBoaderWdth, color: Colors.grey) : BorderSide.none,
          right:  BorderSide(width: cellBoaderWdth, color: Colors.grey),
        ),
        color: cellColor
      ),
      child: editable
      ? Center(child: SizedBox(width: cellWidth, height: cellHeight, child: cellValue))
      : SizedBox(width: cellWidth, height: cellHeight, child: CustomPaint(painter: DiagonalLinePainter(Colors.grey)))
    );
  }

    
  // Matrix Cell Class Instance
  Widget responseCell(int row, int column, int responseIndex,  bool editable, bool selected) {

    ShiftRequest shiftRequest = shiftTable.requests[responseIndex];
    var value = editable ? shiftRequest.reqTable[row][column] : 0;
    Icon cellValue;
    Color cellColor;

    if(value == 1){ 
      cellValue = Icon((shiftRequest.respTable[row][column] == 1) ? PopIcons.circle : PopIcons.circle_empty, size: 12 * cellWidth / 20, color: Styles.primaryColor);
      cellColor = Styles.primaryColor;
    }else{
      cellValue = Icon(PopIcons.cancel, size: 12 * cellWidth / 20, color: Colors.red);
      cellColor = Colors.red;
    }

    cellColor = (selected) ? cellColor.withAlpha(100) : cellColor.withAlpha(50);
    var cellBoaderWdth = 1.0;
    return Container(
      width: cellWidth,
      height: cellHeight,
      decoration: BoxDecoration(
        border: Border(
          top:    row == 0 ? BorderSide(width: cellBoaderWdth, color: Colors.grey) : BorderSide.none,
          bottom: BorderSide(width: cellBoaderWdth, color: Colors.grey),
          left:   column == 0 ? BorderSide(width: cellBoaderWdth, color: Colors.grey) : BorderSide.none,
          right:  BorderSide(width: cellBoaderWdth, color: Colors.grey),
        ),
        color: cellColor
      ),
      child: editable
        ? Center(child: SizedBox(width: cellWidth, height: cellHeight,child: cellValue))
        : SizedBox(width: cellWidth, height: cellHeight, child: CustomPaint(painter: DiagonalLinePainter(Colors.grey)))
    );
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Zoom In / Zoom Out 機能の実装
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void zoomIn(){
    if(enableZoomIn && cellHeight < cellSizeMax){
      cellHeight  += zoomDiv;
      cellWidth   += zoomDiv;
    }
    if(cellHeight >= cellSizeMax){
      enableZoomIn = false;
    }else{
      enableZoomIn = true;
    }
    if(cellHeight <= cellSizeMin){
      enableZoomOut = false;
    }else{
      enableZoomOut = true;
    }
  }

  void zoomOut(){
    if(enableZoomOut && cellHeight > cellSizeMin){
      cellHeight  -= zoomDiv;
      cellWidth   -= zoomDiv;
    }
    if(cellHeight >= cellSizeMax){
      enableZoomIn = false;
    }else{
      enableZoomIn = true;
    }
    if(cellHeight <= cellSizeMin){
      enableZoomOut = false;
    }else{
      enableZoomOut = true;
    }
  }

  void handleZoomIn() {
    setState(() {
      zoomIn();
      editorKey = GlobalKey<TableEditorState>();
    });
  }

  void handleZoomOut() {
    setState(() {
      zoomOut();
      editorKey = GlobalKey<TableEditorState>();
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  redo undo 機能の実装
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void insertBuffer(List<List<List<Candidate>>> table){
    undoredoCtrl.insertBuffer(table.map((e) => List.from(e.map((f) => List.from(f.map((g) => g.copy())).cast<Candidate>()).toList()).cast<List<Candidate>>()).toList());
  }

  void callUndoRedo(bool undo){
    setState(() {
      if(undo){
        shiftTable.shiftTable = undoredoCtrl.undo().map((e) => List.from(e.map((f) => List.from(f.map((g) => g.copy())).cast<Candidate>()).toList()).cast<List<Candidate>>()).toList();
      }else{
        shiftTable.shiftTable = undoredoCtrl.redo().map((e) => List.from(e.map((f) => List.from(f.map((g) => g.copy())).cast<Candidate>()).toList()).cast<List<Candidate>>()).toList();
      }
      shiftTable.copyshiftTable2ResponseTable();
      shiftTable.calcFitness(baseDuration.inMinutes, minDuration.inMinutes, baseConDay);
    });
  }

  void handleUndo(){
    setState(() {
      if(undoredoCtrl.enableUndo()){
        registered = false;
        callUndoRedo(true);
      }
    });
  }

  void handleRedo(){
    setState(() {
      if(undoredoCtrl.enableRedo()){
        registered = false;
        callUndoRedo(false);
      }
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表に塗る色を選択する
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void buildChangeInputValueModaleWindow() {
    showModalWindow(
      context,
      0.5,
      buildModalWindowContainer(
        context,
        [
          Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              const Icon(Icons.circle_outlined, size: 30, color: Styles.primaryColor), 
              const SizedBox(width: 30),
              Text("非割り当て", style: Styles.defaultStyle13,textAlign: TextAlign.center),
            ],
          ),
          Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              const Icon(Icons.circle, size: 30, color: Styles.primaryColor),
              const SizedBox(width: 30),
              Text("割り当て", style: Styles.defaultStyle13,textAlign: TextAlign.center),
            ],
          )
        ],
        0.5,
        (BuildContext context, int index){
          setState(() {});
          requestInputValue = index; 
        }
      )
    );
  }

  void handleTouchEdit(){
    setState(() {
      if(selectedIndex != 0){
        editorKey = GlobalKey<TableEditorState>();
        enableResponseEdit = !enableResponseEdit;
      }
      else{
        showAlertDialog(context, ref, "エラー", "このツールボタンは「シフトリクエスト表示画面」でのみ有効です。 \n 画面下部の「切り替えボタン」より切り替えからタップして下さい。", true);
      }
    });
  }
  
  void handleChangeInputValue(){
    setState(() {
      if(selectedIndex != 0){
        buildChangeInputValueModaleWindow(); 
        enableResponseEdit = true;
      }
      else{
        showAlertDialog(context, ref, "エラー", "このツールボタンは「シフトリクエスト表示画面」でのみ有効です。 \n 画面下部の「切り替えボタン」より切り替えからタップして下さい。", true);
      }
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表のセルをクリックした時に表示するモーダルウィンドウ
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void buildAssignSelectModaleWindow(int column, int row) async {
    showModalWindow(
      context,
      0.5,
      InputModalWindowWidget(shiftTable, column, row)
    ).then((value){
      if(value == true){
        setState(() {});
        registered = false;
        insertBuffer(shiftTable.shiftTable);
      }
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///   ChatGPT API を呼び出す関数　（今はChatGPTの精度が悪いので使えない）
  ////////////////////////////////////////////////////////////////////////////////////////////

  // Future<void> callChatGPT() async {

  //   String message = "I would like to create a shift schedule based on the following information. \n\n";

  //   DateTime startDay = _shiftTable.shiftFrame.shiftDateRange[0].start;
  //   DateTime endDay   = _shiftTable.shiftFrame.shiftDateRange[0].end;

  //   message += "<Duration>\n${DateFormat('MM/dd(EEEE)').format(startDay)} ~  ${DateFormat('MM/dd(EEEE)').format(endDay)}\n\n";

  //   message += "<List of time categories>\n";
  //   for(int i = 0; i < _shiftTable.shiftFrame.timeDivs.length -1; i++){
  //     message += "${DateFormat('hh:mm').format(_shiftTable.shiftFrame.timeDivs[i].startTime)} ~ ${DateFormat('hh:mm').format(_shiftTable.shiftFrame.timeDivs[i].endTime)} \n";
  //   }
  //   message += "\n";

  //   message += "<Member's Name> \n";
  //   for(int i = 0; i < _shiftTable.shiftRequests.length -1; i++){
  //     message += "${_shiftTable.shiftRequests[i].displayName} \n";
  //   }

  //   message += "\nThe following is a list of shift requests for each member.\n";
  //   for(int i = 0; i < _shiftTable.shiftRequests.length -1; i++){
  //     message += "[${_shiftTable.shiftRequests[i].displayName}]\n";
  //     for(var row = 0; row < _shiftTable.shiftRequests[i].requestTable.length; row++){
  //       for(var column = 0; column < _shiftTable.shiftRequests[i].requestTable[row].length; column++){
  //         if(_shiftTable.shiftRequests[i].requestTable[row][column] != 0){
  //           message += "OK,";
  //         }else{
  //           message += "NG,";
  //         }
  //       }
  //       message += "\n";
  //     }
  //   }
  //   return;

    // Member:";

    // // Set the OpenAI API key from the .env file.

    // // Start using!
    // OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
    //   model: "gpt-3.5-turbo",
    //   messages: [
    //     const OpenAIChatCompletionChoiceMessageModel(
    //       content: "シフト表を作成してください．",
    //       role:  OpenAIChatMessageRole.user,
    //     ),
    //   ],
    // );
    // print(chatCompletion.choices.first.message);
  // }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表自動入力のためのモーダルウィンドウ
  ////////////////////////////////////////////////////////////////////////////////////////////

  void buildAutoFillModalWindow(BuildContext context){
    showModalWindow(
      context,
      0.5,
      AutoFillModalWindowWidget(shiftTable: shiftTable)
    ).then((value) {
      if(value != null){
        setState(() {});
        registered = false;
        insertBuffer(shiftTable.shiftTable);
      }
    });
  }

  void handleAutoFill(){
    setState(() {
      buildAutoFillModalWindow(context);
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表範囲一括入力のためのモーダルウィンドウ
  ////////////////////////////////////////////////////////////////////////////////////////////

  void buildRangeFillModalWindow(BuildContext context){
    showModalWindow(
      context,
      0.5,
      RangeFillModalWindowWidget(shiftTable: shiftTable)
    ).then((value) {
      if(value != null){
        setState(() {});
        registered = false;
        insertBuffer(shiftTable.shiftTable);
      }
    },);
  }
  
  void handleRangeFill(){
    setState(() {
      buildRangeFillModalWindow(context);
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  画面遷移時に変数をクリアするための関数
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void crearVariables(){
    ref.read(shiftFrameProvider).shiftFrame = ShiftFrame();
    selectedCoodinate     = Coordinate(column: 0, row: 0);
    undoredoCtrl   = UndoRedo(bufferMax);
    selectedIndex = 0;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト管理画面の使い方を説明するための関数
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<int?> showInfoDialog(bool isDarkTheme) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              title: Text("「シフト管理画面」の使い方", style:  Styles.defaultStyleGreen20, textAlign: TextAlign.center),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.95,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // About Shift Table Buttons 
                      const SizedBox(height: 20),
                      TextButton(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                              child : displayInfoFlag[0] ? Text("-", style: Styles.defaultStyleGreen18) : Text("+", style: Styles.defaultStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("シフト表について", style: Styles.defaultStyleGreen18),
                          ],
                        ),
                        onPressed: (){
                          displayInfoFlag[0] = !displayInfoFlag[0];
                          setState(() {});
                        },
                      ),

                      if(displayInfoFlag[0])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // How to Edit
                            Text("この画面では、「シフトリクエスト期間」終了後、「シフト表」を編集できます。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 20),
                            Text("編集方法", style: Styles.defaultStyle18),
                            const SizedBox(height: 10),
                            Text("各日時に対応するマスをタップすると、その日時を希望者の一覧が表示されます。", style: Styles.defaultStyleGrey13),
                            Text("希望者の名前をタップするとその希望者の「割り当て」/「非割り当て」状態にすることができます。", style: Styles.defaultStyleGrey13),
                            Text("編集後は、画面右上の「登録」ボタンを押して登録してください。", style: Styles.defaultStyleGrey13),
                            Text("注意 : 編集は常に行うことはできますが、「シフトリクエスト期間」終了後にしか登録できません。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(Icons.check_box_outline_blank_rounded, color: Styles.hiddenColor, size: 20),
                                    Padding( 
                                      padding: EdgeInsets.only(bottom: 10, left: 5),
                                      child: Icon(Icons.check, color: Styles.primaryColor, size: 30),
                                    )
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Text("割り当て状態", style: Styles.defaultStyleGrey13),
                                const SizedBox(width: 10),
                                  const Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(Icons.check_box_outline_blank_rounded, color: Styles.hiddenColor, size: 20),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10, left: 5),
                                      child: Icon(Icons.check, color: Colors.transparent, size: 30),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Text("非割り当て状態", style: Styles.defaultStyleGrey13),
                              ],
                            ),

                            const SizedBox(height: 20),
                            Text("アイコンについて", style: Styles.defaultStyle18),
                            const SizedBox(height: 10),
                            Text("シフト表の表示されるアイコンは、その日時の割り当て充足率を示すものです。", style: Styles.defaultStyleGrey13),
                            Text("アイコンの示す意味は、下記のとおりです。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all( color: (isDarkTheme) ?Colors.white : Colors.grey),
                                    borderRadius: BorderRadius.circular( 5 )
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.cancel_sharp, size: 20, color: Colors.red)
                                  )
                                ),
                                const SizedBox(width: 10),
                                SizedBox(width: 80, child: Text("0 %", style: Styles.defaultStyleGrey13)),
                                const SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all( color: (isDarkTheme) ?Colors.white : Colors.grey),
                                    borderRadius: BorderRadius.circular( 5 )
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Icon(Icons.cancel_sharp, size: 20, color: Colors.yellow[800])
                                  )
                                ),
                                const SizedBox(width: 10),
                                Text("1 ~ 29 %", style: Styles.defaultStyleGrey13)
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all( color: (isDarkTheme) ?Colors.white : Colors.grey),
                                    borderRadius: BorderRadius.circular( 5 )
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.warning, size: 20, color: Colors.red)
                                  )
                                ),
                                const SizedBox(width: 10),
                                SizedBox(width: 80, child: Text("30 ~ 69 %", style: Styles.defaultStyleGrey13)),
                                const SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all( color: (isDarkTheme) ?Colors.white : Colors.grey),
                                    borderRadius: BorderRadius.circular( 5 )
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Icon(Icons.warning, size: 20, color: Colors.yellow[800])
                                  )
                                ),
                                const SizedBox(width: 10),
                                Text("70% ~ 99%", style: Styles.defaultStyleGrey13),

                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all( color: (isDarkTheme) ?Colors.white : Colors.grey),
                                    borderRadius: BorderRadius.circular( 5 )
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.thumb_up_off_alt_sharp, size: 20, color: Styles.primaryColor),
                                  )
                                ),
                                const SizedBox(width: 10),
                                SizedBox(width: 80, child: Text("100 %", style: Styles.defaultStyleGrey13)),
                                const SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all( color: (isDarkTheme) ?Colors.white : Colors.grey),
                                    borderRadius: BorderRadius.circular( 5 )
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Icon(Icons.thumb_up_off_alt_sharp, size: 20, color: Colors.yellow[800]),
                                  )
                                ),
                                const SizedBox(width: 10),
                                Text("101 % 以上", style: Styles.defaultStyleGrey13),
                              ],
                            ),
                            
                            // How to Update
                            const SizedBox(height: 30),
                            Text("登録方法", style: Styles.defaultStyle18),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.cloud_upload_outlined, size: 24, color: Styles.primaryColor),
                                const SizedBox(width: 10),
                                Text("登録ボタン (画面右上)", style: Styles.defaultStyleGrey13),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("シフト表の編集内容は、「登録」しない場合、画面遷移時に破棄されます。", style: Styles.defaultStyleGrey13),
                            Text("入力したシフト表を「登録」するには、画面右上の「登録ボタン」を押してください。", style: Styles.defaultStyleGrey13),
                            Text("登録したシフト表は常にシフト希望者に共有されますが、「シフト表作成者のみ」が変更を加えることができます。", style: Styles.defaultStyleGrey13),
                            Text("「シフト期間」開始日までには、必ず登録してください。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),

                      // About Tool Buttons 
                      const SizedBox(height: 20),
                      TextButton(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                              child : displayInfoFlag[1] ? Text("-", style: Styles.defaultStyleGreen18) : Text("+", style: Styles.defaultStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("ツールボタンについて", style: Styles.defaultStyleGreen18),
                          ],
                        ),
                        onPressed: (){
                          displayInfoFlag[1] = !displayInfoFlag[1];
                          setState(() {});
                        },
                      ),

                      if(displayInfoFlag[1])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Zoom Out / In Button
                            Text("「シフト表」上部のツールボタンを用いることで、効率的なシフト表の編集を行うことができます。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 20),
                            Text("拡大・縮小ボタン", style: Styles.defaultStyle18),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ToolButton( icon: Icons.zoom_in,  pressEnable: true, width: screenSize.width/7),
                                const SizedBox(width: 10),
                                ToolButton( icon: Icons.zoom_out, pressEnable: true, width: screenSize.width/7),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("シフト表の拡大・縮小ができます。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          
                            // Auto Fill Button
                            const SizedBox(height: 10),
                            Text("自動入力ボタン", style: Styles.defaultStyle18),
                            const SizedBox(height: 10),
                            ToolButton( icon: Icons.auto_fix_high_outlined, pressEnable: true, width: screenSize.width/7),
                            const SizedBox(height: 10),
                            Text("自動でシフト表へ割り当てできます。", style: Styles.defaultStyleGrey13),
                            Text("入力前に、ボタン長押しし、自動割り当てを行うための基準となる勤務時間を設定してください。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("(例)8時間を設定 -> 8時間を基準の勤務時間として割り当てを行われる", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("注意1 : 全ての勤務者の希望通過率を基準に自動入力されます。そのため，設定した希望勤務時間に満たない割り当ても生じます。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("注意2 : 入力の手間を軽減することを目的としており，質を保証するものではありません。自動入力後，必ずご確認ください。改善案等がございましたら、ぜひご連絡くださいませ。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          
                            // Filterring Input Button
                            const SizedBox(height: 10),
                            Text("フィルタ入力ボタン", style: Styles.defaultStyle18),
                            const SizedBox(height: 10),
                            ToolButton( icon: Icons.filter_alt_outlined, pressEnable: true, width: screenSize.width/7),
                            const SizedBox(height: 10),
                            Text("「勤務者名」「日時」を指定して、一括でシフト表に入力できます。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 10),

                            // Draw Button                             
                            const SizedBox(height: 10),
                            Text("タッチ入力ボタン", style: Styles.defaultStyle18),
                            const SizedBox(height: 10),
                            ToolButton(icon: Icons.touch_app_outlined, pressEnable: true, width: screenSize.width/7),
                            const SizedBox(height: 10),
                            Text("細かい1マス単位の編集ができます。", style: Styles.defaultStyleGrey13),
                            Text("タップ後に表のマスをなぞることで「割り当て状態」を編集できます。", style: Styles.defaultStyleGrey13),
                            Text("「割当て状態」「非割り当て状態」どちらを入力するかは、ボタンを長押しすることで選択できます。", style: Styles.defaultStyleGrey13),
                            Text("注意1 : その間、表のスクロールが無効化されます。スクロールが必要な場合は、もう一度「タッチ入力ボタン」をタップし、無効化してください。", style: Styles.defaultStyleGrey13),
                            Text("注意2 : 「シフトリクエスト表示中」にのみ使用できます。", style: Styles.defaultStyleGrey13),

                            // Redo / Undo Button
                            const SizedBox(height: 10),
                            Text("戻る・進む ボタン", style: Styles.defaultStyle18),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ToolButton( icon: Icons.undo, pressEnable: true, width: screenSize.width/7),
                                const SizedBox(width: 10),
                                ToolButton( icon: Icons.redo, pressEnable: true, width: screenSize.width/7)
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("編集したシフト表を「前の状態」や「次の状態」に戻すことができます。", style: Styles.defaultStyleGrey13),
                            Text("注意 : 遡れる状態は最大50であり、一度管理者画面を閉じると過去の変更履歴は破棄されます。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),

                      // About Shift Request View 
                      const SizedBox(height: 20),
                      TextButton(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                              child : displayInfoFlag[2] ? Text("-", style: Styles.defaultStyleGreen18) : Text("+", style: Styles.defaultStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("シフトリクエスト表について", style: Styles.defaultStyleGreen18),
                          ],
                        ),
                        onPressed: (){
                          displayInfoFlag[2] = !displayInfoFlag[2];
                          setState(() {});
                        },
                      ),
                      
                      if(displayInfoFlag[2])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("画面下部の切り替えボタンをタップすることで、「シフト表」と「シフトリクエスト表」を切り替えることができます。", style: Styles.defaultStyleGrey13),
                            Text("どちらの画面でもシフト表への割り当てを編集することが可能です。", style: Styles.defaultStyleGrey13),
                            
                            const SizedBox(height: 20),
                            Text("アイコンについて", style: Styles.defaultStyle18),
                            const SizedBox(height: 10),
                            Text("シフト表の表示されるアイコンは、「シフトリクエスト表のリクエスト状態」/「割り当て状態」を示すものです。", style: Styles.defaultStyleGrey13),
                            Text("アイコンの示す意味は、下記のとおりです。", style: Styles.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all( color: (isDarkTheme) ?Colors.white : Colors.grey),
                                    borderRadius: BorderRadius.circular( 5 )
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.circle_outlined, size: 20, color: Styles.primaryColor)
                                  )
                                ),
                                const SizedBox(width: 10),
                                SizedBox(width: 100, child: Text("リクエスト状態", style: Styles.defaultStyleGrey13)),
                                const SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all( color: (isDarkTheme) ?Colors.white : Colors.grey),
                                    borderRadius: BorderRadius.circular( 5 )
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.clear, size: 20, color: Colors.red)
                                  )
                                ),
                                const SizedBox(width: 10),
                                Text("非リクエスト状態", style: Styles.defaultStyleGrey13)
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all( color: (isDarkTheme) ?Colors.white : Colors.grey),
                                    borderRadius: BorderRadius.circular( 5 )
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(Icons.circle, size: 20, color: Styles.primaryColor)
                                  )
                                ),
                                const SizedBox(width: 10),
                                Text("割り当て状態", style: Styles.defaultStyleGrey13),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('閉じる', style: Styles.defaultStyleGreen13),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        );
      }
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト表全体を自動で埋めるためのモーダルウィンドウクラス
////////////////////////////////////////////////////////////////////////////////////////////


class InputModalWindowWidget extends StatefulWidget {
  
  final ShiftTable shiftTable;
  final int        column;
  final int        row;
  final List<bool> backup = [];

  InputModalWindowWidget(this.shiftTable, this.column, this.row, {Key? key}) : super(key: key);

  @override
  InputModalWindowWidgetState createState() => InputModalWindowWidgetState();
}

class InputModalWindowWidgetState extends State<InputModalWindowWidget> {

  @override
  void initState(){
    super.initState();
    for(int i = 0; i < widget.shiftTable.shiftTable[widget.row][widget.column].length; i++){
      widget.backup.add(widget.shiftTable.shiftTable[widget.row][widget.column][i].assign);
    }
  }

  @override
  Widget build(BuildContext context) {

    DateTime     date = widget.shiftTable.shiftFrame.dateTerm[0].start.add(Duration(days: widget.column));
    List<String> weekdayJP = ["月", "火", "水", "木", "金", "土", "日"];
    Text         dateText;
    
    if(date.weekday == 6){
      dateText = Text('${date.day} (${weekdayJP[date.weekday - 1]})', style: Styles.tableTitleStyle(Colors.blue, 15)); 
    }else if(date.weekday == 7){
      dateText = Text('${date.day} (${weekdayJP[date.weekday - 1]})', style: Styles.tableTitleStyle(Colors.red, 15)); 
    }else{
      dateText = Text('${date.day} (${weekdayJP[date.weekday - 1]})', style: Styles.tableTitleStyle(null, 15)); 
    }

    int assignNum = 0;
    for(int i = 0; i < widget.shiftTable.shiftTable[widget.row][widget.column].length; i++){
      if(widget.shiftTable.shiftTable[widget.row][widget.column][i].assign){
        assignNum++;
      }
    }

    return PopScope(
      canPop: false, // 戻るキーの動作で戻ることを一旦防ぐ
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        bool changed = false;
        for(int i = 0; i < widget.shiftTable.shiftTable[widget.row][widget.column].length; i++){
          if(widget.shiftTable.shiftTable[widget.row][widget.column][i].assign != widget.backup[i]){
            changed = true;
            break; // 変更が見つかったらループを終了
          }
        }
        Navigator.pop(context, changed);
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    dateText,
                    const SizedBox(width: 10),
                    Text(widget.shiftTable.shiftFrame.timeDivs[widget.row].name, style: Styles.tableTitleStyle(null, 15)),
                    const SizedBox(width: 20),
                    Text("$assignNum / ${widget.shiftTable.shiftFrame.assignTable[widget.row][widget.column]} 人", style: Styles.tableTitleStyle(null, 15)),
                  ],
                ),
              ),
            ),
            (widget.shiftTable.shiftTable[widget.row][widget.column].isEmpty)
            ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Text("リクエストしているユーザがいません", style: Styles.defaultStyleRed15, textAlign: TextAlign.center),
            )
            : SizedBox(
              height: MediaQuery.of(context).size.height * 0.5 - 70 - MediaQuery.of(context).padding.bottom,  
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.shiftTable.shiftTable[widget.row][widget.column].length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [            
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(widget.shiftTable.requests[widget.shiftTable.shiftTable[widget.row][widget.column][index].userIndex].displayName, style: Styles.defaultStyle15, textAlign: TextAlign.center)),
                            const SizedBox(width: 30),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.check_box_outline_blank_rounded, color: Styles.hiddenColor, size: 30),
                                (widget.shiftTable.shiftTable[widget.row][widget.column][index].assign)
                                ? const Padding(
                                    padding: EdgeInsets.only(bottom: 5, left: 5),
                                    child: Icon(PopIcons.ok, color: Styles.primaryColor, size: 25),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.only(bottom: 5, left: 5),
                                    child: Icon(PopIcons.ok, color: Colors.transparent, size: 25),
                                  ),
                              ],
                            )
                          ]
                        ),
                        onTap: () {
                          setState(() {
                            widget.shiftTable.shiftTable[widget.row][widget.column][index].assign = !widget.shiftTable.shiftTable[widget.row][widget.column][index].assign;
                            widget.shiftTable.requests[widget.shiftTable.shiftTable[widget.row][widget.column][index].userIndex].respTable[widget.row][widget.column] = (widget.shiftTable.shiftTable[widget.row][widget.column][index].assign) ? 1 : 0;
                          });
                        },
                      ),
                      const Divider(thickness: 2)
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
/// 人，日時を選択して自動で埋めるためのモーダルウィンドウクラス
////////////////////////////////////////////////////////////////////////////////////////////

class AutoFillModalWindowWidget extends StatefulWidget {
  
  final ShiftTable _shiftTable;

  const AutoFillModalWindowWidget({Key? key, required ShiftTable shiftTable}) : _shiftTable = shiftTable, super(key: key);

  @override
  AutoFillModalWindowWidgetState createState() => AutoFillModalWindowWidgetState();
}

class AutoFillModalWindowWidgetState extends State<AutoFillModalWindowWidget> {

  var selectorsIndex = [0, 0, 0];

  @override
  Widget build(BuildContext context) {
   
    ///////////////////////////////////////////////////////////////////////////////////////////
    /// Auto-Fillの引数の入力UI (viewHistoryがTrueであれば，履歴表示画面を表示)
    ////////////////////////////////////////////////////////////////////////////////////////////
    
    return LayoutBuilder(
      builder: (context, constraints) {
        var modalHeight  = screenSize.height * 0.5;
        var modalWidth   = screenSize.width - 20 - screenSize.width * 0.1;
        var paddingHeght = modalHeight * 0.04;
        var buttonHeight = modalHeight * 0.16;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
          child: SizedBox(
            height: modalHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text("シフトの自動割り当て", style: Styles.defaultStyleGrey15, textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("基本勤務時間", style: Styles.defaultStyleGreen15),
                          buildTimePicker(DateTime(1,1,1,0,0).add(baseDuration), DateTime(1,1,1,0,15), DateTime(1,1,1,23,45), 15, (DateTime val){ baseDuration = val.difference(DateTime(1,1,1,0,0));}),
                        ],
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("最短勤務時間", style: Styles.defaultStyleGreen15),
                          buildTimePicker(DateTime(1,1,1,0,0).add(minDuration), DateTime(1,1,1,0,15), DateTime(1,1,1,23,45), 15, (DateTime val){ minDuration = val.difference(DateTime(1,1,1,0,0));}),
                        ],
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("連続勤務日数", style: Styles.defaultStyleGreen15),
                          SizedBox(
                            height: 40,
                            width: screenSize.width / 4,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shadowColor: Styles.hiddenColor, 
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: const BorderSide(color: Styles.hiddenColor),
                              ),
                              onPressed: () async {
                                buildInputBaseConDayModaleWindow();
                              },
                              child: Text(inputConDayList[baseConDay], style: Styles.defaultStyleGreen18)
                            ),
                          )
                        ],
                      )
                    ),
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text: "自動アサイン",
                        enable: true,
                        width: modalWidth,
                        height: buttonHeight,
                        onPressed:(){
                          setState(() {
                            widget._shiftTable.autoFill(baseDuration.inMinutes, minDuration.inMinutes, baseConDay);
                            widget._shiftTable.calcFitness( baseDuration.inMinutes, minDuration.inMinutes, baseConDay);
                            Navigator.pop(context, true);
                          });
                        }
                      ),
                    ),
                  ]
                )
              ],
            ),
          ),
        );
      }
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Auto-Fill UI作成に使用するテキストボタンを構築
  ////////////////////////////////////////////////////////////////////////////////////////////

  Widget buildTimePicker(DateTime init, DateTime min, DateTime max, int interval, Function(DateTime) callback){    
    DateTime temp = init;
    return SizedBox(
      height: 40,
      width: screenSize.width / 4,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shadowColor: Styles.hiddenColor, 
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: Styles.hiddenColor),
        ),
        onPressed: () async {
          await showModalWindow(
            context,
            0.4,
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.maxFinite,
              child: Theme(
                data: isDark ? ThemeData.dark() : ThemeData.light(),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: init,
                  minuteInterval: interval,
                  minimumDate: min,
                  maximumDate: max,
                  onDateTimeChanged: (val){ setState(() { temp = val; callback(val); }); },
                  use24hFormat: true,
                ),
              ),
            )
          );
        },
        child: Text('${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}', style: Styles.defaultStyleGreen18)
      ),
    );
  }

  void buildInputBaseConDayModaleWindow() {
    showModalWindow(
      context,
      0.5,
      buildModalWindowContainer(
        context,
        List<Widget>.generate(assignNumSelect.length, (index) => Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [ 
              Text(inputConDayList[index], style: Styles.defaultStyle13,textAlign: TextAlign.center),
            ],
          )
        ),
        0.5,
        (BuildContext context, int index){
          setState(() {});
          baseConDay = index; 
        }
      )
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  選択モーダルウィンドウを表示するための実装
  ////////////////////////////////////////////////////////////////////////////////////////////

  void buildSelectorModaleWindow(List list, int resultIndex) {
    showModalWindow(
      context,
      0.50,
      buildModalWindowContainer(
        context,
        list,
        0.50,
        (BuildContext context, int index){
          selectorsIndex[resultIndex] = index;
          setState(() {});
        }
      )
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
/// 人，日時を選択して自動で埋めるためのモーダルウィンドウクラス
////////////////////////////////////////////////////////////////////////////////////////////

class RangeFillModalWindowWidget extends StatefulWidget {
  
  final ShiftTable _shiftTable;

  const RangeFillModalWindowWidget({Key? key, required ShiftTable shiftTable}) : _shiftTable = shiftTable, super(key: key);

  @override
  RangeFillModalWindowWidgetState createState() => RangeFillModalWindowWidgetState();
}

class RangeFillModalWindowWidgetState extends State<RangeFillModalWindowWidget> {

  var selectorsIndex = [0, 0, 0, 0, 0, 0];
  
  @override
  Widget build(BuildContext context) {
    
    var shiftTable       = widget._shiftTable;
    var timeDivs1List = List.generate(shiftTable.shiftFrame.timeDivs.length + 1, (index) => (index == 0) ? '全て' : shiftTable.shiftFrame.timeDivs[index-1].name);
    var timeDivs2List = List.generate(shiftTable.shiftFrame.timeDivs.length + 1, (index) => (index == 0) ? '-' : shiftTable.shiftFrame.timeDivs[index-1].name);
    var requesterList = List.generate(shiftTable.requests.length + 1, (index) => (index == 0) ? '全員' : shiftTable.requests[index-1].displayName);
   
    ///////////////////////////////////////////////////////////////////////////////////////////
    /// Auto-Fillの引数の入力UI (viewHistoryがTrueであれば，履歴表示画面を表示)
    ////////////////////////////////////////////////////////////////////////////////////////////
    
    return LayoutBuilder(
      builder: (context, constraints) {
        
        var modalHeight  = screenSize.height * 0.5;
        var modalWidth   = screenSize.width - 20 - screenSize.width * 0.1;
        var paddingHeght = modalHeight * 0.03;
        var buttonHeight = modalHeight * 0.16;
        var widgetHeight = buttonHeight + paddingHeght * 2;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
          child: SizedBox(
            height: modalHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 20,
                    child: Text("シフトの範囲入力", style: Styles.defaultStyleGrey15, textAlign: TextAlign.center),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: SizedBox(
                        child: CustomTextButton(
                          text: requesterList[selectorsIndex[5]],
                          enable: false,
                          width: modalWidth,
                          height: buttonHeight,
                          onPressed: (){
                            setState(() {
                              buildSelectorModaleWindow(requesterList, 5);
                            });
                          }
                        )
                      ),
                    ),
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: SizedBox(
                        child: CustomTextButton(
                          text: weekSelect[selectorsIndex[0]],
                          enable: false,
                          width: modalWidth * (100 / 330),
                          height: buttonHeight,
                          onPressed: (){
                            setState(() {
                              buildSelectorModaleWindow(weekSelect, 0);
                            });
                          }
                        )
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("の", style: Styles.defaultStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text: weekdaySelect[selectorsIndex[1]],
                        enable: false,
                        width: modalWidth * (100 / 330),
                        height: buttonHeight,
                        onPressed: (){
                          setState(() {
                            buildSelectorModaleWindow(weekdaySelect, 1);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("の", style: Styles.defaultStyleGrey13))),
                    SizedBox(height: widgetHeight, width: modalWidth * (100 / 330))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text: timeDivs1List[selectorsIndex[2]],
                        enable: false,
                        width: modalWidth * (100 / 330),
                        height: buttonHeight,
                        onPressed: (){
                          setState(() {
                            buildSelectorModaleWindow(timeDivs1List, 2);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("~", style: Styles.defaultStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text: timeDivs2List[selectorsIndex[3]],
                        enable: false,
                        width: modalWidth * (100 / 330),
                        height: buttonHeight,
                        onPressed: (){
                          setState(() {
                            buildSelectorModaleWindow(timeDivs2List, 3);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (50 / 330), child: Center(child: Text("の区分は", style: Styles.defaultStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomIconButton(
                        icon: (selectorsIndex[4] == 1) ? const Icon(Icons.circle_outlined, size: 20, color: Styles.primaryColor) : const Icon(Icons.clear, size: 20, color: Colors.red),
                        enable: false,
                        width: modalWidth * (65 / 330),
                        height: buttonHeight,
                        action: (){
                          setState(() {
                            buildSelectorModaleWindow(List<Icon>.generate(2, (index) => (index == 1) ? const Icon(Icons.circle_outlined, size: 20, color: Styles.primaryColor) : const Icon(Icons.clear, size: 20, color: Colors.red)), 4);
                          });
                        }
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text: "範囲入力する",
                        enable: true,
                        width: modalWidth,
                        height: buttonHeight,
                        onPressed: (){
                          setState(() {
                            var rule = ShiftTableRule(
                              week:      selectorsIndex[0],
                              weekday:   selectorsIndex[1],
                              time1:     selectorsIndex[2],
                              time2:     selectorsIndex[3],
                              response:  selectorsIndex[4],
                              requester: selectorsIndex[5] == 0 ? null : selectorsIndex[5]- 1,
                            );
                            widget._shiftTable.applyRuleToShift(rule);
                            Navigator.pop(context, rule);
                            setState(() {});
                          });
                        }
                      ),
                    ),
                  ]
                )
              ],
            ),
          ),
        );
      }
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  buildTextButtonさらに選択モーダルウィンドウを表示するための実装
  ////////////////////////////////////////////////////////////////////////////////////////////

  void buildSelectorModaleWindow(List list, int resultIndex) {
    showModalWindow(
      context,
      0.50,
      buildModalWindowContainer(
        context,
        list,
        0.50,
        (BuildContext context, int index){
          selectorsIndex[resultIndex] = index;
          setState(() {});
        }
      )
    );
  }
}