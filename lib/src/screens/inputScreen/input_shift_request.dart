////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shift/main.dart';
import 'package:shift/src/components/style/pop_icons.dart';
import 'package:shift/src/components/form/shift_editor/editor_appbar.dart';
import 'package:shift/src/components/form/shift_editor/table.dart';
import 'package:shift/src/components/form/shift_editor/table_title.dart';
import 'package:shift/src/components/style/style.dart';
import 'package:shift/src/components/form/utility/dialog.dart';
import 'package:shift/src/components/shift/shift_frame.dart';
import 'package:shift/src/components/shift/shift_request.dart';
import 'package:shift/src/components/form/shift_editor/coordinate.dart';
import 'package:shift/src/components/undo_redo.dart';
import 'package:shift/src/components/form/utility/modal_window.dart';
import 'package:shift/src/components/form/utility/button.dart';
import 'package:shift/src/screens/createScreen/register_shift_frame.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// 全体で使用する変数
////////////////////////////////////////////////////////////////////////////////////////////

// editor のセルサイズ設定
double cellHeight  = 20;
double cellWidth   = 20;
double titleMargin = 3;
double cellSizeMax = 30;
double cellSizeMin = 10;
double zoomDiv     = 1;
int    bufferMax   = 50;

// editor の設定変数
bool enableRequestEdit  = false;
bool enableZoomIn       = true;
bool enableZoomOut      = true;
int  requestInputValue  = 1;
bool isDark             = false;

// 画面サイズ
Size screenSize         = const Size(0, 0);

// 使い方の表示フラグ
List<bool> displayInfoFlag = [false, false, false, false];

