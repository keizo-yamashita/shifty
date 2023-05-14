List<String> weekSelect    = ["すべての週","第1週","第2週","第3週","第4週"];
List<String> weekdaySelect = ["すべての曜日","月曜日","火曜日","水曜日","木曜日","金曜日","土曜日","日曜日"];

class ShiftTable{
  late List<ShiftRule>     rules;
  late List<String>        timeDivs;
  late List<ShiftTableRow> assignTable;
  late DateTime            inputStartDate;
  late DateTime            inputEndDate;
  late DateTime            workStartDate;
  late DateTime            workEndDate;

  ShiftTable(){
    rules          = List<ShiftRule>.generate(0, (index) => ShiftRule(week: 0, weekday: 0, timeDivs: 0, assignNum: 0));
    timeDivs       = List<String>.generate(0, (index) => index.toString());
    assignTable    = List<ShiftTableRow>.generate(0, (index) => ShiftTableRow("", 0));
    inputStartDate = DateTime(1, 1, 1);
    inputEndDate   = DateTime(1, 1, 1);
    workStartDate  = DateTime(1, 1, 1);
    workEndDate    = DateTime(1, 1, 1);
  }

  generateShiftTable(){
    int startWeekday = workStartDate.weekday;
    int lastDay      = workEndDate.difference(workStartDate).inDays;
    assignTable      = List<ShiftTableRow>.generate(timeDivs.length, (index) => ShiftTableRow(timeDivs[index], lastDay));

    final List<int> fifo1 = List<int>.generate(0, (index) => index);
    final List<int> fifo2 = List<int>.generate(0, (index) => index);
    
    int weekdayTemp = startWeekday;
    
    for(int i = 0; i < assignTable.length; i++){
      for(int j = 0; j < assignTable[0].timeDivsAssign.length; j++){
        assignTable[i].timeDivsAssign[j] = 0;
      }
    }

    for(int rulesIndex = 0; rulesIndex < rules.length; rulesIndex++){
      weekdayTemp = startWeekday;
      fifo1.clear();
      fifo2.clear();
      if(rules[rulesIndex].week == 0){
        fifo1.addAll(List<int>.generate(assignTable[0].timeDivsAssign.length, (index) => index));
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
          for(int j = 0; j < assignTable.length; j++){
            assignTable[j].timeDivsAssign[fifo2[i]] = rules[rulesIndex].assignNum;
          }
        }
      }else{
        for(int i = 0; i < fifo2.length; i++){
          assignTable[rules[rulesIndex].timeDivs-1].timeDivsAssign[fifo2[i]] = rules[rulesIndex].assignNum;
        }
      }
    }
  }

  bool addTimeDivison(String input){
    for(int i = 0; i < timeDivs.length; i++){
      if(timeDivs[i] == input){
        return false;
      }      
    }
    timeDivs.add(input);
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
    final String item = timeDivs.removeAt(oldIndex);
    timeDivs.insert(newIndex, item);
  }
}

class ShiftTableRow{
  late String timeDivsName;
  late List<int> timeDivsAssign;

  ShiftTableRow(String timeDivsName_, int lastDay){
    timeDivsName = timeDivsName_;
    timeDivsAssign = List<int>.generate(lastDay, (index) => 0);
  }
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
