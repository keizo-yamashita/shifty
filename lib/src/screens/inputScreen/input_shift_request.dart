////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shift/main.dart';
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/dialog.dart';
import 'package:shift/src/mylibs/shift/shift_frame.dart';
import 'package:shift/src/mylibs/shift/shift_request.dart';
import 'package:shift/src/mylibs/shift_editor/linkled_scroll.dart';
import 'package:shift/src/mylibs/shift_editor/shift_request_editor.dart';
import 'package:shift/src/mylibs/shift_editor/shift_response_editor.dart';
import 'package:shift/src/mylibs/shift_editor/coordinate.dart';
import 'package:shift/src/mylibs/undo_redo.dart';
import 'package:shift/src/mylibs/modal_window.dart';
import 'package:shift/src/mylibs/button.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// 全体で使用する変数
////////////////////////////////////////////////////////////////////////////////////////////

// editor のセルサイズ設定
double _cellHeight   = 20;
double _cellWidth    = 20;
double _cellSizeMax  = 25;
double _cellSizeMin  = 15;
double _zoomDiv      = 1;
int    _bufferMax    = 50;

// editor の設定変数
bool _enableRequestEdit  = false;
bool _enableZoomIn       = true;
bool _enableZoomOut      = true;
int  _inkValue           = 1;
bool _isDark             = false;

// 画面サイズ
Size _screenSize         = const Size(0, 0);

// 使い方の表示フラグ
List<bool> _displayInfoFlag = [false, false, false, false];

// 最後のデータを保存したかどうか
bool _registered = true;

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト表の最終チェックに使用するページ (勤務人数も指定)
////////////////////////////////////////////////////////////////////////////////////////////

class InputShiftRequestWidget extends ConsumerStatefulWidget {
  
  const InputShiftRequestWidget({Key? key}) : super(key: key);
  
  @override
  InputShiftRequestWidgetState createState() => InputShiftRequestWidgetState();
}

class InputShiftRequestWidgetState extends ConsumerState<InputShiftRequestWidget> {

  // undo redo コントローラ
  UndoRedo<List<List<int>>> undoredoCtrl = UndoRedo(_bufferMax);

  // 選択している editor 上の座標
  Coordinate? coordinate;
  
  // シフトリクエストのインスタンス取得
  ShiftRequest _shiftRequest = ShiftRequest(ShiftFrame());

  late LinkedScrollControllerGroup horizontalScrollGroup;
  late LinkedScrollControllerGroup verticalScrollGroup;
  late ScrollController controllerHorizontal_0;
  late ScrollController controllerHorizontal_1;
  late ScrollController controllerVertical_0;
  late ScrollController controllerVertical_1;

  @override
  void initState() {
    super.initState();
    horizontalScrollGroup = LinkedScrollControllerGroup();
    verticalScrollGroup = LinkedScrollControllerGroup();
    controllerHorizontal_0 = horizontalScrollGroup.addAndGet();
    controllerHorizontal_1 = horizontalScrollGroup.addAndGet();
    controllerVertical_0 = verticalScrollGroup.addAndGet();
    controllerVertical_1 = verticalScrollGroup.addAndGet();
  }

  @override
  void dispose() {
    controllerHorizontal_0.dispose();
    controllerHorizontal_1.dispose();
    controllerVertical_0.dispose();
    controllerVertical_1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // 画面サイズの取得
    _screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom);


    // Provider 処理
    _shiftRequest = ref.read(shiftRequestProvider).shiftRequest;
    ref.read(settingProvider).loadPreferences();
    _isDark     = ref.read(settingProvider).enableDarkTheme;

