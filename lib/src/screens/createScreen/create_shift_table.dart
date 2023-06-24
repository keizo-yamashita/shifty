import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// my package
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/functions/shift_table_provider.dart';
import 'package:shift/src/screens/createScreen/register_shift_table.dart';
import 'package:shift/src/functions/show_modal_window.dart';
import 'package:shift/src/functions/undo_redo.dart';

class CreateShiftTableWidget extends StatefulWidget {
  const CreateShiftTableWidget({Key? key}) : super(key: key);
  @override
  State<CreateShiftTableWidget> createState() => CreateShiftTableWidgetState();
}

class CreateShiftTableWidgetState extends State<CreateShiftTableWidget> {

  static DateTime _startTime = DateTime(1, 1, 1,  9,  0);
  static DateTime _endTime   = DateTime(1, 1, 1, 21,  0);
  static DateTime _duration  = DateTime(1, 1, 1,  0, 30);
  
  static List<TimeDivision>  _timeDivsTemp = [];
  static int                 _durationTemp = 30;

  ShiftTable _shiftTable = ShiftTable();

  static UndoRedo<List<TimeDivision>> undoredoCtrl = UndoRedo<List<TimeDivision>>(50);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ja_JP', null).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {

    _shiftTable = Provider.of<CreateShiftTableProvider>(context, listen: false).shiftTable;
    
    if(undoredoCtrl.buffer.isEmpty){
      insertBuffer(_shiftTable.timeDivs);
    }

