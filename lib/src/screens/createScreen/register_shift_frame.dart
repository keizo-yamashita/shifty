///////////////////////////////////////////////////////////////////////////////////////////
/// import
///////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// my package
import 'package:shift/src/functions/style.dart';
import 'package:shift/src/functions/dialog.dart';
import 'package:shift/src/functions/undo_redo.dart';
import 'package:shift/src/functions/modal_window.dart';
import 'package:shift/src/functions/shift/shift_frame.dart';
import 'package:shift/src/functions/sing_in/sign_in_provider.dart';
import 'package:shift/src/functions/shift_editor/shift_frame_editor.dart';
import 'package:shift/src/functions/setting_provider.dart';
import 'package:shift/src/functions/shift_editor/coordinate.dart';
import 'package:shift/src/functions/shift/shift_provider.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// 全体で使用する変数
////////////////////////////////////////////////////////////////////////////////////////////

double _cellHeight       = 20;
double _cellWidth        = 20;
double _titleHeight      = 30;
double _titleWidth       = 60;
double _cellSizeMax      = 30;
double _cellSizeMin      = 10;
double _zoomDiv          = 1;
const int _bufferMax     = 50;

bool _enableEdit         = false;
bool _enableZoomIn       = true;
bool _enableZoomOut      = true;
int  _inkValue           = 1;
Size _screenSize         = const Size(0, 0);

List<bool> _displayInfoFlag = [false, false, false, false];

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト表の最終チェックに使用するページ (勤務人数も指定)
////////////////////////////////////////////////////////////////////////////////////////////

class CheckShiftTableWidget extends StatefulWidget {
  
  const CheckShiftTableWidget({Key? key}) : super(key: key);
  
  @override
  State<CheckShiftTableWidget> createState() => CheckShiftTableWidgetState();
}

class CheckShiftTableWidgetState extends State<CheckShiftTableWidget> {

  UndoRedo<List<List<int>>> undoredoCtrl = UndoRedo(_bufferMax);

  Coordinate? coordinate;
  
  ShiftFrame _shiftFrame = ShiftFrame();

  @override
  Widget build(BuildContext context) {
    
    _screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom);
    
    _shiftFrame = Provider.of<ShiftFrameProvider>(context, listen: false).shiftFrame;

    var signInProvider = Provider.of<SignInProvider>(context);

    var settingProvider = Provider.of<SettingProvider>(context, listen: false);
    settingProvider.loadPreferences();

