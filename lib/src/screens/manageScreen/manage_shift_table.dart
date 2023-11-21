////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';


// my package
import 'package:shift/main.dart';
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/dialog.dart';
import 'package:shift/src/mylibs/shift/shift_frame.dart';
import 'package:shift/src/mylibs/shift/shift_table.dart';
import 'package:shift/src/mylibs/shift_editor/shift_table_editor.dart';
import 'package:shift/src/mylibs/shift_editor/shift_response_editor.dart';
import 'package:shift/src/mylibs/shift_editor/coordinate.dart';
import 'package:shift/src/mylibs/undo_redo.dart';
import 'package:shift/src/mylibs/modal_window.dart';
import 'package:shift/src/mylibs/button.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// 全体で使用する変数
////////////////////////////////////////////////////////////////////////////////////////////

double _cellHeight       = 20;
double _cellWidth        = 20;
double _cellSizeMax      = 25;
double _cellSizeMin      = 15;
double _zoomDiv          = 1;
const int _bufferMax     = 50;

bool _enableZoomIn       = true;
bool _enableZoomOut      = true;
int  baseTime            = 8;
int  minTime             = 1;
int  baseConDay          = 2;
Size _screenSize         = const Size(0, 0);
bool _isDark             = false;
List<bool> _displayInfoFlag = [false, false, false, false];

// 自動入力パラメータ
Duration _baseDuration = const Duration(hours: 7);
Duration _minDuration  = const Duration(hours: 4);
int      _baseConDay   = 0;

var inputConDayList = List<String>.generate(31, (index) => "${index+1} 日");

// 最後のデータを保存したかどうか
bool _registered = true;

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト表の最終チェックに使用するページ (勤務人数も指定)
////////////////////////////////////////////////////////////////////////////////////////////

class ManageShiftTableWidget extends ConsumerStatefulWidget {
  
  const ManageShiftTableWidget({Key? key}) : super(key: key);
  
  @override
  ManageShiftTableWidgetState createState() => ManageShiftTableWidgetState();
}

class ManageShiftTableWidgetState extends ConsumerState<ManageShiftTableWidget> {

  UndoRedo<List<List<List<Candidate>>>> undoredoCtrl = UndoRedo(_bufferMax);

  Coordinate? coordinate;

  List<List<List<Candidate>>> shiftTableBuffer = [];  
  late ShiftTable _shiftTable;
  int  _selectedIndex = 0;
  bool _enableResponseEdit    = false;
  int  _inkValue      = 1;

  @override
  Widget build(BuildContext context) {

    _screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top  - MediaQuery.of(context).padding.bottom/2);
    _shiftTable = ref.read(shiftTableProvider).shiftTable;
    _isDark     = ref.read(settingProvider).enableDarkTheme;

    ref.read(settingProvider).loadPreferences();

    if(undoredoCtrl.buffer.isEmpty){
      _registered = true;
      insertBuffer(_shiftTable.shiftTable);
    }
    
    // Firestoreからシフト表に対するシフト希望表を取ってくる           

