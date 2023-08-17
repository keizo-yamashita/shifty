////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/dialog.dart';
import 'package:shift/src/mylibs/shift/shift_frame.dart';
import 'package:shift/src/mylibs/shift/shift_request.dart';
import 'package:shift/src/mylibs/shift_editor/shift_request_editor.dart';
import 'package:shift/src/mylibs/shift_editor/shift_response_editor.dart';
import 'package:shift/src/mylibs/shift_editor/coordinate.dart';
import 'package:shift/src/mylibs/undo_redo.dart';
import 'package:shift/src/mylibs/modal_window.dart';
import 'package:shift/src/mylibs/setting_provider.dart';
import 'package:shift/src/mylibs/shift/shift_provider.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// 全体で使用する変数
////////////////////////////////////////////////////////////////////////////////////////////

double _cellHeight       = 20;
double _cellWidth        = 20;
double _titleHeight      = 30;
double _titleWidth       = 60;
double _cellSizeMax      = 25;
double _cellSizeMin      = 15;
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

class InputShiftRequestWidget extends StatefulWidget {
  
  const InputShiftRequestWidget({Key? key}) : super(key: key);
  
  @override
  State<InputShiftRequestWidget> createState() => InputShiftRequestWidgetState();
}

class InputShiftRequestWidgetState extends State<InputShiftRequestWidget> {

  UndoRedo<List<List<int>>> undoredoCtrl = UndoRedo(_bufferMax);

  Coordinate? coordinate;
  
  ShiftRequest _shiftRequest = ShiftRequest(ShiftFrame());

  @override
  Widget build(BuildContext context) {

    _screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom);

    _shiftRequest = Provider.of<ShiftRequestProvider>(context, listen: false).shiftRequest;

    var settingProvider = Provider.of<SettingProvider>(context, listen: false);
    settingProvider.loadPreferences();

    if(undoredoCtrl.buffer.isEmpty){
      insertBuffer(_shiftRequest.requestTable);
    }