    // set input text and cursor positon 
    final TextEditingController textConroller = TextEditingController(text: _shiftTable.name);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      textConroller.selection = TextSelection.fromPosition(TextPosition(offset: textConroller.text.length));
    });

    var appBarHeight = AppBar().preferredSize.height;
    var screenSize   = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        //AppBar
        appBar: AppBar(
          title: Text("新しいシフト表の作成",style: MyFont.headlineStyleGreen20),
          backgroundColor: MyFont.backgroundColor.withOpacity(0.9),
          foregroundColor: MyFont.hiddenColor,
          bottomOpacity: 2.0,
          elevation: 2.0,
          actions: [
            TextButton(
              child: Text("確認", style: MyFont.headlineStyleGreen20),
              onPressed: () {
                FocusScope.of(context).unfocus();
                if(_shiftTable.timeDivs.isEmpty){
                  _onCreateScheduleItemTapped(context, "1つ以上の時間区分を入力してください");
                }else if(_shiftTable.name == ''){
                  _onCreateScheduleItemTapped(context, "シフト表の名前を指定してください");
                }else{
                  _shiftTable.initTable();
                  Provider.of<CreateShiftTableProvider>(context, listen: false).shiftTable = _shiftTable;
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const CheckShiftTableWidget()));
                }
              }
            )
          ],
        ),
        
        floatingActionButton: (_shiftTable.timeDivs.isEmpty) ? null : Padding(
          padding: EdgeInsets.only(bottom: screenSize.height/40, right: screenSize.width/20),
          child: FloatingActionButton(
            foregroundColor: MyFont.backgroundColor,
            backgroundColor: (undoredoCtrl.enableUndo()) ? MyFont.primaryColor: MyFont.hiddenColor,
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
              SizedBox(height: screenSize.height/10 + appBarHeight),
              ////////////////////////////////////////////////////////////////////////////
              /// シフト名の名前の入力
              ////////////////////////////////////////////////////////////////////////////
              Text("作成するシフト表の名前を入力してください", style: MyFont.defaultStyleGrey15),
              SizedBox(height: screenSize.height/40),
              SizedBox(
                width: screenSize.width * 0.90,
                child: TextField(
                  controller: textConroller,
                  cursorColor: MyFont.primaryColor,
                  style: MyFont.headlineStyleGreen15,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                    prefixIconColor: MyFont.primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: MyFont.hiddenColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: MyFont.primaryColor,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.input),
                    hintText: 'シフト表名を入力してください',
                    hintStyle: MyFont.defaultStyleGrey15,
                    
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.go,
                  onChanged: (value){_shiftTable.name = value;},
                ),
              ),
              const Divider(height: 30, thickness: 1),

              ////////////////////////////////////////////////////////////////////////////
              /// シフト期間とシフト希望入力期間を入力
              ////////////////////////////////////////////////////////////////////////////      
              Text("「シフト期間」「シフト希望入力期間を入力しましょう", style: MyFont.defaultStyleGrey15),
              SizedBox(height: screenSize.height/40),
              SizedBox(
                width: screenSize.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: screenSize.width * 0.44,
                      child: buildInputBox(
                        "シフト期間",
                        buildDateRangePicker(_shiftTable.shiftDateRange, 0)
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.02),
                    SizedBox(
                      width: screenSize.width * 0.44,
                      child: buildInputBox(
                        "シフト希望入力期間",
                        buildDateRangePicker(_shiftTable.shiftDateRange, 1)
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 30, thickness: 1),

              ////////////////////////////////////////////////////////////////////////////
              /// 基本時間区分の入力
              ////////////////////////////////////////////////////////////////////////////
              Text("次に，基本となる時間区分を設定しましょう", style: MyFont.defaultStyleGrey15, textAlign: TextAlign.left),
              SizedBox(height: screenSize.height/40),
        
              SizedBox(
                width: screenSize.width * 0.90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildInputBox("始業時間", buildTimePicker(_startTime, DateTime(1,1,1,0,0), DateTime(1,1,1,23,59), 5, setStartTime)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Text(" 〜 ", style: MyFont.headlineStyleGreen15),
                    ),
                    buildInputBox("終業時間", buildTimePicker(_endTime, _startTime.add(const Duration(hours: 1)), DateTime(1,1,1,23,59), 5, setEndTime)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Text(" ... ", style: MyFont.headlineStyleGreen15),
                    ),
                    buildInputBox("管理間隔", buildTimePicker(_duration, DateTime(1,1,1,0,10), DateTime(1,1,1,6,0), 5, setDuration)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Text("     ", style: MyFont.headlineStyleGreen15),
                    ),
                    buildInputBox("", InkWell(
                      onTap: () {
                        setState(() {
                          createMimimumDivision(_startTime, _endTime, _duration);
                          insertBuffer(_shiftTable.timeDivs);
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 60,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: MyFont.primaryColor,
                          borderRadius: BorderRadius.circular(9), 
                        ),
                        child: const Icon(
                          size: 20,
                          Icons.check,  
                          color: MyFont.backgroundColor
                        ),
                      ),
                    ))
                  ],
                ),
              ),
        
              const Divider(height: 30, thickness: 1),
        
              ////////////////////////////////////////////////////////////////////////////
              /// 登録した時間区分一覧
              ////////////////////////////////////////////////////////////////////////////
              Text("時間区分一覧（クリックで結合）", style: MyFont.defaultStyleGrey15, textAlign: TextAlign.left),
              SizedBox(height: screenSize.height/40),
              (_shiftTable.timeDivs.isEmpty) ? Text("登録されている時間区分がありません", style: MyFont.defaultStyleGrey15) : buildScheduleEditor(),
              SizedBox(height: screenSize.height / 20),
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
      print("${undoredoCtrl.buffer.length} ${undoredoCtrl.bufferIndex}");
    });
  }

  void timeDivsUndoRedo(bool undo){
    setState(() {
      if(undo){
        _shiftTable.timeDivs = undoredoCtrl.undo().map((e) => TimeDivision.copy(e)).toList();
      }else{
        _shiftTable.timeDivs = undoredoCtrl.redo().map((e) => TimeDivision.copy(e)).toList();
      }
      print("undo");
      for(int i = 0; i < undoredoCtrl.buffer.length; i++){
        print("buffer : $i");
        for(int j = 0; j < undoredoCtrl.buffer[i].length; j++){
          print("${undoredoCtrl.buffer.length} ${undoredoCtrl.bufferIndex} ${undoredoCtrl.buffer[i][j].name} ${undoredoCtrl.buffer[i][j].startTime} ${undoredoCtrl.buffer[i][j].endTime}");
        }
      }
    });
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
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: MyFont.backgroundColor,
          shadowColor: MyFont.hiddenColor, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: MyFont.hiddenColor),
        ),
        onPressed: () async {
          final x = pickDateRange(context, dateRange[index]);
          x.then((value) => dateRange[index] = value);
          setState(() {});
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat('yy/MM/dd', 'ja_JP').format(dateRange[index].start), style: MyFont.headlineStyleGreen15),
            Text("-", style: MyFont.headlineStyleGreen15),
            Text(DateFormat('yy/MM/dd', 'ja_JP').format(dateRange[index].end), style: MyFont.headlineStyleGreen15),
          ],
        ),
      ),
    );
  }

  Future<DateTimeRange> pickDateRange(BuildContext context, DateTimeRange initialDateRange) async {

    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange : initialDateRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: MyFont.primaryColor),
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
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: MyFont.backgroundColor,
          shadowColor: MyFont.hiddenColor, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: MyFont.hiddenColor),
        ),
        onPressed: () async {
          await showModalWindow(context, 0.4, SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.maxFinite,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
                initialDateTime: init,
                minuteInterval: interval,
                minimumDate: min,
                maximumDate: max,
                onDateTimeChanged: (val){ setState(() { temp = val; callback(val); }); },
                use24hFormat: true,
              ),
            )
          );
        },
        child: Text('${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}', style: MyFont.headlineStyleGreen15)
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
        Container(
          child: child
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(title, style: MyFont.defaultStyleGrey15),
        )
      ],
    );
  }

  void createMimimumDivision(DateTime start, DateTime end, DateTime duration){
    setState(() {
      _shiftTable.timeDivs.clear();
      while(start.compareTo(end) < 0){
        var temp = start.add(Duration(hours: duration.hour, minutes: duration.minute));
        if(temp.compareTo(end) > 0){
          temp = end;
        }
        _shiftTable.addTimeDivision("${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}-${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}", DateTime(1, 1, 1, start.hour, start.minute), DateTime(1, 1, 1, temp.hour, temp.minute));
        start = temp;
      }
      _timeDivsTemp = List.of(_shiftTable.timeDivs);
      _durationTemp = _duration.hour*60+_duration.minute;
    });
  }

  ///////////////////////////////////////////////////////////////////////////////////
  /// Build Schedule Editor
  ///////////////////////////////////////////////////////////////////////////////////
  
  buildScheduleEditor(){
    double height = 40;
    double boader = 3;

    var timeDivs = _shiftTable.timeDivs;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 50,
          child: Column(
            children: [
              for(final timeDiv in _timeDivsTemp)
                SizedBox(
                  height: height + boader,
                  child: Text(
                    "${timeDiv.startTime.hour.toString().padLeft(2, '0')}:${timeDiv.startTime.minute.toString().padLeft(2, '0')}-",
                    style: MyFont.defaultStyleGrey15, textHeightBehavior: MyFont.defaultBehavior,
                    textAlign: TextAlign.center, overflow: TextOverflow.ellipsis
                  )
                ),
              SizedBox(
                height: height + boader,
                child: Text(
                  "${_timeDivsTemp.last.endTime.hour.toString().padLeft(2, '0')}:${_timeDivsTemp.last.endTime.minute.toString().padLeft(2, '0')}-",
                  style: MyFont.defaultStyleGrey15,
                  textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(5)),
              for(int i = 0; i < _shiftTable.timeDivs.length; i++)
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
                      splashColor: MyFont.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: MyFont.backgroundColor,
                          border: Border.all(
                            color: MyFont.hiddenColor
                          ),
                          borderRadius: BorderRadius.circular(5.0)
                        ),
                        height: (height*(( (timeDivs[i].endTime.hour*60 + timeDivs[i].endTime.minute) - (timeDivs[i].startTime.hour*60+timeDivs[i].startTime.minute) ) / _durationTemp).ceil())
                        +(boader*((((timeDivs[i].endTime.hour*60 + timeDivs[i].endTime.minute) - (timeDivs[i].startTime.hour*60+timeDivs[i].startTime.minute)) / _durationTemp).ceil()-1)),
                        child: Center(
                          child: Text(
                            "${timeDivs[i].startTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].startTime.minute.toString().padLeft(2, '0')} - ${timeDivs[i].endTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].endTime.minute.toString().padLeft(2, '0')}",
                            style: MyFont.headlineStyleGreen15,
                            textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis
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
}