    if(undoredoCtrl.buffer.isEmpty){
      insertBuffer(_shiftFrame.assignTable);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("割り当て人数の設定",style: MyStyle.headlineStyleGreen20),
        bottomOpacity: 2.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton( 
              icon: const Icon(Icons.info_outline, size: 30, color: MyStyle.primaryColor),
              tooltip: "使い方",
              onPressed: () async {
                showInfoDialog(settingProvider.enableDarkTheme);
              }
            ),
          ),
          // 登録ボタン
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: const Icon(Icons.cloud_upload_outlined, size: 30, color: MyStyle.primaryColor),
              tooltip: "シフト表を作成する",
              onPressed: (){
                if(signInProvider.user != null){
                  showConfirmDialog(context, "確認", "このシフト表で作成しますか？", "シフト表を作成しました", (){
                    _shiftFrame.pushShiftFrame();
                    crearVariables();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                }
                else{
                  showAlertDialog(context, "ログインエラー", "未ログイン状態では\n登録できません。\n'ホーム画面'及び'アカウント画面'から\n'ログイン画面'に移動してください。", true);
                }
              }
            ),
          )
        ],
      ),
    
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            
            SizedBox(height: _screenSize.height * 0.02),
            
            ////////////////////////////////////////////////////////////////////////////////////////////
            /// ツールボタン
            /// height : screenSize.height * 0.075
            ////////////////////////////////////////////////////////////////////////////////////////////
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildIconButton( Icons.zoom_in, _enableZoomIn, (){ zoomIn(); }, (){}),
                  buildIconButton( Icons.zoom_out, _enableZoomOut, (){ zoomOut(); }, (){}),
                  buildIconButton( Icons.filter_alt_outlined, true, (){ buildAutoFillModalWindow(context); }, (){}),
                  buildIconButton(
                    Icons.touch_app_outlined, _enableEdit,
                    (){_enableEdit = !_enableEdit;},
                    (){ buildInkChangeModaleWindow();}
                  ),
                  buildIconButton( Icons.undo,  undoredoCtrl.enableUndo(), (){paintUndoRedo(true);}, (){}),
                  buildIconButton( Icons.redo,  undoredoCtrl.enableRedo(), (){paintUndoRedo(false);}, (){}),
                ],
              ),
            ),
            
            SizedBox(height: _screenSize.height * 0.02),
            
            ////////////////////////////////////////////////////////////////////////////////////////////
            /// メインテーブル
            /// height : screenSize.height * 0.075
            ////////////////////////////////////////////////////////////////////////////////////////////
            
            ShiftFrameEditor(
              sheetHeight: _screenSize.height * (1.0 - 0.02 - 0.02) - 30,
              sheetWidth:  _screenSize.width,
              cellHeight:  _cellHeight*1,
              cellWidth:   _cellWidth*1,
              titleHeight: _cellHeight*1.5,
              titleWidth:  _cellWidth*3.5,
              onChangeSelect: (p0){
                setState(() {
                  coordinate = p0!;
                  if(_enableEdit){
                    _shiftFrame.assignTable[coordinate!.row][coordinate!.column] = _inkValue;
                  }
                });
              },
              onInputEnd: (){ insertBuffer(_shiftFrame.assignTable); },
              shiftFrame: _shiftFrame,
              enableEdit: _enableEdit,
              selected: coordinate
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  ページ上部のツールボタン作成に使用 (onPress OnLongPress 2つの関数を使用)
  ///  OnLongPress に 0.5 秒の検出時間がかかるので，GestureDetector で検出したほうがいいかも
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  Widget buildIconButton(IconData icon, bool flag, Function onPressed, Function onLongPressed){
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: SizedBox(
        width: _screenSize.width / 7,
        height: 30,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            shadowColor: MyStyle.hiddenColor, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: BorderSide(color: (flag) ? MyStyle.primaryColor : MyStyle.hiddenColor),
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
          child: Align(alignment: Alignment.center, child: Icon(icon, color: (flag) ? MyStyle.primaryColor : MyStyle.hiddenColor, size: 20))
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
  
  void insertBuffer(List<List<int>> table){
    setState(() {
      undoredoCtrl.insertBuffer(table.map((e) => List.from(e).cast<int>()).toList());
    });
  }

  void paintUndoRedo(bool undo){
    setState(() {
      if(undo){
        _shiftFrame.assignTable = undoredoCtrl.undo().map((e) => List.from(e).cast<int>()).toList();
      }else{
        _shiftFrame.assignTable = undoredoCtrl.redo().map((e) => List.from(e).cast<int>()).toList();
      }
    });
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
        List<Widget>.generate(assignNumSelect.length, (index) => Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [ 
              Text(assignNumSelect[index], style: MyStyle.headlineStyle13,textAlign: TextAlign.center),
            ],
          )
        ),
        0.5,
        (BuildContext context, int index){
          setState(() {});
          _inkValue = index; 
        }
      )
    );
  }

  void buildAutoFillModalWindow(BuildContext context){
    showModalWindow(
      context,
      0.5,
      AutoFillWidget(shiftTable: _shiftFrame)
    ).then((value) {
      if(value != null){
        setState(() {});
        insertBuffer(_shiftFrame.assignTable);
      }
    });
  }

  void crearVariables(){
    Provider.of<ShiftFrameProvider>(context, listen: false).shiftFrame = ShiftFrame();
    coordinate  = Coordinate(column: 0, row: 0);
    undoredoCtrl = UndoRedo(_bufferMax);
    coordinate = null;
  }

    ////////////////////////////////////////////////////////////////////////////////////////////
  ///  割当て人数設定画面の使い方を説明するための関数
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<int?> showInfoDialog(bool isDarkTheme) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              title: Text("「シフト作成画面②」の使い方", style:  MyStyle.headlineStyleGreen20, textAlign: TextAlign.center),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.90,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text("この画面では、シフト表の割り当て人数を設定します。", style: MyStyle.headlineStyle18),
                      
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
                            Text("割り当て人数の設定について", style: MyStyle.headlineStyleGreen18),
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
                            Text("この画面では、シフト表の各日時に対する割り当て最大人数を設定します。", style: MyStyle.defaultStyleGrey13),
                            Text("シフト表作成後に割り当て人数を変更することはできません。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 20),
                            Text("編集方法", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("シフト表の各マスに表示されている数字は、その日時の割り当て人数を示すものです。", style: MyStyle.defaultStyleGrey13),
                            Text("画面上部のツールボタンを使用することで、割り当て人数を編集できます。", style: MyStyle.defaultStyleGrey13),
                            Text("編集後は、画面右上の「登録」ボタンを押してシフト表を作成してください。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            // How to Update
                            const SizedBox(height: 20),
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
                            Text("編集内容を「登録」しない場合、画面遷移時に破棄されます。", style: MyStyle.defaultStyleGrey13),
                            Text("「登録」するには、画面右上の「登録ボタン」を押してください。", style: MyStyle.defaultStyleGrey13),
                            Text("「登録」することでシフト表を作成できます。", style: MyStyle.defaultStyleGrey13),
                            Text("作成したシフト表の共有方法は、「ホーム画面」のインフォメーションボタンをタップしてご確認ください。", style: MyStyle.defaultStyleGrey13),
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
                            Text("画面上部のツールボタンを用いることで、効率的な編集を行うことができます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 20),
                            Text("拡大・縮小ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildIconButton( Icons.zoom_in,  true, (){}, (){}),
                                const SizedBox(width: 10),
                                buildIconButton( Icons.zoom_out, true, (){}, (){}),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("表の拡大・縮小ができます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          
                            // Filterring Input Button
                            const SizedBox(height: 10),
                            Text("フィルタ入力ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            buildIconButton( Icons.filter_alt_outlined, true, (){}, (){}),
                            const SizedBox(height: 10),
                            Text("「日時」「割当て人数」を指定して、一括で入力できます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),

                            // Draw Button                             
                            const SizedBox(height: 10),
                            Text("タッチ入力ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            buildIconButton(Icons.touch_app_outlined, true, (){}, (){}),
                            const SizedBox(height: 10),
                            Text("細かい1マス単位の編集ができます。", style: MyStyle.defaultStyleGrey13),
                            Text("タップ後に表のマスをなぞることで割り当て人数を編集できます。", style: MyStyle.defaultStyleGrey13),
                            Text("設定する割当て人数は、ボタンを長押しすることで選択できます。", style: MyStyle.defaultStyleGrey13),
                            Text("注意 : その間、表のスクロールが無効化されます。スクロールが必要な場合は、もう一度「タッチ入力ボタン」をタップし、無効化してください。", style: MyStyle.defaultStyleGrey13),
 

                            // Redo / Undo Button
                            const SizedBox(height: 10),
                            Text("戻る・進む ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildIconButton( Icons.undo, true, (){}, (){}),
                                const SizedBox(width: 10),
                                buildIconButton( Icons.redo, true, (){}, (){})
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("編集した割り当て表を「前の状態」や「次の状態」に戻すことができます。", style: MyStyle.defaultStyleGrey13),
                            Text("注意 : 遡れる状態は最大50であり、一度シフト表作成画面を閉じると過去の変更履歴は破棄されます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  )
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('閉じる'),
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
///  シフト表の Auto-Fill 機能のためのクラス (モーダルウィンドウとして使用)
////////////////////////////////////////////////////////////////////////////////////////////

class AutoFillWidget extends StatefulWidget {
  
  final ShiftFrame _shiftFrame;
  const AutoFillWidget({Key? key, required ShiftFrame shiftTable}) : _shiftFrame = shiftTable, super(key: key);

  @override
  AutoFillWidgetState createState() => AutoFillWidgetState();
}

class AutoFillWidgetState extends State<AutoFillWidget> {
  
  bool viewHistry = false;
  var selectorsIndex = [0, 0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    var table        = widget._shiftFrame;
    var timeDivs1List = List.generate(table.timeDivs.length + 1, (index) => (index == 0) ? '全て' : table.timeDivs[index-1].name);
    var timeDivs2List = List.generate(table.timeDivs.length + 1, (index) => (index == 0) ? '-' : table.timeDivs[index-1].name);

    ////////////////////////////////////////////////////////////////////////////////////////////
    /// Auto-Fillの引数の入力UI
    ////////////////////////////////////////////////////////////////////////////////////////////
    
    return LayoutBuilder(
      builder: (context, constraints) {
        var modalHeight  = _screenSize.height * 0.5;
        var modalWidth   = _screenSize.width - 10 - _screenSize.width * 0.08;
        var paddingHeght = modalHeight * 0.04;
        var buttonHeight = modalHeight * 0.2;
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
                      child: SizedBox(child: buildTextButton( weekSelect[selectorsIndex[0]], false, modalWidth * (100 / 330), buttonHeight, (){ buildSelectorModaleWindow(weekSelect, 0); } )),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("の", style: MyStyle.defaultStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: buildTextButton( weekdaySelect[selectorsIndex[1]], false, modalWidth * (100 / 330), buttonHeight, (){ buildSelectorModaleWindow(weekdaySelect, 1); }),
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
                      child: buildTextButton( timeDivs1List[selectorsIndex[2]], false, modalWidth * (100 / 330), buttonHeight, (){ buildSelectorModaleWindow(timeDivs1List, 2); }),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("~", style: MyStyle.defaultStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: buildTextButton( timeDivs2List[selectorsIndex[3]], false, modalWidth * (100 / 330), buttonHeight, (){ buildSelectorModaleWindow(timeDivs2List, 3); }),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (50 / 330), child: Center(child: Text("の区分は", style: MyStyle.defaultStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: buildTextButton(
                        "${selectorsIndex[4]} 人", false, modalWidth * (65 / 330), buttonHeight, (){
                          buildSelectorModaleWindow(
                            List<Widget>.generate(assignNumSelect.length, (index) => Row(
                              mainAxisAlignment:  MainAxisAlignment.center,
                              children: [
                                Text(assignNumSelect[index], style: MyStyle.headlineStyle13,textAlign: TextAlign.center),
                              ],
                            )
                          ),4);
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
                          var rule = AssignRule(
                            week:      selectorsIndex[0],
                            weekday:   selectorsIndex[1],
                            timeDivs1: selectorsIndex[2],
                            timeDivs2: selectorsIndex[3],
                            assignNum: selectorsIndex[4]
                          );
                          widget._shiftFrame.applyRuleToShiftFrame(rule);
                          Navigator.pop(context, rule); // これだけでModalWindowのFuture<dynamic>から返せる
                          setState(() {});
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

    ////////////////////////////////////////////////////////////////////////////////////////////
    ///  履歴表示　UI
    ////////////////////////////////////////////////////////////////////////////////////////////
    // : Padding(
    //   padding: const EdgeInsets.all(10.0),
    //   child: SingleChildScrollView(
    //     child: SizedBox(
    //       width: 250,
    //       height: MediaQuery.of(context).size.height * 0.40,
    //       child: (widget._shiftTable.assignRules.isEmpty) ? Center(child: Text("登録されている履歴がありません", style: MyFont.defaultStyleGrey15)) : ReorderableListView.builder(
    //         shrinkWrap: true,
    //         buildDefaultDragHandles: false,
    //         itemCount: widget._shiftTable.assignRules.length,
    //         itemBuilder: (context, i) => registerAutoFill(
    //           i, 
    //           weekSelect[widget._shiftTable.assignRules[i].week], 
    //           weekdaySelect[widget._shiftTable.assignRules[i].weekday],
    //           timeDivs1List[widget._shiftTable.assignRules[i].timeDivs1],
    //           timeDivs2List[widget._shiftTable.assignRules[i].timeDivs2],
    //           widget._shiftTable.assignRules[i].assignNum.toString(),
    //           context
    //         ),
    //         onReorder: (int oldIndex, int newIndex) {
    //           setState(() {
    //             if (oldIndex < newIndex) {
    //               newIndex -= 1;
    //             }
    //             final AssignRule item = widget._shiftTable.assignRules.removeAt(oldIndex);
    //             widget._shiftTable.assignRules.insert(newIndex, item);
    //           });
    //         }
    //       ),
    //     ),
    //   ),
    // );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Auto-Fill UI作成に使用するテキストボタンを構築
  ////////////////////////////////////////////////////////////////////////////////////////////

  Widget buildTextButton(String text, bool flag, double width, double height, Function action){
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shadowColor: MyStyle.hiddenColor, 
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(color: (flag) ? MyStyle.primaryColor : MyStyle.hiddenColor),
        ),
        onPressed: (){ 
          setState(() {
            action();
          });
        },
        child: Text(text, style: MyStyle.headlineStyleGreen13)
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  buildTextButtonを押すとさらに選択モーダルウィンドウを表示するための実装
  ////////////////////////////////////////////////////////////////////////////////////////////

  void buildSelectorModaleWindow(List list, int resultIndex) {
    showModalWindow(
      context,
      0.5,
      buildModalWindowContainer(
        context,
        list,
        0.5,
        (BuildContext context, int index){
          selectorsIndex[resultIndex] = index;
          setState(() {});
        }
      )
    );
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
          border: Border.all(
            color: MyStyle.hiddenColor
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
                  Text(weekSelect,      style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                  Text(' の ',          style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                  Text(weekdaySelect,   style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                  Text(' の ',          style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                  Text(timeDivs1Select, style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                  Text(' - ',           style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                  Text(timeDivs2Select, style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                  Text(' の勤務人数は ',  style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                  Text(assignNumSelect, style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                  Text(' 人',           style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.delete, size: 20),
              color: MyStyle.hiddenColor,
            ),
          ],
        ),
      ),
    );
  }
}