// 最後のデータを保存したかどうか
bool registered = true;

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
  UndoRedo<List<List<int>>> undoredoCtrl = UndoRedo(bufferMax);

  // 選択している editor 上の座標
  Coordinate? selectedCoodinate;
  
  // シフトリクエストのインスタンス取得
  late ShiftRequest shiftRequest;
  bool         enableResponseEdit = false;
  GlobalKey    editorKey          = GlobalKey<TableEditorState>();

  @override
  Widget build(BuildContext context) {

    // 画面サイズの取得
    screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom/2);

    // Provider 処理
    isDark        = ref.read(settingProvider).enableDarkTheme;
    shiftRequest = ref.read(shiftRequestProvider).shiftRequest;
    ref.read(settingProvider).loadPreferences();

    int columnLength = shiftRequest.shiftFrame.dateTerm[0].end.difference(shiftRequest.shiftFrame.dateTerm[0].start).inDays + 1;
    int rowLength    = shiftRequest.shiftFrame.timeDivs.length;

    //  Undo Redo Buffer が空だったら最初の状態を保存
    if(undoredoCtrl.buffer.isEmpty){
      registered = true;
      insertBuffer(shiftRequest.reqTable);
    }

    return EditorAppBar(
      context: context,
      ref: ref, 
      registered: registered,
      title: isRequestRange() ? " [リクエスト入力画面]  ${shiftRequest.shiftFrame.shiftName}" : " [シフト確認画面]  ${shiftRequest.shiftFrame.shiftName}",
      handleInfo: (){
        showInfoDialog(isDark);
      }, 
      handleRegister: (){
        if(isRequestRange()){
          if(registered){
            showAlertDialog(context, ref, "注意", "リクエストは変更されていないため、登録できません。", true);
          }else{
            showConfirmDialog(
              context, ref, "確認", "このリクエストを登録しますか？", "リクエストを登録しました。",
              (){
                registered = true;
                shiftRequest.updateShiftRequest();
              },
              true
            );
          }
        }else{
          showAlertDialog(context, ref, "注意", "リクエスト期間内でないため、登録できません。\n編集が必要な場合は管理者に連絡して下さい。", true);
        }
      },
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
            
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// ツールボタン
          ////////////////////////////////////////////////////////////////////////////////////////////
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(right: 5.0, left: 5.0, top: 15.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //　拡大縮小ボタン
                  ToolButton(icon: Icons.zoom_in,  pressEnable: enableZoomIn,  width: screenSize.width/7, onPressed: handleZoomIn,),
                  ToolButton(icon: Icons.zoom_out, pressEnable: enableZoomOut, width: screenSize.width/7, onPressed: handleZoomOut,),
                  // 範囲入力ボタン
                  ToolButton(icon: Icons.filter_alt_outlined, pressEnable: isRequestRange(), width: screenSize.width/7, onPressed: handleRangeFill,),
                  // タッチ入力ボタン
                  ToolButton(icon: Icons.touch_app_outlined, pressEnable: isRequestRange(), offEnable: !enableResponseEdit, width: screenSize.width/7, onPressed: handleTouchEdit, onLongPressed: handleChangeInputValue,),
                  // Redo Undo ボタン
                  ToolButton(icon: Icons.undo, pressEnable: undoredoCtrl.enableUndo(), width: screenSize.width/7, onPressed: handleUndo,),
                  ToolButton(icon: Icons.redo, pressEnable: undoredoCtrl.enableRedo(), width: screenSize.width/7, onPressed: handleRedo,),
                ],
              ),
            ),
          ),
          
          ////////////////////////////////////////////////////////////////////////////////////////////
          /// メインテーブル
          ////////////////////////////////////////////////////////////////////////////////////////////
          (isRequestRange())
          ? TableEditor(
            editorKey:   editorKey,
            tableHeight: screenSize.height * 1.0 - 65,
            tableWidth:  screenSize.width,
            cellHeight:  cellHeight,
            cellWidth:   cellWidth,
            titleHeight: cellHeight*2,
            titleWidth:  cellWidth*3.5,
            titleMargin: titleMargin,
            onChangeSelect: (p0) async {
              setState(() {
                selectedCoodinate = p0!;
              });
            },
            columnTitles: getColumnTitles(cellHeight*2, cellWidth, shiftRequest.shiftFrame.dateTerm[0].start, shiftRequest.shiftFrame.dateTerm[0].end, isDark),
            rowTitles: getRowTitles(cellHeight, cellWidth*3.5, shiftRequest.shiftFrame.timeDivs, isDark),
            cells: List<List<Widget>>.generate(
              rowLength, 
              (i){
                return List.generate(
                  columnLength,
                  (j){
                    return requestCell( i, j, shiftRequest.shiftFrame.assignTable[i][j] != 0, j == selectedCoodinate?.column && i == selectedCoodinate?.row);
                  }
                );
              },
            ),
            enableEdit: enableEdit,
            selected: selectedCoodinate,
            isDark: isDark,
          )
          : TableEditor(
            editorKey:   editorKey,
            tableHeight: screenSize.height * 1.0 - 65,
            tableWidth:  screenSize.width,
            cellHeight:  cellHeight,
            cellWidth:   cellWidth,
            titleHeight: cellHeight*2,
            titleWidth:  cellWidth*3.5,
            titleMargin: titleMargin,
            onChangeSelect: (p0) async {
              setState(() {
                selectedCoodinate = p0!;
                if(enableRequestEdit){
                  shiftRequest.reqTable[selectedCoodinate!.row][selectedCoodinate!.column] = requestInputValue;
                }
              });
            },
            onInputEnd: (){
              registered = false;
              insertBuffer(shiftRequest.reqTable);
            },
            columnTitles: getColumnTitles(cellHeight*2, cellWidth, shiftRequest.shiftFrame.dateTerm[0].start, shiftRequest.shiftFrame.dateTerm[0].end, isDark),
            rowTitles: getRowTitles(cellHeight, cellWidth*3.5, shiftRequest.shiftFrame.timeDivs, isDark),
            cells: List<List<Widget>>.generate(
              rowLength, 
              (i){
                return List.generate(
                  columnLength,
                  (j){
                    return responseCell(i, j, shiftRequest.shiftFrame.assignTable[i][j] != 0, j == selectedCoodinate?.column && i == selectedCoodinate?.row);
                  }
                );
              },
            ),
            enableEdit: false,
            selected: selectedCoodinate,
            isDark: isDark,
          ),
          // brank
          const SizedBox(height: 8)
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Cell
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  Widget responseCell(int row, int column, bool editable, bool selected) {

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

    cellColor =  selected ? cellColor.withAlpha(200) : cellColor.withAlpha(50);
    var cellBoaderWdth = 1.0;
    return SizedBox(
      child: Container(
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
      ),
    );
  }

  Widget requestCell(int row, int column, bool editable, bool selected) {

    var value = editable ? shiftRequest.reqTable[row][column] : 0;
    Icon cellValue;
    Color cellColor;

    if(value == 1){ 
      cellValue = Icon(PopIcons.circle_empty, size: 12 * cellWidth / 20, color: Styles.primaryColor);
      cellColor = Styles.primaryColor;
    }else{
      cellValue = Icon(PopIcons.cancel, size: 12 * cellWidth / 20, color: Colors.red);
      cellColor = Colors.red;
    }

    cellColor =  (selected) ? cellColor.withAlpha(100) : Colors.transparent;
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
  /// リクエスト期間内か判定する関数
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  bool isRequestRange(){
    DateTime now = DateTime.now();
    // 今の日付が，シフトリクエスト期間かどうか判定 (リクエスト期間 -> true)
    return (now.compareTo(shiftRequest.shiftFrame.dateTerm[1].start) >= 0 && now.compareTo(shiftRequest.shiftFrame.dateTerm[1].end) <= 0);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  Zoom In / Zoom Out 機能の実装
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void zoomIn(){
    if(enableZoomIn && cellHeight < cellSizeMax){
      cellHeight += zoomDiv;
      cellWidth  += zoomDiv;
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
      cellHeight -= zoomDiv;
      cellWidth  -= zoomDiv;
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
  
  void insertBuffer(List<List<int>> table){
    setState(() {
      undoredoCtrl.insertBuffer(table.map((e) => List.from(e).cast<int>()).toList());
    });
  }

  void callUndoRedo(bool undo){
    setState(() {
      if(undo){
        shiftRequest.reqTable = undoredoCtrl.undo().map((e) => List.from(e).cast<int>()).toList();
      }else{
        shiftRequest.reqTable = undoredoCtrl.redo().map((e) => List.from(e).cast<int>()).toList();
      }
    });
  }

  void handleUndo(){
    setState(() {
      registered = false;
      callUndoRedo(true);
    });
  }

  void handleRedo(){
    setState(() {
      registered = false;
      callUndoRedo(false);
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表に塗る色を選択する
  ////////////////////////////////////////////////////////////////////////////////////////////

  void xbuildChangeInputValueModaleWindow() {
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
              Text("NG", style: Styles.headlineStyle13,textAlign: TextAlign.center),
            ],
          ),
          Row(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              const Icon(Icons.circle_outlined, size: 30, color: Styles.primaryColor), 
              const SizedBox(width: 30),
              Text("OK", style: Styles.headlineStyle13,textAlign: TextAlign.center),
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
    if(isRequestRange()){
      editorKey = GlobalKey<TableEditorState>();
      enableRequestEdit = !enableRequestEdit;
    }else{
      showAlertDialog(context, ref, "注意", "リクエスト期間内でないため、編集できません。\n編集が必要な場合は管理者に連絡してください。", true);
    }
    setState((){});
  }
  
  void handleChangeInputValue(){
    if(isRequestRange()){
      xbuildChangeInputValueModaleWindow();
      enableRequestEdit = true;
    }else{
      showAlertDialog(context, ref, "注意", "リクエスト期間内でないため、編集できません。\n編集が必要な場合は管理者に連絡してください。", true);
    }
    setState((){});
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// 範囲入力処理
  ////////////////////////////////////////////////////////////////////////////////////////////

  void buildRangeFillModalWindow(BuildContext context){
    showModalWindow(
      context,
      0.5,
      RangeFillWidget(shiftRequest: shiftRequest)
    ).then((value) {
      if(value != null){
        setState(() {});
        registered = false;
        insertBuffer(shiftRequest.reqTable);
      }
    });
  }

  void handleRangeFill(){
    if(isRequestRange()){
      buildRangeFillModalWindow(context);
    }else{
      showAlertDialog(context, ref, "注意", "リクエスト期間内でないため、編集できません。\n編集が必要な場合は管理者に連絡してください。", true);
    }
    setState((){});
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
              title: Text("「リクエスト入力画面」の使い方", style:  Styles.headlineStyleGreen20, textAlign: TextAlign.center),
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
                              child : displayInfoFlag[0] ? Text("-", style: Styles.headlineStyleGreen18) : Text("+", style: Styles.headlineStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("シフト表について", style: Styles.headlineStyleGreen18),
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
                            Text("この画面では、シフトリクエストを編集できます。", style: Styles.headlineStyleGrey13),
                            Text("また「シフトリクエスト期間」終了後にシフト表を確認するためにも使用します。", style: Styles.headlineStyleGrey13),
                            const SizedBox(height: 20),
                            Text("編集方法", style: Styles.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("編集は「シフトリクエスト期間」でのみ可能です。", style: Styles.headlineStyleGrey13),
                            Text("「シフトリクエスト期間」中は何度でも編集できます。", style: Styles.headlineStyleGrey13),
                            Text("編集後は、画面右上の「登録」ボタンを押して登録してください。", style: Styles.headlineStyleGrey13),
                            const SizedBox(height: 10),

                            const SizedBox(height: 20),
                            Text("アイコンについて", style: Styles.headlineStyle18),
                            const SizedBox(height: 10),
                            Text("シフト表の表示されるアイコンは、その日時の「リクエスト」を示すものです。", style: Styles.headlineStyleGrey13),
                            Text("アイコンの示す意味は、下記のとおりです。", style: Styles.headlineStyleGrey13),
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
                                SizedBox(width: 80, child: Text("シフト希望", style: Styles.headlineStyleGrey13)),
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
                                Text("非シフト希望", style: Styles.headlineStyleGrey13)
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
                                    child: Icon(Icons.circle, size: 20, color: Styles.primaryColor),
                                  )
                                ),
                                const SizedBox(width: 10),
                                Text("シフト確定 ※「リクエスト期間」以降に確認可能", style: Styles.headlineStyleGrey13),
                              ],
                            ),
                            
                            // How to Update
                            const SizedBox(height: 30),
                            Text("登録方法", style: Styles.headlineStyle18),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.cloud_upload_outlined, size: 24, color: Styles.primaryColor),
                                const SizedBox(width: 10),
                                Text("登録ボタン (画面右上)", style: Styles.headlineStyleGrey13),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("シフトリクエスト表の編集内容は、画面遷移時に破棄されます。", style: Styles.headlineStyleGrey13),
                            Text("編集内容を「登録」するには、画面右上の「登録ボタン」を押してください。", style: Styles.headlineStyleRed13),
                            Text("登録内容は常にシフト管理者に共有されますが、「シフトリクエスト期間」終了日までは何度でも変更できます。", style: Styles.headlineStyleGrey13),
                            Text("「シフトリクエスト期間」終了日までには、必ず登録してください。", style: Styles.headlineStyleRed13),
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
                              child : displayInfoFlag[1] ? Text("-", style: Styles.headlineStyleGreen18) : Text("+", style: Styles.headlineStyleGreen18),
                            ),
                            const SizedBox(width: 10),
                            Text("ツールボタンについて", style: Styles.headlineStyleGreen18),
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
                            Text("画面上部のツールボタンを用いることで、効率的な編集を行うことができます。", style: Styles.headlineStyleGrey13),
                            const SizedBox(height: 20),
                            Text("拡大・縮小ボタン", style: Styles.headlineStyle18),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ToolButton( icon: Icons.zoom_in, pressEnable: true, width: screenSize.width/7),
                                const SizedBox(width: 10),
                                ToolButton( icon: Icons.zoom_out, pressEnable: true, width: screenSize.width/7),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("表の拡大・縮小ができます。", style: Styles.headlineStyleGrey13),
                            const SizedBox(height: 10),
                          
                            // Filterring Input Button
                            const SizedBox(height: 10),
                            Text("フィルタ入力ボタン", style: Styles.headlineStyle18),
                            const SizedBox(height: 10),
                            ToolButton(icon: Icons.filter_alt_outlined, pressEnable: true, width: screenSize.width/7),
                            const SizedBox(height: 10),
                            Text("「日時」「リクエスト」を指定して、一括で入力できます。", style: Styles.headlineStyleGrey13),
                            const SizedBox(height: 10),

                            // Draw Button                             
                            const SizedBox(height: 10),
                            Text("タッチ入力ボタン", style: Styles.headlineStyle18),
                            const SizedBox(height: 10),
                            ToolButton(icon: Icons.touch_app_outlined, pressEnable: true, width: screenSize.width/7),
                            const SizedBox(height: 10),
                            Text("細かい1マス単位の編集ができます。", style: Styles.headlineStyleGrey13),
                            Text("タップ後に表のマスをなぞることで割り当て状態を編集できます。", style: Styles.headlineStyleGrey13),
                            Text("入力する「リクエスト」は、ボタンを長押しすることで選択できます。", style: Styles.headlineStyleGrey13),
                            Text("注意 : 使用中、表のスクロールが無効化されます。スクロールが必要な場合は、もう一度「タッチ入力ボタン」をタップし、無効化してください。", style: Styles.headlineStyleRed13),

                            // Redo / Undo Button
                            const SizedBox(height: 10),
                            Text("戻る・進む ボタン", style: Styles.headlineStyle18),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ToolButton(icon: Icons.undo, pressEnable: true, width: screenSize.width/7),
                                const SizedBox(width: 10),
                                ToolButton( icon: Icons.redo, pressEnable: true, width: screenSize.width/7)
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("編集したシフトリクエスト表を「前の状態」や「次の状態」に戻すことができます。", style: Styles.headlineStyleGrey13),
                            Text("注意 : 遡れる状態は最大50であり、一度管理者画面を閉じると過去の変更履歴は破棄されます。", style: Styles.headlineStyleRed13),
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
                  child: Text('閉じる', style: Styles.headlineStyleGreen13),
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
        var modalHeight  = screenSize.height * 0.5;
        var modalWidth   = screenSize.width - 10 - screenSize.width * 0.08;
        var paddingHeght = modalHeight * 0.04;
        var buttonHeight = modalHeight * 0.2;
        var widgetHeight = buttonHeight + paddingHeght * 2;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
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
                        child: CustomTextButton(
                          text:   weekSelect[selectorsIndex[0]],
                          enable:   false,
                          width:  modalWidth * (100 / 330),
                          height: buttonHeight,
                          onPressed: (){
                            setState(() {
                              buildSelectorModaleWindow(weekSelect, 0);
                            });
                          }
                        )
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("の", style: Styles.headlineStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text:   weekdaySelect[selectorsIndex[1]],
                        enable:   false,
                        width:  modalWidth * (100 / 330),
                        height: buttonHeight,
                        onPressed: (){
                          setState(() {
                            buildSelectorModaleWindow(weekdaySelect, 1);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("の", style: Styles.headlineStyleGrey13))),
                    SizedBox(height: widgetHeight, width: modalWidth * (100 / 330))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text:   timeDivs1List[selectorsIndex[2]],
                        enable:   false,
                        width:  modalWidth * (100 / 330),
                        height: buttonHeight,
                        onPressed: (){
                          setState(() {
                            buildSelectorModaleWindow(timeDivs1List, 2);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (15 / 330), child: Center(child: Text("~", style: Styles.headlineStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomTextButton(
                        text:   timeDivs2List[selectorsIndex[3]],
                        enable:   false,
                        width:  modalWidth * (100 / 330),
                        height: buttonHeight,
                        onPressed: (){
                          setState(() {
                            buildSelectorModaleWindow(timeDivs2List, 3);
                          });
                        }
                      ),
                    ),
                    SizedBox(height: widgetHeight, width: modalWidth * (50 / 330), child: Center(child: Text("の区分は", style: Styles.headlineStyleGrey13))),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: paddingHeght),
                      child: CustomIconButton(
                        icon:   (selectorsIndex[4] == 1) ? const Icon(Icons.circle_outlined, size: 20, color: Styles.primaryColor) : const Icon(Icons.clear, size: 20, color: Colors.red),
                        enable:   false,
                        width:  modalWidth * (65 / 330),
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
                        text:   "一括入力",
                        enable:   true,
                        width:  modalWidth,
                        height: buttonHeight * 0.8,
                        onPressed: (){
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
  ///  Range-Fill 条件を登録
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  Widget registerRangeFill(int index, String weekSelect, String weekdaySelect, String timeDivs1Select, String timeDivs2Select,  String requestSelect, BuildContext context) {
    return ReorderableDragStartListener(
      key: Key(index.toString()),
      index: index,
      child: Container(
        width: 300,
        height: 80,
        decoration: BoxDecoration(
          color: Styles.bgColor,
          border: Border.all(
            color: Styles.hiddenColor
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
                  Text(weekSelect,      style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(' の ',          style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(weekdaySelect,   style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(' の ',          style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(timeDivs1Select, style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(' - ',           style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(timeDivs2Select, style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(' は ',          style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                  Text(requestSelect,   style: Styles.headlineStyleGrey13, textHeightBehavior: Styles.defaultBehavior),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // widget._shiftTable.requestRules.remove(widget._shiftTable.requestRules[index]);
                setState(() {});
              },
              icon: const Icon(Icons.delete, size: 20),
              color: Styles.hiddenColor,
            ),
          ],
        ),
      ),
    );
  }
}