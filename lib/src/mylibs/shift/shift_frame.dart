////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shift/src/mylibs/style.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// grobal variable
////////////////////////////////////////////////////////////////////////////////////////////

const List<String> weekSelect                  = ["すべての週","第1週","第2週","第3週","第4週"];
const List<String> weekdaySelect               = ["すべての曜日","月曜日","火曜日","水曜日","木曜日","金曜日","土曜日","日曜日"];
const List<String> assignNumSelect             = ["0 人", "1 人", "2 人", "3 人", "4 人", "5 人", "6 人", "7 人", "8 人", "9 人", "10 人"];
const List<String> templateShiftDurationSelect = ["1月ごと", "2週間ごと", "1週間ごと"];
const List<String> templateRequestLimitSelect  = ["シフト開始 7 日前まで", "シフト開始 6 日前まで", "シフト開始 5 日前まで", "シフト開始 4 日前まで", "シフト開始 3 日前まで", "シフト開始 2 日前まで"];

List<List<Color>> colorTable = List<List<Color>>.generate(
  11,
  (index) => [
      Color.fromARGB(
        MyStyle.primaryColor.alpha,
        (200 - ((200 - MyStyle.primaryColor.red  ) * (index)~/10)).toInt(),
        (200 - ((200 - MyStyle.primaryColor.green) * (index)~/10)).toInt(),
        (200 - ((200 - MyStyle.primaryColor.blue ) * (index)~/10)).toInt()
      ),
      Colors.grey[600]!
    ]
  );

////////////////////////////////////////////////////////////////////////////////////////////
/// shift frame class
////////////////////////////////////////////////////////////////////////////////////////////

class ShiftFrame{

  late String              shiftId;
  late String              shiftName;
  late List<TimeDivision>  timeDivs;
  late List<DateTimeRange> shiftDateRange;
  late List<List<int>>     assignTable;
  late DateTime            updateTime;