    //  Undo Redo Buffer が空だったら最初の状態を保存
    if(undoredoCtrl.buffer.isEmpty){
      _registered = true;
      insertBuffer(_shiftRequest.requestTable);
    }

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
          final bool shouldPop = await showConfirmDialog( context, ref, "注意", "データが保存されていません。\n未登録のデータは破棄されます。", "", (){}, false, true);// ダイアログで戻るか確認
          if (shouldPop) {
            navigator.pop(); // 戻るを選択した場合のみpopを明示的に呼ぶ
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: FittedBox(fit:BoxFit.fill, child: Text((isRequestRange() ? " [リクエスト入力画面] " : " [シフト確認画面] ") +  _shiftRequest.shiftFrame.shiftName, style: MyStyle.headlineStyleGreen20)),
          bottomOpacity: 2.0,
          elevation: 2.0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: IconButton( 
                icon: const Icon(Icons.info_outline, size: 30, color: MyStyle.primaryColor),
                tooltip: "使い方",
                onPressed: () async {
                  showInfoDialog(_isDark);
                }
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: IconButton(
                icon: const Icon(Icons.cloud_upload_outlined, size: 30, color: MyStyle.primaryColor),
                tooltip: "リクエストを登録",
                onPressed: (){
                  if(isRequestRange()){
                    if(_registered){
                      showAlertDialog(context, ref, "注意", "リクエストは変更されていないため、登録できません。", true);
                    }else{
                      showConfirmDialog(
                        context, ref, "確認", "このリクエストを登録しますか？", "リクエストを登録しました。",
                        (){
                          _registered = true;
                          _shiftRequest.updateShiftRequest();
                        },
                        true
                      );
                    }
                  }else{
                    showAlertDialog(context, ref, "注意", "リクエスト期間内でないため、登録できません。\n編集が必要な場合は管理者に連絡して下さい。", true);
                  }
                }
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: false,
      
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
              
            ////////////////////////////////////////////////////////////////////////////////////////////
            /// ツールボタン
            ////////////////////////////////////////////////////////////////////////////////////////////
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //　拡大縮小ボタン
                    buildToolButton(
                      Icons.zoom_in,
                      _enableZoomIn,
                      _screenSize.width/7,
                      (){
                        setState((){
                          zoomIn();
                        });
                      },
                      (){}
                    ),
                    buildToolButton(
                      Icons.zoom_out,
                      _enableZoomOut,
                      _screenSize.width/7,
                      (){
                        setState((){
                          zoomOut();
                        });
                      },
                      (){}
                    ),
                    // フィルタ入力ボタン
                    buildToolButton(
                      Icons.filter_alt_outlined,
                      isRequestRange(),
                      _screenSize.width/7,
                      (){
                        if(isRequestRange()){
                          buildAutoFillModalWindow(context);
                        }else{
                          showAlertDialog(context, ref, "注意", "リクエスト期間内でないため、編集できません。\n編集が必要な場合は管理者に連絡してください。", true);
                        }
                        setState((){});
                      },
                      (){}
                    ),
                    // タッチ入力ボタン
                    buildToolButton(
                      Icons.touch_app_outlined,
                      _enableRequestEdit && isRequestRange(),
                      _screenSize.width/7,
                      (){
                        if(isRequestRange()){
                          _enableRequestEdit = !_enableRequestEdit;
                        }else{
                          showAlertDialog(context, ref, "注意", "リクエスト期間内でないため、編集できません。\n編集が必要な場合は管理者に連絡してください。", true);
                        }
                        setState((){});
                      },
                      (){
                        if(isRequestRange()){
                          buildInkChangeModaleWindow();
                          _enableRequestEdit = true;
                        }else{
                          showAlertDialog(context, ref, "注意", "リクエスト期間内でないため、編集できません。\n編集が必要な場合は管理者に連絡してください。", true);
                        }
                        setState((){});
                      }
                    ),
                    // Redo Undo ボタン
                    buildToolButton(
                      Icons.undo,
                      undoredoCtrl.enableUndo(),
                      _screenSize.width/7,
                      (){
                        setState(() {
                          _registered = false;
                          runUndoRedo(true);
                        });
                      },
                      (){}
                    ),
                    buildToolButton(
                      Icons.redo,
                      undoredoCtrl.enableRedo(),
                      _screenSize.width/7,
                      (){
                        setState(() {
                          _registered = false;
                          runUndoRedo(false);
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
            (isRequestRange())
            ? ShiftRequestEditor(
              sheetHeight: _screenSize.height * 1.0 - 30 - 16 - 8,
              sheetWidth:  _screenSize.width,
              cellHeight:  _cellHeight*1,
              cellWidth:   _cellWidth*1,
              titleHeight: _cellHeight*2,
              titleWidth:  _cellWidth*3.5,
              onChangeSelect:   (p0){
                setState(() {
                  coordinate = p0!;
                  if(_enableRequestEdit){
                    _shiftRequest.requestTable[coordinate!.row][coordinate!.column] = _inkValue;
                  }
                });
              },
              onInputEnd: (){
                _registered = false;
                insertBuffer(_shiftRequest.requestTable);
              },
              shiftRequest: _shiftRequest,
              enableEdit: _enableRequestEdit,
              selected: coordinate,
              isDark: _isDark,
            )
            : ShiftResponseEditor(
              sheetHeight: _screenSize.height * 1.0 - 30 - 16 - 8,
              sheetWidth:  _screenSize.width,
              cellHeight:  _cellHeight*1,
              cellWidth:   _cellWidth*1,
              titleHeight: _cellHeight*2,
              titleWidth:  _cellWidth*3.5,
              titleMargin: 10,
              controllerHorizontal_0: controllerHorizontal_0,
              controllerHorizontal_1: controllerHorizontal_1,
              controllerVertical_0: controllerVertical_0,
              controllerVertical_1: controllerVertical_1,
              onChangeSelect:   (p0){
                setState(() {
                  coordinate = p0!;
                });
              },
              onInputEnd: (){},
              shiftRequest: _shiftRequest,
              enableEdit: false,
              selected: coordinate,
              isDark: _isDark,
            ),
              
            // brank
            const SizedBox(height: 8)
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// リクエスト期間内か判定する関数
  ////////////////////////////////////////////////////////////////////////////////////////////
  bool isRequestRange(){
    DateTime now = DateTime.now();
    // 今の日付が，シフトリクエスト期間かどうか判定 (リクエスト期間 -> true)
    return (now.compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].start) >= 0 && now.compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].end) <= 0);
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

  void runUndoRedo(bool undo){
    setState(() {
      if(undo){
        _shiftRequest.requestTable = undoredoCtrl.undo().map((e) => List.from(e).cast<int>()).toList();
      }else{
        _shiftRequest.requestTable = undoredoCtrl.redo().map((e) => List.from(e).cast<int>()).toList();
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
        [
          Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              const Icon(Icons.clear, size: 30, color: Colors.red),
              const SizedBox(width: 30),
              Text("NG", style: MyStyle.headlineStyle13,textAlign: TextAlign.center),
            ],
          ),
          Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              const Icon(Icons.circle_outlined, size: 30, color: MyStyle.primaryColor), 
              const SizedBox(width: 30),
              Text("OK", style: MyStyle.headlineStyle13,textAlign: TextAlign.center),
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

  void buildAutoFillModalWindow(BuildContext context){
    showModalWindow(
      context,
      0.5,
      RangeFillWidget(shiftRequest: _shiftRequest)
    ).then((value) {
      if(value != null){
        setState(() {});
        _registered = false;
        insertBuffer(_shiftRequest.requestTable);
      }
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフトリクエスト入力画面の使い方を説明するための関数
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<int?> showInfoDialog(bool isDarkTheme) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              title: Text("「リクエスト入力画面」の使い方", style:  MyStyle.headlineStyleGreen20, textAlign: TextAlign.center),
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
                            Text("この画面では、シフトリクエストを編集できます。", style: MyStyle.defaultStyleGrey13),
                            Text("また「シフトリクエスト期間」終了後にシフト表を確認するためにも使用します。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 20),
                            Text("編集方法", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("編集は「シフトリクエスト期間」でのみ可能です。", style: MyStyle.defaultStyleGrey13),
                            Text("「シフトリクエスト期間」中は何度でも編集できます。", style: MyStyle.defaultStyleGrey13),
                            Text("編集後は、画面右上の「登録」ボタンを押して登録してください。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),

                            const SizedBox(height: 20),
                            Text("アイコンについて", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("シフト表の表示されるアイコンは、その日時の「リクエスト」を示すものです。", style: MyStyle.defaultStyleGrey13),
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
                                SizedBox(width: 80, child: Text("シフト希望", style: MyStyle.defaultStyleGrey13)),
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
                                Text("非シフト希望", style: MyStyle.defaultStyleGrey13)
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
                                    child: Icon(Icons.circle, size: 20, color: MyStyle.primaryColor),
                                  )
                                ),
                                const SizedBox(width: 10),
                                Text("シフト確定 ※「リクエスト期間」以降に確認可能", style: MyStyle.defaultStyleGrey13),
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
                            Text("シフトリクエスト表の編集内容は、画面遷移時に破棄されます。", style: MyStyle.defaultStyleGrey13),
                            Text("編集内容を「登録」するには、画面右上の「登録ボタン」を押してください。", style: MyStyle.defaultStyleRed13),
                            Text("登録内容は常にシフト管理者に共有されますが、「シフトリクエスト期間」終了日までは何度でも変更できます。", style: MyStyle.defaultStyleGrey13),
                            Text("「シフトリクエスト期間」終了日までには、必ず登録してください。", style: MyStyle.defaultStyleRed13),
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
                                buildToolButton( Icons.zoom_in,  true, _screenSize.width/7, (){}, (){}),
                                const SizedBox(width: 10),
                                buildToolButton( Icons.zoom_out, true, _screenSize.width/7, (){}, (){}),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("表の拡大・縮小ができます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          
                            // Filterring Input Button
                            const SizedBox(height: 10),
                            Text("フィルタ入力ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            buildToolButton( Icons.filter_alt_outlined, true, _screenSize.width/7, (){}, (){}),
                            const SizedBox(height: 10),
                            Text("「日時」「リクエスト」を指定して、一括で入力できます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),

                            // Draw Button                             
                            const SizedBox(height: 10),
                            Text("タッチ入力ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            buildToolButton(Icons.touch_app_outlined, true, _screenSize.width/7, (){}, (){}),
                            const SizedBox(height: 10),
                            Text("細かい1マス単位の編集ができます。", style: MyStyle.defaultStyleGrey13),
                            Text("タップ後に表のマスをなぞることで割り当て状態を編集できます。", style: MyStyle.defaultStyleGrey13),
                            Text("入力する「リクエスト」は、ボタンを長押しすることで選択できます。", style: MyStyle.defaultStyleGrey13),
                            Text("注意 : 使用中、表のスクロールが無効化されます。スクロールが必要な場合は、もう一度「タッチ入力ボタン」をタップし、無効化してください。", style: MyStyle.defaultStyleRed13),

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
                            Text("編集したシフトリクエスト表を「前の状態」や「次の状態」に戻すことができます。", style: MyStyle.defaultStyleGrey13),
                            Text("注意 : 遡れる状態は最大50であり、一度管理者画面を閉じると過去の変更履歴は破棄されます。", style: MyStyle.defaultStyleRed13),
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
///  シフト表の Auto-Fill 機能のためのクラス (モーダルウィンドウとして使用)
////////////////////////////////////////////////////////////////////////////////////////////

class RangeFillWidget extends StatefulWidget {
  
  final ShiftRequest _shiftRequest;
  const RangeFillWidget({Key? key, required ShiftRequest shiftRequest}) : _shiftRequest = shiftRequest, super(key: key);

  @override
  RangeFillWidgetState createState() => RangeFillWidgetState();
}

class RangeFillWidgetState extends State<RangeFillWidget> {
  
  bool viewHistry = false;
  var selectorsIndex = [0, 0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {

    var request       = widget._shiftRequest;
    var timeDivs1List = List.generate(request.shiftFrame.timeDivs.length + 1, (index) => (index == 0) ? '全て' : request.shiftFrame.timeDivs[index-1].name);
    var timeDivs2List = List.generate(request.shiftFrame.timeDivs.length + 1, (index) => (index == 0) ? '-' : request.shiftFrame.timeDivs[index-1].name);

    ////////////////////////////////////////////////////////////////////////////////////////////
    /// Auto-Fillの引数の入力UI (viewHistoryがTrueであれば，履歴表示画面を表示)
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        "一括入力", true, modalWidth, buttonHeight * 0.8,
                        (){
                          var rule = RequestRule(
                            week:      selectorsIndex[0],
                            weekday:   selectorsIndex[1],
                            timeDivs1: selectorsIndex[2],
                            timeDivs2: selectorsIndex[3],
                            request:   selectorsIndex[4]
                          );
                          widget._shiftRequest.applyRuleToRequest(rule);
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

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Auto-Fill条件を登録
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  Widget registerAutoFill(int index, String weekSelect, String weekdaySelect, String timeDivs1Select, String timeDivs2Select,  String requestSelect, BuildContext context) {
    return ReorderableDragStartListener(
      key: Key(index.toString()),
      index: index,
      child: Container(
        width: 300,
        height: 80,
        decoration: BoxDecoration(
          color: MyStyle.backgroundColor,
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
                  Text(' は ',          style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                  Text(requestSelect,   style: MyStyle.defaultStyleGrey13, textHeightBehavior: MyStyle.defaultBehavior),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // widget._shiftTable.requestRules.remove(widget._shiftTable.requestRules[index]);
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