    return PopScope(
      canPop: false, // 戻るキーの動作で戻ることを一旦防ぐ
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        if(_registered){
          navigator.pop();
        }else{
          final bool shouldPop = await showConfirmDialog( context, ref, "注意", "データが保存されていません\n未登録のデータは破棄されます", "", (){}, false, true);// ダイアログで戻るか確認
          if (shouldPop) {
            navigator.pop(); // 戻るを選択した場合のみpopを明示的に呼ぶ
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(fit: BoxFit.fill, child: Text("[シフト管理画面]  ${_shiftTable.shiftFrame.shiftName}",style: MyStyle.headlineStyleGreen20),),
          bottomOpacity: 2.0,
          elevation: 2.0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: IconButton( 
                icon: const Icon(Icons.info_outline, size: 30, color: MyStyle.primaryColor),
                tooltip: "使い方",
                onPressed: () async {
                  showInfoDialog(ref.read(settingProvider).enableDarkTheme);
                }
              ),
            ),
            // 登録ボタン
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: IconButton(
                icon: const Icon(Icons.cloud_upload_outlined, size: 30, color: MyStyle.primaryColor),
                tooltip: "シフトを登録する",
                onPressed: (){
                  var now = DateTime.now();
                    // リクエスト期間ではないことを確認
                  if(!(now.compareTo(_shiftTable.shiftFrame.shiftDateRange[1].start) >= 0 && now.compareTo(_shiftTable.shiftFrame.shiftDateRange[1].end) <= 0)){
                    // シフト期間ではないことを確認
                    if(!(now.compareTo(_shiftTable.shiftFrame.shiftDateRange[0].start) >= 0 && now.compareTo(_shiftTable.shiftFrame.shiftDateRange[0].end) <= 0)){
                      showConfirmDialog(
                        context, ref, "確認", "このシフトを登録しますか？", "シフトを登録しました", (){
                          _registered = true;
                          _shiftTable.pushShiftTable();
                        }
                      );
                    }else{
                      showConfirmDialog(
                        context, ref, "確認", "現在はシフト期間中です\nこのシフトを登録しますか？", "シフトを登録しました", (){
                          Navigator.pop(context);
                          _shiftTable.pushShiftTable();
                        }
                      );
                    }
                  }else{
                    showAlertDialog(context, ref, "注意", "リクエスト期間内であるため、登録できません", true);
                  }
                }
              ),
            ),
          ],
        ),
      
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ////////////////////////////////////////////////////////////////////////////////////////////
            /// ツールボタン
            ////////////////////////////////////////////////////////////////////////////////////////////
            // height 30 + 16
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildToolButton(
                      Icons.zoom_in,
                      _enableZoomIn,
                      _screenSize.width/8,
                      (){
                        setState(() {
                          zoomIn();
                        });
                      },
                      (){}
                    ),
                    buildToolButton(
                      Icons.zoom_out,
                      _enableZoomOut,
                      _screenSize.width/8,
                      (){
                        setState(() {
                          zoomOut();
                        });
                      },
                      (){}
                    ),
                    buildToolButton(
                      Icons.auto_fix_high_outlined,
                      true,
                      _screenSize.width/8,
                      (){
                        setState(() {
                          buildAutoFillModalWindow(context);
                        });
                      },
                      (){}
                    ),
                    buildToolButton(
                      Icons.filter_alt_outlined,
                      true,
                      _screenSize.width/8,
                      (){
                        setState(() {
                          buildRangeFillModalWindow(context);
                        });
                      },
                      (){}
                    ),
                    buildToolButton(
                      Icons.touch_app_outlined,
                      _enableResponseEdit,
                      _screenSize.width/8,
                      (){
                        setState(() {
                          if(_selectedIndex != 0){
                            _enableResponseEdit = !_enableResponseEdit;
                          }
                          else{
                            showAlertDialog(context, ref, "エラー", "このツールボタンは「シフトリクエスト表示画面」でのみ有効です \n 画面下部の「切り替えボタン」より切り替えからタップして下さい", true);
                          }
                        });
                      },
                      (){
                        setState(() {
                          if(_selectedIndex != 0){
                            buildInkChangeModaleWindow(); 
                            _enableResponseEdit = true;
                          }
                          else{
                            showAlertDialog(context, ref, "エラー", "このツールボタンは「シフトリクエスト表示画面」でのみ有効です \n 画面下部の「切り替えボタン」より切り替えからタップして下さい`", true);
                          }
                        });
                      }
                    ),
                    buildToolButton(
                      Icons.undo,
                      undoredoCtrl.enableUndo(),
                      _screenSize.width/8,
                      (){
                        setState(() {
                          _registered = false;
                          paintUndoRedo(true);
                        });
                      },
                      (){}
                    ),
                    buildToolButton(
                      Icons.redo,
                      undoredoCtrl.enableRedo(),
                      _screenSize.width/8,
                      (){
                        setState(() {
                          _registered = false;
                          paintUndoRedo(false);
                        });
                      },
                      (){}
                    )
                  ],
                ),
              ),
            ),
            
            ////////////////////////////////////////////////////////////////////////////////////////////
            /// メインテーブル
            ////////////////////////////////////////////////////////////////////////////////////////////
            
            (_selectedIndex == 0)
            ? ShiftTableEditor(
              sheetHeight: _screenSize.height * 1.0 - 60 - 30 - 16 - 16,
              sheetWidth:  _screenSize.width,
              cellHeight:  _cellHeight*1,
              cellWidth:   _cellWidth*1,
              titleHeight: _cellHeight*1.5,
              titleWidth:  _cellWidth*3.5,
              onChangeSelect: (p0) async {
                coordinate = p0!;
                setState(() {});
                await buildAssignSelectModaleWindow(p0.column, p0.row);
                setState(() {});
              },
              onInputEnd: (){
                _registered = false;
                insertBuffer(_shiftTable.shiftTable);
              },
              shiftTable: _shiftTable,
              enableEdit: true,
              selected: coordinate,
                isDark: ref.read(settingProvider).enableDarkTheme,
            )
            : ShiftResponseEditor(
              sheetHeight: _screenSize.height * 1.0 - 60 - 30 - 16 - 16,
              sheetWidth:  _screenSize.width,
              cellHeight:  _cellHeight*1,
              cellWidth:   _cellWidth*1,
              titleHeight: _cellHeight*1.5,
              titleWidth:  _cellWidth*3.5,
              onChangeSelect: (p0) async {
                coordinate = p0!;
                if(_enableResponseEdit && _shiftTable.shiftRequests[_selectedIndex-1].requestTable[p0.row][p0.column] == 1){
                  _shiftTable.shiftRequests[_selectedIndex-1].responseTable[p0.row][p0.column] = _inkValue;
                  for(int i = 0; i < _shiftTable.shiftTable[p0.row][p0.column].length; i++){
                    if(_shiftTable.shiftTable[p0.row][p0.column][i].userIndex == _selectedIndex -1){
                      _shiftTable.shiftTable[p0.row][p0.column][i].assign = (_inkValue == 1) ? true : false;
                      break;
                    }
                  }
                  _shiftTable.calcFitness(_baseDuration.inMinutes, _minDuration.inMinutes, _baseConDay);
                }
                setState(() {});
              },
              onInputEnd: (){
                _registered = false;
                insertBuffer(_shiftTable.shiftTable);
              },
              shiftRequest: _shiftTable.shiftRequests[_selectedIndex-1],
              enableEdit: _enableResponseEdit,
              selected: coordinate,
              isDark: ref.read(settingProvider).enableDarkTheme,
            ),
            
            ////////////////////////////////////////////////////////////////////////////////////////////
            /// 切り替えボタン
            ////////////////////////////////////////////////////////////////////////////////////////////
            
            // height : 60 + 16
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildBottomButton(
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("", style: (_selectedIndex == 0) ? MyStyle.headlineStyleGreen13 : MyStyle.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                            Text("      全体      ", style: (_selectedIndex == 0) ? MyStyle.headlineStyleGreen13 : MyStyle.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                            Text("", style: (_selectedIndex == 0) ? MyStyle.headlineStyleGreen13 : MyStyle.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      _selectedIndex == 0,
                      (){
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      (){}
                    ),
                    for(int requesterIndex = 0; requesterIndex < _shiftTable.shiftRequests.length; requesterIndex++)
                    buildBottomButton(
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_shiftTable.shiftRequests[requesterIndex].displayName, style: (_selectedIndex == requesterIndex+1) ? MyStyle.headlineStyleGreen13 : MyStyle.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                            Text("${(_shiftTable.fitness[requesterIndex][1]/60).toStringAsFixed(1)} h (${(_shiftTable.fitness[requesterIndex][0]/60).toStringAsFixed(1)} h)", style: (_selectedIndex == requesterIndex+1) ? MyStyle.headlineStyleGreen13 : MyStyle.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                            Text("${(_shiftTable.fitness[requesterIndex][2]*100).toStringAsFixed(2)} %", style: (_selectedIndex == requesterIndex+1) ? MyStyle.headlineStyleGreen13 : MyStyle.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      _selectedIndex == requesterIndex+1,
                      (){
                        setState(() {
                          _selectedIndex = requesterIndex + 1; _enableResponseEdit = false;
                        });
                      },
                      (){}
                    ),
                    if(_shiftTable.shiftRequests.isEmpty)
                    buildBottomButton(
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("", style: MyStyle.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                            Text("フォロワーがいません", style: MyStyle.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                            Text("", style: MyStyle.defaultStyleGrey13, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      false,
                      (){},
                      (){}
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
  ///  Zoom In / Zoom Out 機能の実装
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void zoomIn(){
    if(_enableZoomIn && _cellHeight < _cellSizeMax){
      _cellHeight += _zoomDiv;
      _cellWidth  += _zoomDiv;
    }
    if(_cellHeight >= _cellSizeMax){
      _enableZoomIn = false;
    }else{
      _enableZoomIn = true;
    }
    if(_cellHeight <= _cellSizeMin){
      _enableZoomOut = false;
    }else{
      _enableZoomOut = true;
    }
  }

  void zoomOut(){
    if(_enableZoomOut && _cellHeight > _cellSizeMin){
      _cellHeight -= _zoomDiv;
      _cellWidth  -= _zoomDiv;
    }
    if(_cellHeight >= _cellSizeMax){
      _enableZoomIn = false;
    }else{
      _enableZoomIn = true;
    }
    if(_cellHeight <= _cellSizeMin){
      _enableZoomOut = false;
    }else{
      _enableZoomOut = true;
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  redo undo 機能の実装
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void insertBuffer(List<List<List<Candidate>>> table){
    setState(() {
      undoredoCtrl.insertBuffer(table.map((e) => List.from(e.map((f) => List.from(f.map((g) => g.copy())).cast<Candidate>()).toList()).cast<List<Candidate>>()).toList());
    });
  }

  void paintUndoRedo(bool undo){
    setState(() {
      if(undo){
        _shiftTable.shiftTable = undoredoCtrl.undo().map((e) => List.from(e.map((f) => List.from(f.map((g) => g.copy())).cast<Candidate>()).toList()).cast<List<Candidate>>()).toList();
      }else{
        _shiftTable.shiftTable = undoredoCtrl.redo().map((e) => List.from(e.map((f) => List.from(f.map((g) => g.copy())).cast<Candidate>()).toList()).cast<List<Candidate>>()).toList();
      }
      _shiftTable.copyshiftTable2ResponseTable();
      _shiftTable.calcFitness(_baseDuration.inMinutes, _minDuration.inMinutes, _baseConDay);
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表に一括入力するときの基本時間を設定する関数
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void buildSetDefaultValueModaleWindow() {
    showModalWindow(
      context,
      0.5,
      buildModalWindowContainer(
        context,
        List<Widget>.generate(24, (index) => Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              Text("${index+1} 時間", style: MyStyle.headlineStyle13,textAlign: TextAlign.center),
            ],
          )
        ),
        0.5,
        (BuildContext context, int index){
          setState(() {});
          baseTime = index+1; 
        },
        title: Text("基本勤務時間の設定", style: MyStyle.headlineStyle15, textAlign: TextAlign.center)
      )
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表に塗る色を選択する
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void buildInkChangeModaleWindow() {
    showModalWindow(
      context,
      0.5,
      buildModalWindowContainer(
        context,
        [
          Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              const Icon(Icons.circle_outlined, size: 30, color: MyStyle.primaryColor), 
              const SizedBox(width: 30),
              Text("非割り当て", style: MyStyle.headlineStyle13,textAlign: TextAlign.center),
            ],
          ),
          Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              const Icon(Icons.circle, size: 30, color: MyStyle.primaryColor),
              const SizedBox(width: 30),
              Text("割り当て", style: MyStyle.headlineStyle13,textAlign: TextAlign.center),
            ],
          )
        ],
        0.5,
        (BuildContext context, int index){
          setState(() {});
          _inkValue = index; 
        }
      )
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表のセルをクリックした時に表示するモーダルウィンドウ
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  Future<dynamic> buildAssignSelectModaleWindow(int column, int row) async {
    return await showModalWindow(
      context,
      0.5,
      InputModalWindowWidget(_shiftTable, column, row)
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///   ChatGPT API を呼び出す関数　（今はChatGPTの精度が悪いので使えない）
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> callChatGPT() async {

    String message = "I would like to create a shift schedule based on the following information. \n\n";

    DateTime startDay = _shiftTable.shiftFrame.shiftDateRange[0].start;
    DateTime endDay   = _shiftTable.shiftFrame.shiftDateRange[0].end;

    message += "<Duration>\n${DateFormat('MM/dd(EEEE)').format(startDay)} ~  ${DateFormat('MM/dd(EEEE)').format(endDay)}\n\n";

    message += "<List of time categories>\n";
    for(int i = 0; i < _shiftTable.shiftFrame.timeDivs.length -1; i++){
      message += "${DateFormat('hh:mm').format(_shiftTable.shiftFrame.timeDivs[i].startTime)} ~ ${DateFormat('hh:mm').format(_shiftTable.shiftFrame.timeDivs[i].endTime)} \n";
    }
    message += "\n";

    message += "<Member's Name> \n";
    for(int i = 0; i < _shiftTable.shiftRequests.length -1; i++){
      message += "${_shiftTable.shiftRequests[i].displayName} \n";
    }

    message += "\nThe following is a list of shift requests for each member.\n";
    for(int i = 0; i < _shiftTable.shiftRequests.length -1; i++){
      message += "[${_shiftTable.shiftRequests[i].displayName}]\n";
      for(var row = 0; row < _shiftTable.shiftRequests[i].requestTable.length; row++){
        for(var column = 0; column < _shiftTable.shiftRequests[i].requestTable[row].length; column++){
          if(_shiftTable.shiftRequests[i].requestTable[row][column] != 0){
            message += "OK,";
          }else{
            message += "NG,";
          }
        }
        message += "\n";
      }
    }

    print(message);

    return;

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
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表自動入力のためのモーダルウィンドウ
  ////////////////////////////////////////////////////////////////////////////////////////////

  void buildAutoFillModalWindow(BuildContext context){
    showModalWindow(
      context,
      0.5,
      AutoFillModalWindowWidget(shiftTable: _shiftTable)
    ).then((value) {
      if(value != null){
        setState(() {});
        _registered = false;
        insertBuffer(_shiftTable.shiftTable);
      }
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表範囲一括入力のためのモーダルウィンドウ
  ////////////////////////////////////////////////////////////////////////////////////////////

  void buildRangeFillModalWindow(BuildContext context){
    showModalWindow(
      context,
      0.5,
      RangeFillModalWindowWidget(shiftTable: _shiftTable)
    ).then((value) {
      if(value != null){
        setState(() {});
        insertBuffer(_shiftTable.shiftTable);
      }
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  画面遷移時に変数をクリアするための関数
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void crearVariables(){
    ref.read(shiftFrameProvider).shiftFrame = ShiftFrame();
    coordinate     = Coordinate(column: 0, row: 0);
    undoredoCtrl   = UndoRedo(_bufferMax);
    _selectedIndex = 0;
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
              title: Text("「シフト管理画面」の使い方", style:  MyStyle.headlineStyleGreen20, textAlign: TextAlign.center),
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
                              child : _displayInfoFlag[0] ? Text("-", style: MyStyle.headlineStyleGreen18) : Text("+", style: MyStyle.headlineStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("シフト表について", style: MyStyle.headlineStyleGreen18),
                          ],
                        ),
                        onPressed: (){
                          _displayInfoFlag[0] = !_displayInfoFlag[0];
                          setState(() {});
                        },
                      ),

                      if(_displayInfoFlag[0])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // How to Edit
                            Text("この画面では、「シフトリクエスト期間」終了後、「シフト表」を編集できます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 20),
                            Text("編集方法", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("各日時に対応するマスをタップすると、その日時を希望者の一覧が表示されます。", style: MyStyle.defaultStyleGrey13),
                            Text("希望者の名前をタップするとその希望者の「割り当て」/「非割り当て」状態にすることができます。", style: MyStyle.defaultStyleGrey13),
                            Text("編集後は、画面右上の「登録」ボタンを押して登録してください。", style: MyStyle.defaultStyleGrey13),
                            Text("注意 : 編集は常に行うことはできますが、「シフトリクエスト期間」終了後にしか登録できません。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(Icons.check_box_outline_blank_rounded, color: MyStyle.hiddenColor, size: 20),
                                    Padding( 
                                      padding: EdgeInsets.only(bottom: 10, left: 5),
                                      child: Icon(Icons.check, color: MyStyle.primaryColor, size: 30),
                                    )
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Text("割り当て状態", style: MyStyle.defaultStyleGrey13),
                                const SizedBox(width: 10),
                                  const Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(Icons.check_box_outline_blank_rounded, color: MyStyle.hiddenColor, size: 20),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 10, left: 5),
                                      child: Icon(Icons.check, color: Colors.transparent, size: 30),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Text("非割り当て状態", style: MyStyle.defaultStyleGrey13),
                              ],
                            ),

                            const SizedBox(height: 20),
                            Text("アイコンについて", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("シフト表の表示されるアイコンは、その日時の割り当て充足率を示すものです。", style: MyStyle.defaultStyleGrey13),
                            Text("アイコンの示す意味は、下記のとおりです。", style: MyStyle.defaultStyleGrey13),
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
                                SizedBox(width: 80, child: Text("0 %", style: MyStyle.defaultStyleGrey13)),
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
                                Text("1 ~ 29 %", style: MyStyle.defaultStyleGrey13)
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
                                SizedBox(width: 80, child: Text("30 ~ 69 %", style: MyStyle.defaultStyleGrey13)),
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
                                Text("70% ~ 99%", style: MyStyle.defaultStyleGrey13),

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
                                    child: Icon(Icons.thumb_up_off_alt_sharp, size: 20, color: MyStyle.primaryColor),
                                  )
                                ),
                                const SizedBox(width: 10),
                                SizedBox(width: 80, child: Text("100 %", style: MyStyle.defaultStyleGrey13)),
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
                                Text("101 % 以上", style: MyStyle.defaultStyleGrey13),
                              ],
                            ),
                            
                            // How to Update
                            const SizedBox(height: 30),
                            Text("登録方法", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.cloud_upload_outlined, size: 24, color: MyStyle.primaryColor),
                                const SizedBox(width: 10),
                                Text("登録ボタン (画面右上)", style: MyStyle.defaultStyleGrey13),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("シフト表の編集内容は、「登録」しない場合、画面遷移時に破棄されます。", style: MyStyle.defaultStyleGrey13),
                            Text("入力したシフト表を「登録」するには、画面右上の「登録ボタン」を押してください。", style: MyStyle.defaultStyleGrey13),
                            Text("登録したシフト表は常にシフト希望者に共有されますが、「シフト表作成者のみ」が変更を加えることができます。", style: MyStyle.defaultStyleGrey13),
                            Text("「シフト期間」開始日までには、必ず登録してください。", style: MyStyle.defaultStyleGrey13),
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
                              child : _displayInfoFlag[1] ? Text("-", style: MyStyle.headlineStyleGreen18) : Text("+", style: MyStyle.headlineStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("ツールボタンについて", style: MyStyle.headlineStyleGreen18),
                          ],
                        ),
                        onPressed: (){
                          _displayInfoFlag[1] = !_displayInfoFlag[1];
                          setState(() {});
                        },
                      ),

                      if(_displayInfoFlag[1])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Zoom Out / In Button
                            Text("「シフト表」上部のツールボタンを用いることで、効率的なシフト表の編集を行うことができます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 20),
                            Text("拡大・縮小ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildToolButton( Icons.zoom_in,  true, _screenSize.width/7, (){}, (){}),
                                const SizedBox(width: 10),
                                buildToolButton( Icons.zoom_out, true, _screenSize.width/7,(){}, (){}),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("シフト表の拡大・縮小ができます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          
                            // Auto Fill Button
                            const SizedBox(height: 10),
                            Text("自動入力ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            buildToolButton( Icons.auto_fix_high_outlined, true, _screenSize.width/7,(){}, (){}),
                            const SizedBox(height: 10),
                            Text("自動でシフト表へ割り当てできます。", style: MyStyle.defaultStyleGrey13),
                            Text("入力前に、ボタン長押しし、自動割り当てを行うための基準となる勤務時間を設定してください。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("(例)8時間を設定 -> 8時間を基準の勤務時間として割り当てを行われる", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("注意1 : 全ての勤務者の希望通過率を基準に自動入力されます。そのため，設定した希望勤務時間に満たない割り当ても生じます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("注意2 : 入力の手間を軽減することを目的としており，質を保証するものではありません。自動入力後，必ずご確認ください。改善案等がございましたら、ぜひご連絡くださいませ。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          
                            // Filterring Input Button
                            const SizedBox(height: 10),
                            Text("フィルタ入力ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            buildToolButton( Icons.filter_alt_outlined, true, _screenSize.width/7, (){}, (){}),
                            const SizedBox(height: 10),
                            Text("「勤務者名」「日時」を指定して、一括でシフト表に入力できます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),

                            // Draw Button                             
                            const SizedBox(height: 10),
                            Text("タッチ入力ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            buildToolButton(Icons.touch_app_outlined, true, _screenSize.width/7, (){}, (){}),
                            const SizedBox(height: 10),
                            Text("細かい1マス単位の編集ができます。", style: MyStyle.defaultStyleGrey13),
                            Text("タップ後に表のマスをなぞることで「割り当て状態」を編集できます。", style: MyStyle.defaultStyleGrey13),
                            Text("「割当て状態」「非割り当て状態」どちらを入力するかは、ボタンを長押しすることで選択できます。", style: MyStyle.defaultStyleGrey13),
                            Text("注意1 : その間、表のスクロールが無効化されます。スクロールが必要な場合は、もう一度「タッチ入力ボタン」をタップし、無効化してください。", style: MyStyle.defaultStyleGrey13),
                            Text("注意2 : 「シフトリクエスト表示中」にのみ使用できます。", style: MyStyle.defaultStyleGrey13),

                            // Redo / Undo Button
                            const SizedBox(height: 10),
                            Text("戻る・進む ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildToolButton( Icons.undo, true, _screenSize.width/7, (){}, (){}),
                                const SizedBox(width: 10),
                                buildToolButton( Icons.redo, true, _screenSize.width/7, (){}, (){})
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("編集したシフト表を「前の状態」や「次の状態」に戻すことができます。", style: MyStyle.defaultStyleGrey13),
                            Text("注意 : 遡れる状態は最大50であり、一度管理者画面を閉じると過去の変更履歴は破棄されます。", style: MyStyle.defaultStyleGrey13),
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
                              child : _displayInfoFlag[2] ? Text("-", style: MyStyle.headlineStyleGreen18) : Text("+", style: MyStyle.headlineStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("シフトリクエスト表について", style: MyStyle.headlineStyleGreen18),
                          ],
                        ),
                        onPressed: (){
                          _displayInfoFlag[2] = !_displayInfoFlag[2];
                          setState(() {});
                        },
                      ),
                      
                      if(_displayInfoFlag[2])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("画面下部の切り替えボタンをタップすることで、「シフト表」と「シフトリクエスト表」を切り替えることができます。", style: MyStyle.defaultStyleGrey13),
                            Text("どちらの画面でもシフト表への割り当てを編集することが可能です。", style: MyStyle.defaultStyleGrey13),
                            
                            const SizedBox(height: 20),
                            Text("アイコンについて", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("シフト表の表示されるアイコンは、「シフトリクエスト表のリクエスト状態」/「割り当て状態」を示すものです。", style: MyStyle.defaultStyleGrey13),
                            Text("アイコンの示す意味は、下記のとおりです。", style: MyStyle.defaultStyleGrey13),
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
                                    child: Icon(Icons.circle_outlined, size: 20, color: MyStyle.primaryColor)
                                  )
                                ),
                                const SizedBox(width: 10),
                                SizedBox(width: 100, child: Text("リクエスト状態", style: MyStyle.defaultStyleGrey13)),
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
                                Text("非リクエスト状態", style: MyStyle.defaultStyleGrey13)
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
                                    child: Icon(Icons.circle, size: 20, color: MyStyle.primaryColor)
                                  )
                                ),
                                const SizedBox(width: 10),
                                Text("割り当て状態", style: MyStyle.defaultStyleGrey13),
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
                  child: Text('閉じる', style: MyStyle.headlineStyleGreen13),
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
  final int column;
  final int row;

  const InputModalWindowWidget(this.shiftTable, this.column, this.row, {Key? key}) : super(key: key);

  @override
  InputModalWindowWidgetState createState() => InputModalWindowWidgetState();
}

class InputModalWindowWidgetState extends State<InputModalWindowWidget> {

  @override
  Widget build(BuildContext context) {

    DateTime     date = widget.shiftTable.shiftFrame.shiftDateRange[0].start.add(Duration(days: widget.column));
    List<String> weekdayJP = ["月", "火", "水", "木", "金", "土", "日"];
    Text         dateText;
    
    if(date.weekday == 6){
      dateText = Text('${date.day} (${weekdayJP[date.weekday - 1]})', style: MyStyle.tableTitleStyle(Colors.blue, 15)); 
    }else if(date.weekday == 7){
      dateText = Text('${date.day} (${weekdayJP[date.weekday - 1]})', style: MyStyle.tableTitleStyle(Colors.red, 15)); 
    }else{
      dateText = Text('${date.day} (${weekdayJP[date.weekday - 1]})', style: MyStyle.tableTitleStyle(null, 15)); 
    }

    int assignNum = 0;
    for(int i = 0; i < widget.shiftTable.shiftTable[widget.row][widget.column].length; i++){
      if(widget.shiftTable.shiftTable[widget.row][widget.column][i].assign){
        assignNum++;
      }
    }

    return SizedBox(
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
                  Text(widget.shiftTable.shiftFrame.timeDivs[widget.row].name, style: MyStyle.tableTitleStyle(null, 15)),
                  const SizedBox(width: 20),
                  Text("$assignNum / ${widget.shiftTable.shiftFrame.assignTable[widget.row][widget.column]} 人", style: MyStyle.tableTitleStyle(null, 15)),
                ],
              ),
            ),
          ),
          (widget.shiftTable.shiftTable[widget.row][widget.column].isEmpty)
          ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Text("リクエストしているユーザがいません", style: MyStyle.defaultStyleRed15, textAlign: TextAlign.center),
          )
          : SizedBox(
            height: MediaQuery.of(context).size.height * 0.5 - 50 - MediaQuery.of(context).padding.bottom - 23,  
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.shiftTable.shiftTable[widget.row][widget.column].length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [            
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(widget.shiftTable.shiftRequests[widget.shiftTable.shiftTable[widget.row][widget.column][index].userIndex].displayName, style: MyStyle.headlineStyle15, textAlign: TextAlign.center)),
                          const SizedBox(width: 30),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.check_box_outline_blank_rounded, color: MyStyle.hiddenColor, size: 20),
                              (widget.shiftTable.shiftTable[widget.row][widget.column][index].assign)
                              ? const Padding(
                                  padding: EdgeInsets.only(bottom: 10, left: 5),
                                  child: Icon(Icons.check, color: MyStyle.primaryColor, size: 30),
                                )
                              : const Padding(
                                  padding: EdgeInsets.only(bottom: 10, left: 5),
                                  child: Icon(Icons.check, color: Colors.transparent, size: 30),
                                ),
                            ],
                          )
                        ]
                      ),
                      onTap: () {
                        setState(() {
                          widget.shiftTable.shiftTable[widget.row][widget.column][index].assign = !widget.shiftTable.shiftTable[widget.row][widget.column][index].assign;
                          widget.shiftTable.shiftRequests[widget.shiftTable.shiftTable[widget.row][widget.column][index].userIndex].responseTable[widget.row][widget.column] = (widget.shiftTable.shiftTable[widget.row][widget.column][index].assign) ? 1 : 0;
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
        var modalHeight  = _screenSize.height * 0.5;
        var modalWidth   = _screenSize.width - 20 - _screenSize.width * 0.1;
        var paddingHeght = modalHeight * 0.04;
        var buttonHeight = modalHeight * 0.16;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: _screenSize.width * 0.04),
          child: SizedBox(
            height: modalHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("基本勤務時間", style: MyStyle.headlineStyleGreen18),
                          buildTimePicker(DateTime(1,1,1,0,0).add(_baseDuration), DateTime(1,1,1,0,15), DateTime(1,1,1,23,45), 15, (DateTime val){ _baseDuration = val.difference(DateTime(1,1,1,0,0));}),
                        ],
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("最短勤務時間", style: MyStyle.headlineStyleGreen18),
                          buildTimePicker(DateTime(1,1,1,0,0).add(_minDuration), DateTime(1,1,1,0,15), DateTime(1,1,1,23,45), 15, (DateTime val){ _minDuration = val.difference(DateTime(1,1,1,0,0));}),
                        ],
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text("連続勤務日数", style: MyStyle.headlineStyleGreen18),
                          SizedBox(
                            height: 40,
                            width: _screenSize.width / 4,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shadowColor: MyStyle.hiddenColor, 
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: const BorderSide(color: MyStyle.hiddenColor),
                              ),
                              onPressed: () async {
                                buildInputBaseConDayModaleWindow();
                              },
                              child: Text(inputConDayList[_baseConDay], style: MyStyle.headlineStyleGreen18)
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
                      child: buildTextButton(
                        "自動アサイン", true, modalWidth, buttonHeight,
                        (){
                          setState(() {
                            widget._shiftTable.autoFill(_baseDuration.inMinutes, _minDuration.inMinutes, _baseConDay);
                            widget._shiftTable.calcFitness( _baseDuration.inMinutes, _minDuration.inMinutes, _baseConDay);
                            Navigator.pop(context, true); // これだけでModalWindowのFuture<dynamic>から返せる
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
      width: _screenSize.width / 4,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shadowColor: MyStyle.hiddenColor, 
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: MyStyle.hiddenColor),
        ),
        onPressed: () async {
          await showModalWindow(
            context,
            0.4,
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.maxFinite,
              child: Theme(
                data: _isDark ? ThemeData.dark() : ThemeData.light(),
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
        child: Text('${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}', style: MyStyle.headlineStyleGreen18)
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
              Text(inputConDayList[index], style: MyStyle.headlineStyle13,textAlign: TextAlign.center),
            ],
          )
        ),
        0.5,
        (BuildContext context, int index){
          setState(() {});
          _baseConDay = index; 
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
    var requesterList = List.generate(shiftTable.shiftRequests.length + 1, (index) => (index == 0) ? '全員' : shiftTable.shiftRequests[index-1].displayName);
   
    ///////////////////////////////////////////////////////////////////////////////////////////
    /// Auto-Fillの引数の入力UI (viewHistoryがTrueであれば，履歴表示画面を表示)
    ////////////////////////////////////////////////////////////////////////////////////////////
    
    return LayoutBuilder(
      builder: (context, constraints) {
        
        var modalHeight  = _screenSize.height * 0.5;
        var modalWidth   = _screenSize.width - 20 - _screenSize.width * 0.1;
        var paddingHeght = modalHeight * 0.04;
        var buttonHeight = modalHeight * 0.16;
        var widgetHeight = buttonHeight + paddingHeght * 2;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: _screenSize.width * 0.04),
          child: SizedBox(
            height: modalHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: SizedBox(
                        child: buildTextButton(
                          requesterList[selectorsIndex[5]],
                          false,
                          modalWidth,
                          buttonHeight,
                          (){
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
                        child: buildTextButton(
                          weekSelect[selectorsIndex[0]],
                          false,
                          modalWidth * (100 / 330),
                          buttonHeight,
                          (){
                            setState(() {
                              buildSelectorModaleWindow(weekSelect, 0);
                            });
                          }
                        )
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("の", style: MyStyle.defaultStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: buildTextButton(
                        weekdaySelect[selectorsIndex[1]],
                        false,
                        modalWidth * (100 / 330),
                        buttonHeight,
                        (){
                          setState(() {
                            buildSelectorModaleWindow(weekdaySelect, 1);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("の", style: MyStyle.defaultStyleGrey13))),
                    SizedBox(height: widgetHeight, width: modalWidth * (100 / 330))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: buildTextButton(
                        timeDivs1List[selectorsIndex[2]],
                        false,
                        modalWidth * (100 / 330),
                        buttonHeight,
                        (){
                          setState(() {
                            buildSelectorModaleWindow(timeDivs1List, 2);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("~", style: MyStyle.defaultStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: buildTextButton(
                        timeDivs2List[selectorsIndex[3]],
                        false,
                        modalWidth * (100 / 330),
                        buttonHeight,
                        (){
                          setState(() {
                            buildSelectorModaleWindow(timeDivs2List, 3);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (50 / 330), child: Center(child: Text("の区分は", style: MyStyle.defaultStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: buildIconButton(
                        (selectorsIndex[4] == 1) ? const Icon(Icons.circle_outlined, size: 20, color: MyStyle.primaryColor) : const Icon(Icons.clear, size: 20, color: Colors.red),
                        false,
                        modalWidth * (65 / 330), buttonHeight,
                        (){
                          setState(() {
                            buildSelectorModaleWindow(List<Icon>.generate(2, (index) => (index == 1) ? const Icon(Icons.circle_outlined, size: 20, color: MyStyle.primaryColor) : const Icon(Icons.clear, size: 20, color: Colors.red)), 4);
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
                      child: buildTextButton(
                        "一括入力", true, modalWidth, buttonHeight,
                        (){
                          setState(() {
                            var rule = ShiftTableRule(
                              week:      selectorsIndex[0],
                              weekday:   selectorsIndex[1],
                              timeDivs1: selectorsIndex[2],
                              timeDivs2: selectorsIndex[3],
                              response:  selectorsIndex[4],
                              requester: selectorsIndex[5]
                            );
                            widget._shiftTable.applyRuleToShift(rule);
                            Navigator.pop(context, rule); // これだけでModalWindowのFuture<dynamic>から返せる
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