  ShiftFrame([
    String?              shiftId,
    String?              shiftName,
    List<TimeDivision>?  timeDivs,
    List<DateTimeRange>? shiftDateRange,
    List<List<int>>?     assignTable,
    DateTime?            updateTime
  ]) {
    this.shiftId        = shiftId ?? "";
    this.shiftName      = shiftName ?? "";
    this.timeDivs       = timeDivs ?? <TimeDivision>[];
    this.shiftDateRange = shiftDateRange ?? [
      DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month + 1, 1), end: DateTime(DateTime.now().year, DateTime.now().month + 2, 0)),
      DateTimeRange(start: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day), end: DateTime(DateTime.now().year, DateTime.now().month + 1, 0))
    ];
    this.updateTime     = updateTime ?? DateTime.now();
    this.assignTable    = assignTable ?? <List<int>>[];
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表の作成関数
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  ShiftFrame initTable(){
    /// 初期化を必要とする場合，及び時間区分，シフト期間が変更された場合に初期化
    if(timeDivs.length != assignTable.length || 
        shiftDateRange[0].end.difference(shiftDateRange[0].start).inDays+1 != assignTable[0].length){
      
      assignTable = List<List<int>>.generate(
        timeDivs.length,
        (index) => List<int>.generate(shiftDateRange[0].end.difference(shiftDateRange[0].start).inDays+1, (index) => 0)
      );
    }

    return this;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表に勤務人数のルールを1つ適用
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  ShiftFrame applyRuleToShiftFrame(AssignRule rule){
    int startWeekday = shiftDateRange[0].start.weekday;
    List<int> fifo1 = List<int>.generate(0, (index) => index);
    List<int> fifo2 = List<int>.generate(0, (index) => index);
    
    int weekdayTemp = startWeekday;

    weekdayTemp = startWeekday;
    fifo1.clear();
    fifo2.clear();
    
    /// fifo1にルールを適応すべき週間を入れていく
    if(rule.week == 0){
      fifo1.addAll(List<int>.generate(assignTable[0].length, (index) => index));
    }else{
      fifo1.addAll(List<int>.generate(7, (index) => (rule.week - 1) * 7 + index));
    }
    // fifo1からfifo2へ特定の曜日のみを抽出する
    if(rule.weekday != 0){
      weekdayTemp = (fifo1[0] + weekdayTemp - 1) % 7  + 1;

      for(int i = 0; i < fifo1.length; i++){
        if(rule.weekday == weekdayTemp){
          fifo2.add(fifo1[i]);
        }
        weekdayTemp++;
        if(weekdayTemp > 7){
          weekdayTemp = weekdayTemp - 7;
        }
      }
    }else{
      fifo2 = fifo1;
    }
    // 指定された時間区分に対してルールを適応していく
    if(rule.timeDivs1 == 0){
      for(int i = 0; i < fifo2.length; i++){
        for(int j = 0; j < assignTable.length; j++){
          assignTable[j][fifo2[i]] = rule.assignNum;
        }
      }
    }else{
      for(int i = 0; i < fifo2.length; i++){
        if(rule.timeDivs2 == 0 || rule.timeDivs1 == rule.timeDivs2){
          assignTable[rule.timeDivs1-1][fifo2[i]] = rule.assignNum;
        }else{
          for(int j = rule.timeDivs1-1; j < rule.timeDivs2; j++){
            assignTable[j][fifo2[i]] = rule.assignNum;
          }
        }
      }
    }
    return this;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// 時間区分を追加する
  ////////////////////////////////////////////////////////////////////////////////////////////

  bool addTimeDivision(String name, DateTime startTime, DateTime endTime){
    for(int i = 0; i < timeDivs.length; i++){
      if(timeDivs[i].name == name){
        return false;
      }      
    }
    timeDivs.add(TimeDivision(name: name, startTime: startTime, endTime: endTime));
    return true;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  作成したシフト表を Firebase へ登録
  ////////////////////////////////////////////////////////////////////////////////////////////

  pushShiftFrame() async{

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth      auth      = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    final uid = user?.uid;

    final table = {
      'user-id'       : uid,
      'name'          : shiftName,
      'created-at'    : FieldValue.serverTimestamp(), 
      'request-start' : shiftDateRange[1].start,
      'request-end'   : shiftDateRange[1].end,
      'work-start'    : shiftDateRange[0].start,
      'work-end'      : shiftDateRange[0].end,
      'time-division' : FieldValue.arrayUnion( List.generate(timeDivs.length, (index) => { 'name' : timeDivs[index].name, 'start-time' : timeDivs[index].startTime, 'end-time' : timeDivs[index].endTime})),
      'assignment'    : assignTable.asMap().map((index, value) => MapEntry(index.toString(), value))
    };
    await firestore.collection('shift-leader').add(table);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  作成したシフト表を Firebase から取ってくる
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<ShiftFrame> pullShiftFrame(DocumentSnapshot<Object?> snapshotFrame) async{
    
    shiftId   = snapshotFrame.id;
    shiftName = snapshotFrame.get('name');
    
    var timeDivsMap = snapshotFrame.get('time-division');
    
    timeDivs = List<TimeDivision>.generate(
      timeDivsMap.length, (index) => TimeDivision(
        name: timeDivsMap[index]['name'],
        startTime: timeDivsMap[index]['start-time'].toDate(),
        endTime: timeDivsMap[index]['end-time'].toDate()
      )
    );

    shiftDateRange = [
      DateTimeRange(start: snapshotFrame.get('work-start').toDate(), end: snapshotFrame.get('work-end').toDate()),
      DateTimeRange(start: snapshotFrame.get('request-start').toDate(), end: snapshotFrame.get('request-end').toDate())
    ];
    
    var assignMap = snapshotFrame.get('assignment');

    updateTime = snapshotFrame.get('created-at').toDate();
    
    assignTable = List<List<int>>.generate(
      timeDivs.length,
      (index) => assignMap[index.toString()].cast<int>()
    );

    return this;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  インスタンスのコピーメソッド
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  ShiftFrame copy(){
    return ShiftFrame(
      shiftId,
      shiftName,
      timeDivs,
      shiftDateRange,
      assignTable
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// シフト表をカード化する
  ////////////////////////////////////////////////////////////////////////////////////////////  
  
  Widget buildShiftTableCard(String title, double width, int followersNum, Function onPressed, Function onPressedShare, bool isDark, Function onLongPressed){

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          SizedBox(
            width: width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                backgroundColor:  isDark ? Colors.grey[800] : MyStyle.backgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width:  width*0.6,
                        child: Text(
                          title, 
                          style: (DateTime.now().compareTo(shiftDateRange[0].end) <= 0) ? MyStyle.headlineStyleGreen15 : MyStyle.defaultStyleGrey15,
                          textHeightBehavior: MyStyle.defaultBehavior,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis
                        )
                      ),
                    ),
                    Text(
                      "　　シフト期間 : ${DateFormat('MM/dd').format(shiftDateRange[0].start)} - ${DateFormat('MM/dd').format(shiftDateRange[0].end)}",
                      style: (DateTime.now().compareTo(shiftDateRange[0].start) >= 0 && DateTime.now().compareTo(shiftDateRange[0].end) <= 0) ? MyStyle.headlineStyleGreen15 : MyStyle.defaultStyleGrey15,
                      textHeightBehavior: MyStyle.defaultBehavior,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis
                    ),
                    Text(
                      "リクエスト期間 : ${DateFormat('MM/dd').format(shiftDateRange[1].start)} - ${DateFormat('MM/dd').format(shiftDateRange[1].end)}",
                      style: (DateTime.now().compareTo(shiftDateRange[1].start) >= 0 && DateTime.now().compareTo(shiftDateRange[1].end) <= 0) ? MyStyle.headlineStyleGreen15 : MyStyle.defaultStyleGrey15,
                      textHeightBehavior: MyStyle.defaultBehavior,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis
                    ),
                    Text(
                      "　フォロワー数 : $followersNum 人",
                      style: MyStyle.defaultStyleGrey15,
                      textHeightBehavior: MyStyle.defaultBehavior,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis
                    ),
                  ],
                ),
              ),
              onPressed: () {
                onPressed();
              },
              onLongPress: () {
                onLongPressed();
              }
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: SizedBox(
              width: width * 0.4,
              child: Text(DateFormat('MM/dd hh:mm').format(updateTime), style: MyStyle.defaultStyleGrey15, textHeightBehavior: MyStyle.defaultBehavior, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)
            )
          ),
          if(DateTime.now().compareTo(shiftDateRange[0].end) <= 0)
          Positioned(
            left: 10,
            top: 0,
            child: SizedBox(
            width: width * 0.2,
              child: IconButton(
                onPressed: (){ onPressedShare(); },
                icon: const Icon(Icons.ios_share, size: 25, color: MyStyle.primaryColor)
              ),
            )
          )
        ],  
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
///  時間区分のクラス
////////////////////////////////////////////////////////////////////////////////////////////

class TimeDivision{
  TimeDivision({
    required this.name,
    required this.startTime,
    required this.endTime
  });

  DateTime startTime;
  DateTime endTime;
  String name;

  TimeDivision.copy(TimeDivision origin) : this(name: origin.name, startTime: origin.startTime, endTime: origin.endTime);
}

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト表一括入力のためのクラス
////////////////////////////////////////////////////////////////////////////////////////////

class AssignRule{
  AssignRule({
    required this.week,
    required this.weekday,
    required this.timeDivs1,
    required this.timeDivs2,
    required this.assignNum,
  });

  final int week;
  final int weekday;
  int timeDivs1;
  int timeDivs2;
  final int assignNum;
}