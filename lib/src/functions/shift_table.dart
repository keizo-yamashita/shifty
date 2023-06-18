import 'package:flutter/material.dart';

List<String> weekSelect    = ["すべての週","第1週","第2週","第3週","第4週"];
List<String> weekdaySelect = ["すべての曜日","月曜日","火曜日","水曜日","木曜日","金曜日","土曜日","日曜日"];

class ShiftTable{
  late String              name;
  late List<AssignRule>    assignRules;
  late List<RequestRule>    requestRules;
  late List<TimeDivision>  timeDivs;
  late List<List<int>>     assignTable;
  late List<List<int>>     requestTable;
  late List<DateTimeRange> shiftDateRange;

  ShiftTable({
    String?              name,
    List<AssignRule>?    assignRules,
    List<RequestRule>?   requestRules,
    List<TimeDivision>?  timeDivs,
    List<List<int>>?     assignTable,
    List<List<int>>?     requestTable,
    List<DateTimeRange>? shiftDateRange,
  }) {
    this.name           = name ?? "";
    this.assignRules    = assignRules ?? <AssignRule>[];
    this.requestRules   = requestRules ?? <RequestRule>[];
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
  
  generateShiftTable(bool initFlag){
    /// 初期化を必要とする場合，及び時間区分，シフト期間が変更された場合に初期化
    if( initFlag || timeDivs.length != assignTable.length || 
        shiftDateRange[0].end.difference(shiftDateRange[0].start).inDays+1 != assignTable[0].length){
      
      assignTable = List<List<int>>.generate(
        timeDivs.length,
        (index) => List<int>.generate(shiftDateRange[0].end.difference(shiftDateRange[0].start).inDays+1, (index) => 0)
      );
    }
  }

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
}

class TimeDivision{
  DateTime startTime;
  DateTime endTime;
  String name;

  TimeDivision({
    required this.name,
    required this.startTime,
    required this.endTime
  });
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