    return Scaffold(
      appBar: AppBar(
        title: 
        Text((DateTime.now().compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].start) >= 0 && DateTime.now().compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].end) <= 0) ? "リクエストの入力" : "シフト表の確認", style: MyStyle.headlineStyleGreen20),
        bottomOpacity: 2.0,
        elevation: 2.0,
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
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: const Icon(Icons.cloud_upload_outlined, size: 30, color: MyStyle.primaryColor),
              tooltip: "リクエストを登録",
              onPressed: (){
                DateTime now = DateTime.now();
                if(now.compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].start) >= 0 && now.compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].end) <= 0){
                  showConfirmDialog(
                    context, "確認", "このリクエストを登録しますか？", "リクエストを登録しました", (){
                    Navigator.pop(context);
                    _shiftRequest.updateShiftRequest();
                  });
                }else{
                  showAlertDialog(context, "注意", "リクエスト期間内でないため，登録できません\n編集が必要な場合は管理者に連絡してください", true);
                }
              }
            ),
          ),
        ],
      ),
    
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: _screenSize.height * 0.02),
          
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// ツールボタン
          ////////////////////////////////////////////////////////////////////////////////////////////
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildIconButton( Icons.zoom_in, _enableZoomIn, (){ zoomIn(); }, (){}),
                buildIconButton( Icons.zoom_out, _enableZoomOut, (){ zoomOut(); }, (){}),
                buildIconButton( Icons.filter_alt_outlined, DateTime.now().compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].start) >= 0 && DateTime.now().compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].end) <= 0,
                (){
                  DateTime now = DateTime.now();
                  if(now.compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].start) >= 0 && now.compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].end) <= 0){
                    buildAutoFillModalWindow(context);
                  }else{
                    showAlertDialog(context, "注意", "リクエスト期間内でないため，編集できません\n編集が必要な場合は管理者に連絡してください", true);
                  }
                }, (){}),
                buildIconButton(
                  Icons.touch_app_outlined, _enableEdit && DateTime.now().compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].start) >= 0 && DateTime.now().compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].end) <= 0
                  ,
                  (){
                    DateTime now = DateTime.now();
                    if(now.compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].start) >= 0 && now.compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].end) <= 0){
                      _enableEdit = !_enableEdit;
                    }else{
                      showAlertDialog(context, "注意", "リクエスト期間内でないため，編集できません\n編集が必要な場合は管理者に連絡してください", true);
                    }
                  },
                  (){
                    DateTime now = DateTime.now();
                    if(now.compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].start) >= 0 && now.compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].end) <= 0){
                      buildInkChangeModaleWindow();
                      _enableEdit = true;
                    }else{
                      showAlertDialog(context, "注意", "リクエスト期間内でないため，編集できません\n編集が必要な場合は管理者に連絡してください", true);
                    }
                  }
                ),
                buildIconButton( Icons.undo,  undoredoCtrl.enableUndo(), (){paintUndoRedo(true);}, (){}),
                buildIconButton( Icons.redo,  undoredoCtrl.enableRedo(), (){paintUndoRedo(false);}, (){})
              ],
            ),
          ),
          
          SizedBox(height: _screenSize.height * 0.02),
          
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// メインテーブル
          ////////////////////////////////////////////////////////////////////////////////////////////
          (DateTime.now().compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].start) >= 0 && DateTime.now().compareTo(_shiftRequest.shiftFrame.shiftDateRange[1].end) <= 0)
          ? ShiftRequestEditor(
            sheetHeight: _screenSize.height * (1.0 - 0.02 - 0.02) - 30,
            sheetWidth:  _screenSize.width,
            cellHeight:  _cellHeight*1,
            cellWidth:   _cellWidth*1,
            titleHeight: _cellHeight*1.5,
            titleWidth:  _cellWidth*3.5,
            onChangeSelect:   (p0){
              setState(() {
                coordinate = p0!;
                if(_enableEdit){
                  _shiftRequest.requestTable[coordinate!.row][coordinate!.column] = _inkValue;
                }
              });
            },
            onInputEnd: (){ insertBuffer(_shiftRequest.requestTable); },
            shiftRequest: _shiftRequest,
            enableEdit: _enableEdit,
            selected: coordinate,
            isDark: Theme.of(context).brightness == Brightness.dark,
          )
          : ShiftResponseEditor(
            sheetHeight: _screenSize.height * (1.0 - 0.02 - 0.02) - 30,
            sheetWidth:  _screenSize.width,
            cellHeight:  _cellHeight*1,
            cellWidth:   _cellWidth*1,
            titleHeight: _cellHeight*1.5,
            titleWidth:  _cellWidth*3.5,
            onChangeSelect:   (p0){
              setState(() {
                coordinate = p0!;
              });
            },
            onInputEnd: (){ insertBuffer(_shiftRequest.requestTable); },
            shiftRequest: _shiftRequest,
            enableEdit: false,
            selected: coordinate,
            isDark: Theme.of(context).brightness == Brightness.dark,
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
      for(int i =0; i < undoredoCtrl.buffer.length; i++){
        print("${undoredoCtrl.buffer.length} ${undoredoCtrl.bufferIndex} ${undoredoCtrl.buffer[i][0][0]}");
      }
    });
  }

  void paintUndoRedo(bool undo){
    setState(() {
      if(undo){
        _shiftRequest.requestTable = undoredoCtrl.undo().map((e) => List.from(e).cast<int>()).toList();
      }else{
        _shiftRequest.requestTable = undoredoCtrl.redo().map((e) => List.from(e).cast<int>()).toList();
      }
      print("${undoredoCtrl.buffer.length} ${undoredoCtrl.bufferIndex} ${_shiftRequest.requestTable[0][0]}");
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
      AutoFillWidget(shiftRequest: _shiftRequest)
    ).then((value) {
      if(value != null){
        setState(() {});
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
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              title: Text("「リクエスト入力画面」の使い方", style:  MyStyle.headlineStyleGreen20, textAlign: TextAlign.center),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.90,
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
                            Text("シフトリクエスト表の編集内容は、「登録」しない場合、画面遷移時に破棄されます。", style: MyStyle.defaultStyleGrey13),
                            Text("編集内容を「登録」するには、画面右上の「登録ボタン」を押してください。", style: MyStyle.defaultStyleGrey13),
                            Text("登録内容は常にシフト管理者に共有されますが、「シフトリクエスト期間」終了日までは何度でも変更できます。", style: MyStyle.defaultStyleGrey13),
                            Text("「シフトリクエスト期間」終了日までには、必ず登録してください。", style: MyStyle.defaultStyleGrey13),
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
                            Text("「日時」「リクエスト」を指定して、一括で入力できます。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),

                            // Draw Button                             
                            const SizedBox(height: 10),
                            Text("タッチ入力ボタン", style: MyStyle.headlineStyle18),
                            const SizedBox(height: 10),
                            buildIconButton(Icons.touch_app_outlined, true,(){}, (){}),
                            const SizedBox(height: 10),
                            Text("細かい1マス単位の編集ができます。", style: MyStyle.defaultStyleGrey13),
                            Text("タップ後に表のマスをなぞることで割り当て状態を編集できます。", style: MyStyle.defaultStyleGrey13),
                            Text("入力する「リクエスト」は、ボタンを長押しすることで選択できます。", style: MyStyle.defaultStyleGrey13),
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
                            Text("編集したシフトリクエスト表を「前の状態」や「次の状態」に戻すことができます。", style: MyStyle.defaultStyleGrey13),
                            Text("注意 : 遡れる状態は最大50であり、一度管理者画面を閉じると過去の変更履歴は破棄されます。", style: MyStyle.defaultStyleGrey13),
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
  
  final ShiftRequest _shiftRequest;
  const AutoFillWidget({Key? key, required ShiftRequest shiftRequest}) : _shiftRequest = shiftRequest, super(key: key);

  @override
  AutoFillWidgetState createState() => AutoFillWidgetState();
}

class AutoFillWidgetState extends State<AutoFillWidget> {
  
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      child: buildIconButton(
                        (selectorsIndex[4] == 1) ? const Icon(Icons.circle_outlined, size: 20, color: MyStyle.primaryColor) : const Icon(Icons.clear, size: 20, color: Colors.red),
                        false,
                        modalWidth * (65 / 330), buttonHeight,
                        (){
                          buildSelectorModaleWindow(List<Icon>.generate(2, (index) => (index == 1) ? const Icon(Icons.circle_outlined, size: 20, color: MyStyle.primaryColor) : const Icon(Icons.clear, size: 20, color: Colors.red)), 4);
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

  Widget buildIconButton(Icon icon, bool flag, double width, double height, Function action){
    return SizedBox(
      width: width,
      height: height,
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
            action();
          });
        },
        child: icon
      ),
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