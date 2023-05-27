import 'package:flutter/material.dart';

List<String> weekSelect    = ["すべての週","第1週","第2週","第3週","第4週"];
List<String> weekdaySelect = ["すべての曜日","月曜日","火曜日","水曜日","木曜日","金曜日","土曜日","日曜日"];

class ShiftTable{
  late List<ShiftRule>     rules;
  late List<TimeDivision>  timeDivs;
  late List<List<String>>  assignTable;
  late DateTime            inputStartDate;
  late DateTime            inputEndDate;
  late DateTime            workStartDate;
  late DateTime            workEndDate;

  ShiftTable(){
    rules          = <ShiftRule>[];
    timeDivs       = <TimeDivision>[];
    assignTable    = <List<String>>[];
    inputStartDate = DateTime(1, 1, 1);
    inputEndDate   = DateTime(1, 1, 1);
    workStartDate  = DateTime(1, 1, 1);
    workEndDate    = DateTime(1, 1, 1);
  }

  generateShiftTable(){
    int startWeekday = workStartDate.weekday;
    assignTable      = List<List<String>>.generate(workEndDate.difference(workStartDate).inDays+1, (index) => List<String>.generate(timeDivs.length, (index) => 0.toString()));

    final List<int> fifo1 = List<int>.generate(0, (index) => index);
    final List<int> fifo2 = List<int>.generate(0, (index) => index);
    
    int weekdayTemp = startWeekday;

    for(int rulesIndex = 0; rulesIndex < rules.length; rulesIndex++){
      weekdayTemp = startWeekday;
      fifo1.clear();
      fifo2.clear();
      if(rules[rulesIndex].week == 0){
        fifo1.addAll(List<int>.generate(assignTable.length, (index) => index));
      }else{
        fifo1.addAll(List<int>.generate(7, (index) => (rules[rulesIndex].week - 1) * 7 + index));
      }

      if(rules[rulesIndex].weekday != 0){
        weekdayTemp = (fifo1[0] + weekdayTemp - 1) % 7  + 1;

        for(int i = 0; i < fifo1.length; i++){
          if(rules[rulesIndex].weekday == weekdayTemp){
            fifo2.add(fifo1[i]);
          }
          weekdayTemp++;
          if(weekdayTemp > 7){
            weekdayTemp = weekdayTemp - 7;
          }
        }
      }else{
        for(int i = 0; i < fifo1.length; i++){
          fifo2.add(fifo1[i]);
        }
      }

      if(rules[rulesIndex].timeDivs == 0){
        for(int i = 0; i < fifo2.length; i++){
          for(int j = 0; j < assignTable[0].length; j++){
            assignTable[fifo2[i]][j] = rules[rulesIndex].assignNum.toString();
          }
        }
      }else{
        for(int i = 0; i < fifo2.length; i++){
          assignTable[fifo2[i]][rules[rulesIndex].timeDivs-1] = rules[rulesIndex].assignNum.toString();
        }
      }
    }
  }

  bool addTimeDivision(String name, TimeOfDay startTime, TimeOfDay endTime){
    for(int i = 0; i < timeDivs.length; i++){
      if(timeDivs[i].name == name){
        return false;
      }      
    }
    timeDivs.add(TimeDivision(name: name, startTime: startTime, endTime: endTime));
    return true;
  }

  removeTimeDivision(int index){
    timeDivs.removeAt(index);
    for(int i = 0; i < rules.length; i++){
      if(rules[i].timeDivs == index + 1){
        rules.removeAt(i);
      }
    }
  }

  sortTimeDivision(int oldIndex, int newIndex){
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    for(int i = 0; i < rules.length; i++){
      if(rules[i].timeDivs == (oldIndex+1)){
        rules[i].timeDivs = newIndex+1;
      }else if((newIndex + 1 <= rules[i].timeDivs) && (rules[i].timeDivs < oldIndex + 1)){
        rules[i].timeDivs += 1;
      }else if((oldIndex + 1 < rules[i].timeDivs) && (rules[i].timeDivs <= newIndex + 1)){
        rules[i].timeDivs -= 1;
      }
    }
    final TimeDivision item = timeDivs.removeAt(oldIndex);
    timeDivs.insert(newIndex, item);
  }
}

class TimeDivision{
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String name;

  TimeDivision({
    required this.name,
    required this.startTime,
    required this.endTime
  });
}

class ShiftRule{
  ShiftRule({
    required this.week,
    required this.weekday,
    required this.timeDivs,
    required this.assignNum,
  });

  final int week;
  final int weekday;
  int timeDivs;
  final int assignNum;
}
