////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// my package
import 'package:shift/main.dart';
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/shift/shift_frame.dart';
import 'package:shift/src/mylibs/modal_window.dart';
import 'package:shift/src/mylibs/undo_redo.dart';
import 'package:shift/src/screens/createScreen/register_shift_frame.dart';

class CreateShiftTableWidget extends ConsumerStatefulWidget {
  const CreateShiftTableWidget({Key? key}) : super(key: key);
  @override
  CreateShiftTableWidgetState createState() => CreateShiftTableWidgetState();
}

class CreateShiftTableWidgetState extends ConsumerState<CreateShiftTableWidget> with SingleTickerProviderStateMixin {

    // シフト作成期間の日数を表す変数
  int _shiftManageRangeDuration   = 0;
  int _templateShiftDurationIndex = 0;
  int _templateRequestLimitIndex  = 5;
  
  List<DateTimeRange> _templateDateRange = [
    DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month + 1, 1), end: DateTime(DateTime.now().year, DateTime.now().month + 2, 0)),
    DateTimeRange(start: DateTime.now(), end: DateTime(DateTime.now().year, DateTime.now().month + 1, 1).subtract(const Duration(days: 7)))
  ]; 
  
  List<DateTimeRange> _customDateRange = [
    DateTimeRange(start: DateTime.now().add(const Duration(days: 11)), end: DateTime.now().add(const Duration(days: 30))),
    DateTimeRange(start: DateTime.now(), end: DateTime.now().add(const Duration(days: 9)))
  ]; 

  // シフト時間区部設定のための parameters
  static DateTime _startTime = DateTime(1, 1, 1,  9,  0);
  static DateTime _endTime   = DateTime(1, 1, 1, 21,  0);
  static DateTime _duration  = DateTime(1, 1, 1,  0, 30);
 
  // 時間区分のカスタムのための変数
  static List<TimeDivision>  _timeDivsTemp = [];
  static int                 _durationTemp = 30;
  
  bool       _isDark       = false;
  ShiftFrame _shiftFrame   = ShiftFrame();
  double     _appBarHeight = 0;     
  Size       _screenSize   = const Size(0, 0);

  static UndoRedo<List<TimeDivision>> undoredoCtrl = UndoRedo<List<TimeDivision>>(50);
  
  // TextField の動作をスムーズにするための変数
  final FocusNode focusNode = FocusNode();
  final TextEditingController textConroller = TextEditingController();
  
  // タブコントローラー
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ja_JP', null).then((_) => setState(() {}));
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // AppBar の高さの取得 & スクリーンサイズの取得
    _appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    _screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - _appBarHeight);
    
    // プロバイダーからのデータ取得
    ref.read(settingProvider).loadPreferences();
    _isDark     = ref.read(settingProvider).enableDarkTheme;
    _shiftFrame = ref.read(shiftFrameProvider).shiftFrame;

    // シフト表名の更新
    textConroller.text = _shiftFrame.shiftName;

    // シフト作成期間の日数を表す変数
    _shiftManageRangeDuration = _shiftFrame.shiftDateRange[0].start.subtract(const Duration(days: 1)).difference(_shiftFrame.shiftDateRange[1].end.add(const Duration(days: 1))).inDays+1;

    if(undoredoCtrl.buffer.isEmpty){
      insertBuffer(_shiftFrame.timeDivs);
    }

    return GestureDetector(
      onTap: () {
        focusNode.unfocus();
      },
      child: Scaffold(
        //AppBar
        appBar: AppBar(
          title: Text("シフト表の作成",style: MyStyle.headlineStyleGreen20),
          bottomOpacity: 2.0,
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
            TextButton(
              child:  const Icon(Icons.navigate_next_outlined, color: MyStyle.primaryColor, size: 45),
              onPressed: () {
                if(_shiftFrame.timeDivs.isEmpty){
                  _onCreateScheduleItemTapped(context, "1つ以上の時間区分を入力して下さい。");
                }else if(_shiftFrame.shiftName == ''){
                  _onCreateScheduleItemTapped(context, "シフト表の名前を指定して下さい。");
                }else if( _shiftManageRangeDuration < 1){
                  _onCreateScheduleItemTapped(context, "※ リクエストに対するシフト作成期間が必要なため、\n「リクエスト期間」「シフト期間」には1日以上の間隔を空けて下さい。");
                }else{
                  _shiftFrame.initTable();
                  ref.read(shiftFrameProvider).shiftFrame = _shiftFrame;
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const CheckShiftTableWidget()));
                }
              }
            )
          ],
        ),
        
        floatingActionButton: (_shiftFrame.timeDivs.isEmpty) ? null : Padding(
          padding: EdgeInsets.only(bottom: _screenSize.height/60, right: _screenSize.width/60),
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            foregroundColor: MyStyle.backgroundColor,
            backgroundColor: (undoredoCtrl.enableUndo()) ? MyStyle.primaryColor: MyStyle.hiddenColor,
            onPressed: (!undoredoCtrl.enableUndo()) ? null :(){
              timeDivsUndoRedo(true);
            },
            child: const Icon(Icons.undo, size: 40)
          ),
        ),

        extendBody: true,
        extendBodyBehindAppBar: true,
    
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ////////////////////////////////////////////////////////////////////////////
              /// シフト名の名前の入力
              ////////////////////////////////////////////////////////////////////////////
              SizedBox(height: _screenSize.height * 0.04 + _appBarHeight),
              if(ref.read(signInProvider).user == null)
              Column(
                children: [
                  Text("注意 : 未ログイン状態です。", style: MyStyle.defaultStyleRed15),
                  Text("シフト表を作成しても、登録できません。", style: MyStyle.defaultStyleRed15),
                  const SizedBox(height: 20),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: _screenSize.width * 0.04),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FittedBox(fit: BoxFit.fill, child: Text("① 作成するシフト表名を入力して下さい。（最大10文字）", style: MyStyle.defaultStyleGrey15))
                ),
              ),
              SizedBox(height: _screenSize.height * 0.02),

              SizedBox(
                width: _screenSize.width * 0.90,
                child: TextField(
                  controller: textConroller,
                  cursorColor: MyStyle.primaryColor,
                  style: MyStyle.headlineStyleGreen15,
                  focusNode: focusNode,
                  autofocus: false,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
                    prefixIconColor: MyStyle.primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: MyStyle.hiddenColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: MyStyle.primaryColor,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.input),
                    hintText: 'シフト表名 (例) 〇〇店シフト',
                    hintStyle: MyStyle.defaultStyleGrey15,
                    
                  ),
                  maxLength: 10,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.go,
                  onTap: (){FocusScope.of(context).requestFocus(focusNode);},
                  onChanged: (value){_shiftFrame.shiftName = value;},
                ),
              ),
              Divider(height: _screenSize.height * 0.04, thickness: 1),
        
              ////////////////////////////////////////////////////////////////////////////
              /// シフト期間とシフト希望入力期間を入力
              ////////////////////////////////////////////////////////////////////////////      
              Padding(
                padding: EdgeInsets.only(left: _screenSize.width * 0.04),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FittedBox(fit: BoxFit.fill, child: Text("② 「リクエスト期間」/「シフト期間」を設定して下さい。", style: MyStyle.defaultStyleGrey15))
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: MyStyle.primaryColor,
                labelStyle: MyStyle.headlineStyle13,
                labelColor: MyStyle.primaryColor,  
                unselectedLabelColor: Colors.grey, 
                tabs: const [
                  Tab(text: 'テンプレート'),
                  Tab(text: 'カスタム'),
                ],
                onTap: (int index){
                  if(index == 0){
                    _shiftFrame.shiftDateRange = _templateDateRange;
                  }else{
                    _shiftFrame.shiftDateRange = _customDateRange;
                  }
                },
              ),
              SizedBox(height: _screenSize.height * 0.02), 
              SizedBox(
                height: 200,
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: _screenSize.width * 0.05),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildInputBox(
                                "シフト表の周期",
                                SizedBox(
                                  width: _screenSize.width * 0.445,
                                  height: 40,
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
                                      showModalWindow(
                                        context,
                                        0.5,
                                        buildModalWindowContainer(
                                          context,
                                          List<Widget>.generate(templateShiftDurationSelect.length, (index) => Row(
                                              mainAxisAlignment:  MainAxisAlignment.center,
                                              children: [ 
                                                Text(templateShiftDurationSelect[index], style: MyStyle.headlineStyle13,textAlign: TextAlign.center),
                                              ],
                                            )
                                          ),
                                          0.5,
                                          (BuildContext context, int index){
                                            _templateShiftDurationIndex = index;
                                            updateTemplateShiftRange();                                  
                                            setState(() {});
                                          }
                                        )
                                      );
                                    },
                                    child: Text(templateShiftDurationSelect[_templateShiftDurationIndex], style: MyStyle.headlineStyleGreen15)
                                  ),
                                ),  
                              ),
                              SizedBox(width: _screenSize.width * 0.01),
                              buildInputBox(
                                "リクエスト入力期限",
                                SizedBox(
                                  width: _screenSize.width * 0.445,
                                  height: 40,
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
                                      showModalWindow(
                                        context,
                                        0.5,
                                        buildModalWindowContainer(
                                          context,
                                          List<Widget>.generate(templateRequestLimitSelect.length, (index) => Row(
                                              mainAxisAlignment:  MainAxisAlignment.center,
                                              children: [ 
                                                Text(templateRequestLimitSelect[index], style: MyStyle.headlineStyle13,textAlign: TextAlign.center),
                                              ],
                                            )
                                          ),
                                          0.5,
                                          (BuildContext context, int index){
                                            _templateRequestLimitIndex = index;
                                            updateTemplateShiftRange();
                                            setState(() {});
                                          }
                                        )
                                      );
                                    },
                                    child: Text(templateRequestLimitSelect[_templateRequestLimitIndex], style: MyStyle.headlineStyleGreen15)
                                  ),
                                ),  
                              ),
                            ],
                          ),
                          Table(
                            columnWidths: const <int, TableColumnWidth>{
                              0: IntrinsicColumnWidth(flex: 0.4),
                              1: IntrinsicColumnWidth(flex: 0.1),
                              2: IntrinsicColumnWidth(flex: 0.5),
                            },
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(
                                children: [
                                  Text('シフトリクエスト期間', style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.right),
                                  Text('  ⇨', style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(DateFormat('MM/dd', 'ja_JP').format(_templateDateRange[1].start), style: MyStyle.headlineStyleGreen15),
                                        Text(" - ", style: MyStyle.headlineStyleGreen15),
                                        Text(DateFormat('MM/dd', 'ja_JP').format(_templateDateRange[1].end), style: MyStyle.headlineStyleGreen15),
                                        Text(" [ ${(_templateDateRange[1].end.difference(_templateDateRange[1].start).inDays+1).toString().padLeft(2, ' ')}日 ]", style: MyStyle.headlineStyleGreen15),
                                      ],
                                    ),
                                  ),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('シフト期間', style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.right),
                                  Text('  ⇨', style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(DateFormat('MM/dd', 'ja_JP').format(_templateDateRange[0].start), style: MyStyle.headlineStyleGreen15),
                                        Text(" - ", style: MyStyle.headlineStyleGreen15),
                                        Text(DateFormat('MM/dd', 'ja_JP').format(_templateDateRange[0].end), style: MyStyle.headlineStyleGreen15),
                                        Text(" [ ${(_templateDateRange[0].end.difference(_templateDateRange[0].start).inDays+1).toString().padLeft(2, ' ')}日 ]", style: MyStyle.headlineStyleGreen15),
                                      ],
                                    ),
                                  ),
                                ]
                              ),
                              TableRow(
                                children: [
                                  Text('シフト作成期間',  style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.right),
                                  Text('  ⇨', style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: (_templateDateRange[0].start.subtract(const Duration(days: 1)).difference(_templateDateRange[1].end.add(const Duration(days: 1))).inDays+1 <= 0)
                                      ? Text("確保できません", style: MyStyle.defaultStyleRed15)
                                      : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(DateFormat('MM/dd', 'ja_JP').format(_templateDateRange[1].end.add(const Duration(days: 1))), style: MyStyle.headlineStyleGreen15),
                                          Text(" - ", style: MyStyle.headlineStyleGreen15),
                                          Text(DateFormat('MM/dd', 'ja_JP').format(_templateDateRange[0].start.subtract(const Duration(days: 1))), style: MyStyle.headlineStyleGreen15),
                                          Text(" [ ${(_templateDateRange[0].start.subtract(const Duration(days: 1)).difference(_templateDateRange[1].end.add(const Duration(days: 1))).inDays+1).toString().padLeft(2, ' ')}日 ]", style: MyStyle.headlineStyleGreen15),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: _screenSize.width * 0.05),
                      child: Table(
                        columnWidths: const <int, TableColumnWidth>{
                          0: IntrinsicColumnWidth(flex: 0.4),
                          1: IntrinsicColumnWidth(flex: 0.1),
                          2: IntrinsicColumnWidth(flex: 0.5),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            children: [
                              Text('シフトリクエスト期間', style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.right),
                              Text('  ⇨', style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.center),
                              SizedBox(width: _screenSize.width*0.45, child: buildInputBox("", buildDateRangePicker(_customDateRange, 1)))
                            ]
                          ),
                          TableRow(
                            children: [
                              Text('シフト期間', style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.right),
                              Text('  ⇨', style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.center),
                              SizedBox(width: _screenSize.width*0.45, child: buildInputBox("", buildDateRangePicker(_customDateRange, 0)))
                            ]
                          ),
                          TableRow(
                            children: [
                              Text('シフト作成期間',  style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.right),
                              Text('  ⇨', style:  MyStyle.defaultStyleGrey15, textAlign: TextAlign.center),
                              SizedBox(
                                height: 40,
                                child: Center(
                                  child: (_customDateRange[0].start.subtract(const Duration(days: 1)).difference(_customDateRange[1].end.add(const Duration(days: 1))).inDays+1 <= 0)
                                  ? Text("確保できません", style: MyStyle.defaultStyleRed15)
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(DateFormat('MM/dd', 'ja_JP').format(_customDateRange[1].end.add(const Duration(days: 1))), style: MyStyle.headlineStyleGreen15),
                                      Text(" - ", style: MyStyle.headlineStyleGreen15),
                                      Text(DateFormat('MM/dd', 'ja_JP').format(_customDateRange[0].start.subtract(const Duration(days: 1))), style: MyStyle.headlineStyleGreen15),
                                      Text(" [ ${(_customDateRange[0].start.subtract(const Duration(days: 1)).difference(_customDateRange[1].end.add(const Duration(days: 1))).inDays+1).toString().padLeft(2, ' ')}日 ]", style: MyStyle.headlineStyleGreen15),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: _screenSize.height * 0.04),
              Divider(height: _screenSize.height * 0.04, thickness: 1),
        
              ////////////////////////////////////////////////////////////////////////////
              /// 基本時間区分の入力
              ////////////////////////////////////////////////////////////////////////////
              Padding(
                padding: EdgeInsets.only(left: _screenSize.width * 0.04),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FittedBox(fit: BoxFit.fill, child: Text("③ 基本となる時間区分を設定して下さい。", style: MyStyle.defaultStyleGrey15))),
              ),
              SizedBox(height: _screenSize.height * 0.04),
        
              SizedBox(
                width: _screenSize.width * 0.90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildInputBox("始業時間", buildTimePicker(_startTime, DateTime(1,1,1,0,0), DateTime(1,1,1,23,59), 5, setStartTime)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Text("〜", style: MyStyle.headlineStyleGreen15),
                    ),
                    buildInputBox("終業時間", buildTimePicker(_endTime, _startTime.add(const Duration(hours: 1)), DateTime(1,1,1,23,59), 5, setEndTime)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Text("...", style: MyStyle.headlineStyleGreen15),
                    ),
                    buildInputBox("管理間隔", buildTimePicker(_duration, DateTime(1,1,1,0,10), DateTime(1,1,1,6,0), 5, setDuration)),
                  ],
                ),
              ),
              SizedBox(height: _screenSize.height * 0.02),
              SizedBox(
                width: _screenSize.width * 0.9,
                height: 40,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    shadowColor: MyStyle.primaryColor, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: MyStyle.primaryColor),
                  ),
                  onPressed: () {
                    setState(() {
                      createMimimumDivision(_startTime, _endTime, _duration);
                      insertBuffer(_shiftFrame.timeDivs);
                    });
                  },
                  child: Text("入力", style: MyStyle.headlineStyleGreen15),
                ),
              ),
              Divider(height: _screenSize.height * 0.04, thickness: 1),
        
              ////////////////////////////////////////////////////////////////////////////
              /// 登録した時間区分一覧
              ////////////////////////////////////////////////////////////////////////////
              Text("時間区分一覧（タップで結合）", style: MyStyle.defaultStyleGrey15, textAlign: TextAlign.left),
              SizedBox(height: _screenSize.height * 0.04),
              (_shiftFrame.timeDivs.isEmpty) ? Text("登録されている時間区分がありません", style: MyStyle.defaultStyleGrey15) : buildScheduleEditor(),
              SizedBox(height: _screenSize.height * 0.04),
            ],
          ),
        )
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  redo undo 機能の実装
  ////////////////////////////////////////////////////////////////////////////////////////////
  void insertBuffer(List<TimeDivision> timeDivs){
    setState(() {
      undoredoCtrl.insertBuffer(timeDivs.map((e) => TimeDivision.copy(e)).toList());
    });
  }

  void timeDivsUndoRedo(bool undo){
    setState(() {
      if(undo){
        _shiftFrame.timeDivs = undoredoCtrl.undo().map((e) => TimeDivision.copy(e)).toList();
      }else{
        _shiftFrame.timeDivs = undoredoCtrl.redo().map((e) => TimeDivision.copy(e)).toList();
      }
    });
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// シフト期間テンプレートを使った時の処理
  ////////////////////////////////////////////////////////////////////////////////////////////
  void updateTemplateShiftRange(){
    var now = DateTime.now().subtract(const Duration(days: 1));
    
    DateTime startDate  = now;
    DateTime endDate    = now;
    
    if(_templateShiftDurationIndex == 0){ // 月ごとの場合
      startDate = DateTime(now.year, now.month + 1, 1);
      endDate   = DateTime(now.year, now.month + 2, 0);
    }else if(_templateShiftDurationIndex == 1){ // 二週毎の場合
      DateTime startOfThisWeek = now.subtract(Duration(days: now.add(const Duration(days: 1)).weekday - 2));
      startDate = startOfThisWeek.add(const Duration(days: 7));
      endDate   = startDate.add(const Duration(days: 13));
    }else if(_templateShiftDurationIndex == 2){ // 一週毎の場合
      DateTime startOfThisWeek = now.subtract(Duration(days: now.add(const Duration(days: 1)).weekday - 2));
      startDate = startOfThisWeek.add(const Duration(days: 7));
      endDate   = startDate.add(const Duration(days: 6));
    }else{
      print("index error");
    }
    _templateDateRange = [
      DateTimeRange(start: startDate, end: endDate),  
      (_templateDateRange[0].start.subtract(const Duration(days: 1)).difference(_templateDateRange[1].end.add(const Duration(days: 1))).inDays+1 <= 0)
      ? DateTimeRange(start: now, end: now)
      : DateTimeRange(start: now, end: startDate.subtract(Duration(days: 7-_templateRequestLimitIndex)))
    ]; 
    _shiftFrame.shiftDateRange = _templateDateRange;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// 確認ボタンを押した時の処理
  /// 引数のmessageを表示
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  void _onCreateScheduleItemTapped(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('入力エラー\n', style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('OK', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildDateRangePicker(List<DateTimeRange> dateRange, int index){

    return SizedBox(
      height: 40,
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
          final x = pickDateRange(context, dateRange[index]);
          x.then((value) => dateRange[index] = value);
          _shiftFrame.shiftDateRange = _customDateRange;
          setState(() {});
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat('MM/dd', 'ja_JP').format(dateRange[index].start), style: MyStyle.headlineStyleGreen15),
            Text(" - ", style: MyStyle.headlineStyleGreen15),
            Text(DateFormat('MM/dd', 'ja_JP').format(dateRange[index].end), style: MyStyle.headlineStyleGreen15),

            Text(" [ ${(dateRange[index].end.difference(dateRange[index].start).inDays+1).toString().padLeft(2, ' ')}日 ]", style: MyStyle.headlineStyleGreen15),
          ],
        ),
      ),
    );
  }

  Future<DateTimeRange> pickDateRange(BuildContext context, DateTimeRange initialDateRange) async {

    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange : initialDateRange,
      firstDate: DateTime.now().subtract(const Duration(days: 10)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              dividerColor: MyStyle.primaryColor.withAlpha(100),
              shadowColor: MyStyle.primaryColor,
              dayBackgroundColor : MaterialStateProperty.all<Color>(MyStyle.primaryColor),
              rangeSelectionBackgroundColor: MyStyle.primaryColor.withAlpha(100),
            ),
          ),
          child: child!,
        );
      },
    );
    if (newDateRange != null) {
      setState(() {});
      return Future<DateTimeRange>.value(newDateRange);
    } else {
      setState(() {});
      return Future<DateTimeRange>.value(initialDateRange);
    }
  } 
  
  Widget buildTimePicker(DateTime init, DateTime min, DateTime max, int interval, Function(DateTime) callback){
    
    DateTime temp = init;

    return SizedBox(
      height: 50,
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
        child: Text('${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}', style: MyStyle.headlineStyleGreen15)
      ),
    );
  }
  
  void setDuration(DateTime val){
    setState(() {
      _duration = val;
    });
  }
  void setStartTime(DateTime val){
    setState(() {   
      _startTime = val;
    });
  }
  void setEndTime(DateTime val){
    setState(() {
      _endTime = val;    
    });
  }

  Widget buildInputBox(String title, Widget child){
    return Column(
      children: [
       if(title != "")
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(title, style: MyStyle.defaultStyleGrey15),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: child,
        )
      ],
    );
  }

  void createMimimumDivision(DateTime start, DateTime end, DateTime duration){
    setState(() {
      _shiftFrame.timeDivs.clear();
      while(start.compareTo(end) < 0){
        var temp = start.add(Duration(hours: duration.hour, minutes: duration.minute));
        if(temp.compareTo(end) > 0){
          temp = end;
        }
        _shiftFrame.addTimeDivision("${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}-${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}", DateTime(1, 1, 1, start.hour, start.minute), DateTime(1, 1, 1, temp.hour, temp.minute));
        start = temp;
      }
      _timeDivsTemp = List.of(_shiftFrame.timeDivs);
      _durationTemp = _duration.hour*60+_duration.minute;
    });
  }

  ///////////////////////////////////////////////////////////////////////////////////
  /// Build Schedule Editor
  ///////////////////////////////////////////////////////////////////////////////////
  
  buildScheduleEditor(){
    double height = 40;
    double boader = 3;

    var timeDivs = _shiftFrame.timeDivs;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: Column(
            children: [
              for(final timeDiv in _timeDivsTemp)
                SizedBox(
                  height: height + boader,
                  child: Text(
                    "${timeDiv.startTime.hour.toString().padLeft(2, '0')}:${timeDiv.startTime.minute.toString().padLeft(2, '0')}-",
                    style: MyStyle.defaultStyleGrey15, textHeightBehavior: MyStyle.defaultBehavior,
                    textAlign: TextAlign.center, overflow: TextOverflow.ellipsis
                  )
                ),
              SizedBox(
                height: height + boader,
                child: Text(
                  "${_timeDivsTemp.last.endTime.hour.toString().padLeft(2, '0')}:${_timeDivsTemp.last.endTime.minute.toString().padLeft(2, '0')}-",
                  style: MyStyle.defaultStyleGrey15,
                  textHeightBehavior: MyStyle.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(5)),
              for(int i = 0; i < _shiftFrame.timeDivs.length; i++)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(boader/2),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if(i+1 != timeDivs.length){
                            timeDivs[i].endTime =  timeDivs[i+1].endTime;
                            timeDivs[i].name = "${timeDivs[i].startTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].startTime.minute.toString().padLeft(2, '0')}-${timeDivs[i].endTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].endTime.minute.toString().padLeft(2, '0')}";
                            timeDivs.removeAt(i+1);
                          }
                        });
                        insertBuffer(timeDivs);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: MyStyle.hiddenColor
                          ),
                          borderRadius: BorderRadius.circular(5.0)
                        ),
                        height: (height*(( (timeDivs[i].endTime.hour*60 + timeDivs[i].endTime.minute) - (timeDivs[i].startTime.hour*60+timeDivs[i].startTime.minute) ) / _durationTemp).ceil())
                        +(boader*((((timeDivs[i].endTime.hour*60 + timeDivs[i].endTime.minute) - (timeDivs[i].startTime.hour*60+timeDivs[i].startTime.minute)) / _durationTemp).ceil()-1)),
                        child: Center(
                          child: Text(
                            "${timeDivs[i].startTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].startTime.minute.toString().padLeft(2, '0')} - ${timeDivs[i].endTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].endTime.minute.toString().padLeft(2, '0')}",
                            style: MyStyle.headlineStyleGreen15,
                            textHeightBehavior: MyStyle.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis
                          )
                        )
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
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
              title: Text("「シフト表の作成画面①」の使い方", style:  MyStyle.headlineStyleGreen20, textAlign: TextAlign.center),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.95,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("この画面では、シフト表の基本設定を行います。", style: MyStyle.defaultStyleGrey13),
                            Text("以下の各項目を入力して下さい。", style: MyStyle.defaultStyleGrey13),
                          ],
                        ),
                      ), 
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("1. シフト表名", style: MyStyle.headlineStyle15),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // hou to use Followed Shift
                            const SizedBox(height: 10),
                            Text("「作成するシフト表」の名前を入力して下さい。", style: MyStyle.defaultStyleGrey13),
                            Text("最大文字数は10文字です。", style: MyStyle.defaultStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset("assets/how_to_use/create_1_1.png"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("2. シフト期間 / リクエスト期間", style: MyStyle.headlineStyle15),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // hou to use Followed Shift
                            const SizedBox(height: 10),
                            Text("　　「シフト期間」... 作成するシフト表のシフト期間", style: MyStyle.defaultStyleGrey13),
                            Text("「リクエスト期間」... シフト表のリクエスト募集期間", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("例)", style: MyStyle.defaultStyleGrey13),
                            Text("'12/1 ~ 12/31' の間のシフトリクエストを '11/15 ~ 11/25' の間に受け取り、11/26 ~ 11/30 の間にシフトを組みたい場合", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("この場合、参考画像のように設定します。", style: MyStyle.defaultStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Image.asset("assets/how_to_use/create_1_2.png"),
                                  Image.asset("assets/how_to_use/create_1_3.png"),
                                ],
                              ),
                            ),
                            Text("「シフト期間」と「リクエスト期間」の間の期間で、シフトを組みます。", style: MyStyle.defaultStyleGrey13),
                            Text("そのため「シフト期間」と「リクエスト期間」の間は１日以上の間隔が必要です。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("3. 基本の時間区分", style: MyStyle.headlineStyle15),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // hou to use Followed Shift
                            Text("「基本の時間区分」とは、シフト表の時間区分のことです。", style: MyStyle.defaultStyleGrey13),
                            Text("「始業時間」「就業時間」「管理間隔」を設定後、「入力ボタン」を押し、時間区分のリストを作成してください。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("例)", style: MyStyle.defaultStyleGrey13),
                            Text("始業時間 8:00 ~ 就業時間 22:00 で 1 時間間隔でシフトを組む場合", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("この場合、参考画像のように設定します。", style: MyStyle.defaultStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Image.asset("assets/how_to_use/create_1_4.png"),
                                  Image.asset("assets/how_to_use/create_1_5.png"),
                                ],
                              ),
                            ),
                            Text("「始業時間」「就業時間」は、平均的な勤務日の「始業時間」「就業時間」を設定してください。", style: MyStyle.defaultStyleGrey13),
                            Text("平日や休日で勤務時間が異なる場合は、できるだけ「勤務時間」が長い方に合わせましょう。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("「入力ボタン」を押すと「始業時間」から「就業時間」までの時間が「管理間隔」で分割されたリストが表示されます。", style: MyStyle.defaultStyleGrey13),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("4. 時間区分のカスタム", style: MyStyle.headlineStyle15),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text("各時間区分をタップすると、その下部の時間区分と連結できます。", style: MyStyle.defaultStyleGrey13),
                            Text("理想の時間区分にカスタマイズしましょう。", style: MyStyle.defaultStyleGrey13),
                            const SizedBox(height: 10),
                            Text("時間区分の変更履歴は「戻るボタン」で遡ることができます。", style: MyStyle.defaultStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Image.asset("assets/how_to_use/create_1_6.png"),
                                  Image.asset("assets/how_to_use/create_1_7.png"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("5. 次の画面へ", style: MyStyle.headlineStyle15),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text("各項目の入力が終了したら、画面右上の「次へボタン」より「勤務人数の設定画面」へと遷移します。", style: MyStyle.defaultStyleGrey13),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset("assets/how_to_use/create_1_8.png"),
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