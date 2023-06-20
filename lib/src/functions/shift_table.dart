import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

List<String> weekSelect      = ["すべての週","第1週","第2週","第3週","第4週"];
List<String> weekdaySelect   = ["すべての曜日","月曜日","火曜日","水曜日","木曜日","金曜日","土曜日","日曜日"];
List<String> assignNumSelect = ["0 人", "1 人", "2 人", "3 人", "4 人", "5 人", "6 人", "7 人", "8 人", "9 人", "10 人"];

List<List<Color>> colorTable = [
  [ Colors.white, Colors.grey],
  [ Colors.green[50]!, Colors.grey], 
  [ Colors.green[100]!, Colors.grey], 
  [ Colors.green[200]!, Colors.grey], 
  [ Colors.green[300]!, Colors.grey], 
  [ Colors.green[400]!, Colors.grey], 
  [ Colors.green[500]!, Colors.grey], 
  [ Colors.green[600]!, Colors.grey], 
  [ Colors.green[700]!, Colors.white], 
  [ Colors.green[800]!, Colors.white], 
  [ Colors.green[900]!, Colors.white], 
];

class ShiftTable{
  late String              name;
  late List<TimeDivision>  timeDivs;
  late List<List<int>>     assignTable;
  late List<List<int>>     requestTable;
  late List<DateTimeRange> shiftDateRange;

  ShiftTable({
    String?              name,
    List<TimeDivision>?  timeDivs,
    List<List<int>>?     assignTable,
    List<List<int>>?     requestTable,
    List<DateTimeRange>? shiftDateRange,
  }) {
    this.name           = name ?? "";
    this.timeDivs       = timeDivs ?? <TimeDivision>[];
    this.assignTable    = assignTable ?? <List<int>>[];
    this.requestTable    = requestTable ?? <List<int>>[];
    this.shiftDateRange = shiftDateRange ?? [
      DateTimeRange(start: DateTime.now().add(const Duration(days: 10)), end: DateTime.now().add(const Duration(days: 20))),
      DateTimeRange(start: DateTime.now(), end: DateTime.now().add(const Duration(days: 9)))
    ];
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表の作成関数
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  initTable(){
    /// 初期化を必要とする場合，及び時間区分，シフト期間が変更された場合に初期化
    if(timeDivs.length != assignTable.length || 
        shiftDateRange[0].end.difference(shiftDateRange[0].start).inDays+1 != assignTable[0].length){
      
      assignTable = List<List<int>>.generate(
        timeDivs.length,
        (index) => List<int>.generate(shiftDateRange[0].end.difference(shiftDateRange[0].start).inDays+1, (index) => 0)
      );
    }
    if(timeDivs.length != requestTable.length || 
        shiftDateRange[0].end.difference(shiftDateRange[0].start).inDays+1 != requestTable[0].length){
      
      requestTable = List<List<int>>.generate(
        timeDivs.length,
        (index) => List<int>.generate(shiftDateRange[0].end.difference(shiftDateRange[0].start).inDays+1, (index) => 0)
      );
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表に勤務人数のルールを1つ適用
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  applyRuleToAssinTable(AssignRule rule){
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
          for(int i = rule.timeDivs1-1; i < rule.timeDivs2; i++){
            assignTable[rule.timeDivs1-1][fifo2[i]] = rule.assignNum;
          }
        }
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト希望表に希望ルールを1つ適用
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  applyRuleToRequestTable(RequestRule rule){
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
        for(int j = 0; j < requestTable.length; j++){
          requestTable[j][fifo2[i]] = rule.request;
        }
      }
    }else{
      for(int i = 0; i < fifo2.length; i++){
        if(rule.timeDivs2 == 0 || rule.timeDivs1 == rule.timeDivs2){
          requestTable[rule.timeDivs1-1][fifo2[i]] = rule.request;
        }else{
          for(int i = rule.timeDivs1-1; i < rule.timeDivs2; i++){
            requestTable[rule.timeDivs1-1][fifo2[i]] = rule.request;
          }
        }
      }
    }
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
  ///  作成したシフト表をFirebaseへ登録
  ////////////////////////////////////////////////////////////////////////////////////////////

  void pushShitTable() async{

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth      auth      = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    final uid = user?.uid;

    final table = {
      'user-id'       : uid,
      'name'          : name,
      'request-start' : shiftDateRange[1].start,
      'request-end'   : shiftDateRange[1].end,
      'work-start'    : shiftDateRange[0].start,
      'work-end'      : shiftDateRange[0].end,
      'time-division' : FieldValue.arrayUnion( List.generate(timeDivs.length, (index) => { 'name' : timeDivs[index].name, 'start-time' : timeDivs[index].startTime, 'end-time' : timeDivs[index].endTime})),
      'assignment'    : assignTable.asMap().map((index, value) => MapEntry(index.toString(), value))
    };

    var refarence = await firestore.collection('shift-table').add(table);

    final request = {
      'user-id'       : uid,
      'table-refarence' : refarence
    };

    await firestore.collection('shift-request').add(request);
  }

  void pullShiftTable(DocumentSnapshot<Object?> snapshot) async{
    
    name = snapshot.get('name');
    
    var timeDivsMap = snapshot.get('time-division');
    
    timeDivs = List<TimeDivision>.generate(
      timeDivsMap.length, (index) => TimeDivision(
        name: timeDivsMap[index]['name'],
        startTime: timeDivsMap[index]['start-time'].toDate(),
        endTime: timeDivsMap[index]['end-time'].toDate()
      )
    );

    shiftDateRange = [
      DateTimeRange(start: snapshot.get('work-start').toDate(), end: snapshot.get('work-end').toDate()),
      DateTimeRange(start: snapshot.get('request-start').toDate(), end: snapshot.get('request-end').toDate())
    ];
    
    var assignMap = snapshot.get('assignment');

    
    assignTable = List<List<int>>.generate(
      timeDivs.length,
      (index) => assignMap[index.toString()].cast<int>()
    );

    var requestMap = snapshot.get('request');

    requestTable = List<List<int>>.generate(
      timeDivs.length,
      (index) => requestMap[index.toString()].cast<int>()
    );
  }
}

class TimeDivision{
  TimeDivision({
    required this.name,
    required this.startTime,
    required this.endTime
  });

  DateTime startTime;
  DateTime endTime;
  String name;
}

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

class RequestRule{
  RequestRule({
    required this.week,
    required this.weekday,
    required this.timeDivs1,
    required this.timeDivs2,
    required this.request,
  });

  final int week;
  final int weekday;
  int timeDivs1;
  int timeDivs2;
  final int request;
}
