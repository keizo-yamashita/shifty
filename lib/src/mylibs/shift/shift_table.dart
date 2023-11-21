////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'dart:math';

import 'package:shift/src/mylibs/shift/shift_frame.dart';
import 'package:shift/src/mylibs/shift/shift_request.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// shift request class
////////////////////////////////////////////////////////////////////////////////////////////

class ShiftTable {
  late ShiftFrame                  shiftFrame;
  late List<ShiftRequest>          shiftRequests;
  late List<List<double>>          fitness;      
  late List<List<List<Candidate>>> shiftTable;

  ShiftTable(this.shiftFrame, this.shiftRequests){

    // init shiftTable
    shiftTable = List<List<List<Candidate>>>.generate(
      shiftFrame.assignTable.length,
      (index_1) => List<List<Candidate>>.generate(
        shiftFrame.assignTable[0].length,
        (index_2){
          List<Candidate> list = [];
          for(int index = 0; index < shiftRequests.length; index++){
            if(shiftRequests[index].requestTable[index_1][index_2] == 1){
              list.add(
                Candidate(index, (shiftRequests[index].responseTable[index_1][index_2] == 1))
              );
            }
          }
          return list;
        }
      )
    );

    // init Happiness
    fitness = List<List<double>>.generate(
      shiftRequests.length,
      (index) => [0,0,0,0,0,0,0]
    );
    calcFitness(0, 0, 0);
  }

  ////////////////////////////////////////////////////////////////////////////
  /// Response Table を Shift Table から作成する 
  ////////////////////////////////////////////////////////////////////////////
  void copyshiftTable2ResponseTable(){
    for(int timeIndex = 0; timeIndex < shiftTable.length; timeIndex++){
      for(int dateIndex = 0; dateIndex < shiftTable[timeIndex].length; dateIndex++){
        for(int requestIndex = 0; requestIndex < shiftTable[timeIndex][dateIndex].length; requestIndex++){
          var temp = shiftTable[timeIndex][dateIndex][requestIndex];
          shiftRequests[temp.userIndex].responseTable[timeIndex][dateIndex] = temp.assign ? 1 : 0;
        }
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  /// その時間区分に何人割り当てられているか確認する関数 
  ////////////////////////////////////////////////////////////////////////////
  bool getAssignedFin(int timeIndex, int dateIndex){
    int count = 0;
    for(int i = 0; i < shiftTable[timeIndex][dateIndex].length; i++){
      if(shiftTable[timeIndex][dateIndex][i].assign){
        count++;
      }
    }
    // 目標人数に達していない && 全員を割り当て終わっていない
    return !(count < shiftFrame.assignTable[timeIndex][dateIndex] && count != shiftTable[timeIndex][dateIndex].length);
  }

  ////////////////////////////////////////////////////////////////////////////
  /// 希望通過率を求める関数 
  /// ... 実行した瞬間の希望通過率を求める
  /// [0] ... 希望時間の合計
  /// [1] ... 勤務予定時間の合計
  /// [2] ... 希望通過率
  /// [3] ... 勤務日の数
  /// [4] ... １日の基本時間を超えた時間の合計
  /// [5] ... １日の最小勤務時間に満たない勤務時間の合計
  /// [6] ... 連日勤務の回数
  ////////////////////////////////////////////////////////////////////////////
  
  calcFitness(int baseTime, int minTime, int baseConDay){
    // date range
    int date = shiftFrame.shiftDateRange[0].end.difference(shiftFrame.shiftDateRange[0].start).inDays+1;
    int time = shiftFrame.timeDivs.length;
    List<int> duration = List.generate(time, (index) => shiftFrame.timeDivs[index].endTime.difference(shiftFrame.timeDivs[index].startTime).inMinutes);

    // init Happiness
    for(var requestIndex = 0; requestIndex < shiftRequests.length; requestIndex++){
      var request = shiftRequests[requestIndex];
      
      double requestTotal   = 0;
      double responseTotal  = 0;
      bool   assignDateFlag = false; // その日 assign されたかを示すフラグ
      int    assignDateCnt  = 0;     // assign された日をカウントするフラグ
      int    dailyTotal     = 0;     // １日の勤務時間
      int    baseTimeOver   = 0;     // １日の勤務時間の基本勤務時間を超過した時間の累積値
      int    minTimeUnder   = 0;     // １日の勤務時間が最短勤務時間に満たない時間の累積
      int    conDayCnt      = 0;     // 連続勤務回数 
      int    baseConDayOver = 0;     // 連続勤務回数 
                                               
      for(var column = 0; column < date; column++){
        dailyTotal = 0;                        
        for(var row = 0; row < time; row++){   
          if(shiftFrame.assignTable[row][column] != 0){
            if(request.requestTable[row][column] == 1){
              requestTotal += duration[row];   
              if(request.responseTable[row][column] == 1){
                dailyTotal += duration[row];
                // その日1日でも割り当てられたら， True
                assignDateFlag = true;
              }
            }
          }
        }
        if(assignDateFlag){
          conDayCnt++;
          assignDateCnt++;
          responseTotal += dailyTotal;
          if(baseTime != 0 && baseTime < dailyTotal){
            baseTimeOver += dailyTotal - baseTime;
          }
          if(minTime != 0 && minTime > dailyTotal){
            minTimeUnder += minTime - dailyTotal;
          }
          dailyTotal = 0;
        }else{
          if(baseConDay != 0 && baseConDay < conDayCnt){
            baseConDayOver += conDayCnt - baseConDay;
          }
          conDayCnt = 0;
        }
        assignDateFlag = false;
      }
      if(conDayCnt != 0){
        baseConDayOver += conDayCnt - baseConDay;
        conDayCnt = 0;
      }

      fitness[requestIndex][0] = requestTotal;
      fitness[requestIndex][1] = responseTotal;
      fitness[requestIndex][2] = (requestTotal != 0.0) ? responseTotal / requestTotal : 0.0;
      fitness[requestIndex][3] = assignDateCnt.toDouble();
      fitness[requestIndex][4] = baseTimeOver.toDouble();
      fitness[requestIndex][5] = minTimeUnder.toDouble();
      fitness[requestIndex][6] = baseConDayOver.toDouble();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  /// 自動でシフト表を入力する関数
  ////////////////////////////////////////////////////////////////////////////
  autoFill(int baseTime, int minTime, int baseConDay){
    int minMinutes = minTime;

    int date         = shiftFrame.shiftDateRange[0].end.difference(shiftFrame.shiftDateRange[0].start).inDays+1;
    int time         = shiftFrame.timeDivs.length;
    int totalMinutes = 0;

    // 全ての希望を初期化
    for(var row = 0; row < time; row++){
      for(var column = 0; column < date; column++){
        for(int i = 0; i < shiftTable[row][column].length; i++){
          shiftTable[row][column][i].assign = false;
          if(shiftFrame.assignTable[row][column] > 0){
            totalMinutes += shiftFrame.timeDivs[row].endTime.difference(shiftFrame.timeDivs[row].startTime).inMinutes;
          }
          shiftRequests[shiftTable[row][column][i].userIndex].responseTable[row][column] = 0;
        }
      }
    }

    // 各時間区分前後の連続勤務可能時間 table[requesterIndex][DateIndex][timeIndex]
    var table = List<List<List<Piece>>>.generate(
      shiftRequests.length,
      (requestIndex) => List<List<Piece>>.generate(
        date,
        (dateIndex){
          // backward を作成
          List<Piece> list = [];
          Duration count = const Duration(hours: 0);
          for(int timeIndex = 0; timeIndex < time; timeIndex++){
            if(shiftRequests[requestIndex].requestTable[timeIndex][dateIndex] == 1){
              count += shiftFrame.timeDivs[timeIndex].endTime.difference(shiftFrame.timeDivs[timeIndex].startTime);
            }else{
              count = const Duration(hours: 0);
            }
            list.add(Piece(count, const Duration(hours: 0)));
          }
          // forward を作成
          int           currIndex = 0;
          List<Duration> buf      = [];
          for(int timeIndex = 0; timeIndex < time; timeIndex++){
            if(list[timeIndex].backward.inSeconds == 0){
              if(buf.isNotEmpty){
                for(Duration value in buf.reversed){
                  list[currIndex].forward = value;
                  currIndex++; 
                }
                currIndex++; 
                buf = [];
              }else{
                currIndex++;
              }
            }
            else{
              buf.add(list[timeIndex].backward);
            }
          }
          if(buf.isNotEmpty){
            for(Duration value in buf.reversed){
              list[currIndex].forward = value;
              currIndex++;  
            }
          }
          return list;
        }
      )
    );
    
    // 最初は必ず割り当てる必要がある人を割り当てる
    for(var row = 0; row < shiftTable.length; row++){
      for(var column = 0; column < shiftTable[row].length; column++){
        // 制限人数の限界まで割り当てる
        if(shiftTable[row][column].length <= shiftFrame.assignTable[row][column]){
          for(int i = 0; i < shiftTable[row][column].length; i++){            
            shiftTable[row][column][i].assign = true;
            shiftRequests[shiftTable[row][column][i].userIndex].responseTable[row][column] = 1;
          }
        }
      }
    }
    // １日ずつ割り当てていく
    for(int dateIndex = 0; dateIndex < date; dateIndex++){
      for(int timeIndex = 0; timeIndex < time; timeIndex++){
        // すでに割り当て人数に達しているか確認する
        while(!getAssignedFin(timeIndex, dateIndex)){
          List<SemiCandidate> semiCandidate = [];
          // 達していなければ，候補の候補者リストを作る
          for(int candidateIndax = 0; candidateIndax < shiftTable[timeIndex][dateIndex].length; candidateIndax++){
            if(!shiftTable[timeIndex][dateIndex][candidateIndax].assign){
              semiCandidate.add(SemiCandidate(candidateIndax, table[shiftTable[timeIndex][dateIndex][candidateIndax].userIndex][dateIndex][timeIndex].forward.inMinutes.clamp(0, minMinutes)));
            }
          }
          if(semiCandidate.isNotEmpty){
            double maxScore   = -10000000000000000000000.0;
            int maxScoreIndex = 0;
            
            for(int semiCandidateIndex = 0; semiCandidateIndex < semiCandidate.length; semiCandidateIndex++){

              // shiftRequest(Response) のバックアップ
              var shiftResponseBackup =  shiftRequests[shiftTable[timeIndex][dateIndex][semiCandidate[semiCandidateIndex].userIndex].userIndex].responseTable.map((e) => List.from(e).cast<int>()).toList();
              
              // 実際にシフトに当てはめる部分
              int changeDuration = semiCandidate[semiCandidateIndex].minutes;
              int count = 0; 
              while(changeDuration > 0){
                shiftRequests[shiftTable[timeIndex][dateIndex][semiCandidate[semiCandidateIndex].userIndex].userIndex].responseTable[timeIndex + count][dateIndex] = 1;
                changeDuration -= shiftFrame.timeDivs[timeIndex + count].endTime.difference(shiftFrame.timeDivs[timeIndex + count].startTime).inMinutes;
                count++;
              }

              double score = 0;
              for(int i = 0; i < shiftRequests.length; i++){
                calcFitness(baseTime, minTime, baseConDay+1);
                // 円の関数に従って勤務者の適合率を求める
                score += sqrt(1 - pow((fitness[i][2]) - 1, 2))*1000;
                score -= fitness[i][4];
                score -= fitness[i][5];
                score -= fitness[i][6]/date*100;
              }
              if(score > maxScore){
                maxScore      = score;
                maxScoreIndex = semiCandidateIndex;
              }
              // shiftRequest(Response) の復元
              shiftRequests[shiftTable[timeIndex][dateIndex][semiCandidate[semiCandidateIndex].userIndex].userIndex].responseTable = shiftResponseBackup.map((e) => List.from(e).cast<int>()).toList();
              
            }

            // 決定版のシフトを入力する部分
            int changeDuration = semiCandidate[maxScoreIndex].minutes;
            int count = 0; 
            while(changeDuration > 0){
              for(int i =0; i < shiftTable[timeIndex + count][dateIndex].length; i++){
                if(shiftRequests[shiftTable[timeIndex + count][dateIndex][i].userIndex].displayName == shiftRequests[shiftTable[timeIndex][dateIndex][semiCandidate[maxScoreIndex].userIndex].userIndex].displayName){
                  shiftTable[timeIndex + count][dateIndex][i].assign = true;
                  break;
                }
              }
              shiftRequests[shiftTable[timeIndex][dateIndex][semiCandidate[maxScoreIndex].userIndex].userIndex].responseTable[timeIndex + count][dateIndex] = 1;
              changeDuration -= shiftFrame.timeDivs[timeIndex + count].endTime.difference(shiftFrame.timeDivs[timeIndex + count].startTime).inMinutes;
              count++;
            }
          }
        }
      }
    }
  }

  pushShiftTable() async{
    for(var request in shiftRequests){
      request.updateShiftResponse();
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト希望表に希望ルールを1つ適用
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  ShiftTable applyRuleToShift(ShiftTableRule rule){
    int startWeekday =  shiftFrame.shiftDateRange[0].start.weekday;

    List<int> fifo1 = List<int>.generate(0, (index) => index);
    List<int> fifo2 = List<int>.generate(0, (index) => index);
    
    int weekdayTemp = startWeekday;

    weekdayTemp = startWeekday;
    fifo1.clear();
    fifo2.clear();
    
    if(rule.requester != 0){
      /// fifo1にルールを適応すべき週間を入れていく
      if(rule.week == 0){
        fifo1.addAll(List<int>.generate(shiftRequests[rule.requester-1].requestTable[0].length, (index) => index));
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
          for(int j = 0; j < shiftRequests[rule.requester-1].requestTable.length; j++){
            if(shiftRequests[rule.requester-1].requestTable[j][fifo2[i]] == 1){
              shiftRequests[rule.requester-1].responseTable[j][fifo2[i]] = rule.response;
            }
          }
        }
      }else{
        for(int i = 0; i < fifo2.length; i++){
          if(rule.timeDivs2 == 0 || rule.timeDivs1 == rule.timeDivs2){
            if(shiftFrame.assignTable[rule.timeDivs1-1][fifo2[i]] != 0){
              if(shiftRequests[rule.requester-1].requestTable[rule.timeDivs1-1][fifo2[i]] == 1){
                shiftRequests[rule.requester-1].responseTable[rule.timeDivs1-1][fifo2[i]] = rule.response;
              }
            }
          }else{
            for(int j = rule.timeDivs1-1; j < rule.timeDivs2; j++){
              if(shiftFrame.assignTable[j][fifo2[i]] != 0){
                if(shiftRequests[rule.requester-1].requestTable[j][fifo2[i]] == 1){
                  shiftRequests[rule.requester-1].responseTable[j][fifo2[i]] = rule.response;
                }
              }
            }
          }
        }
      }
    }else{
      for(int requesterIndex = 0; requesterIndex < shiftRequests.length; requesterIndex++){
        /// fifo1にルールを適応すべき週間を入れていく
        if(rule.week == 0){
          fifo1.addAll(List<int>.generate(shiftRequests[requesterIndex].requestTable[0].length, (index) => index));
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
            for(int j = 0; j < shiftRequests[requesterIndex].requestTable.length; j++){
              if(shiftRequests[requesterIndex].requestTable[j][fifo2[i]] == 1){
                shiftRequests[requesterIndex].responseTable[j][fifo2[i]] = rule.response;
              }
            }
          }
        }else{
          for(int i = 0; i < fifo2.length; i++){
            if(rule.timeDivs2 == 0 || rule.timeDivs1 == rule.timeDivs2){
              if(shiftFrame.assignTable[rule.timeDivs1-1][fifo2[i]] != 0){
                if(shiftRequests[requesterIndex].requestTable[rule.timeDivs1-1][fifo2[i]] == 1){
                  shiftRequests[requesterIndex].responseTable[rule.timeDivs1-1][fifo2[i]] = rule.response;
                }
              }
            }else{
              for(int j = rule.timeDivs1-1; j < rule.timeDivs2; j++){
                if(shiftFrame.assignTable[j][fifo2[i]] != 0){
                  if(shiftRequests[requesterIndex].requestTable[j][fifo2[i]] == 1){
                    shiftRequests[requesterIndex].responseTable[j][fifo2[i]] = rule.response;
                  }
                }
              }
            }
          }
        }
      }    
    }

    // init shiftTable
    shiftTable = List<List<List<Candidate>>>.generate(
      shiftFrame.assignTable.length,
      (index_1) => List<List<Candidate>>.generate(
        shiftFrame.assignTable[0].length,
        (index_2){
          List<Candidate> list = [];
          for(int index = 0; index < shiftRequests.length; index++){
            if(shiftRequests[index].requestTable[index_1][index_2] == 1){
              list.add(
                Candidate(index, (shiftRequests[index].responseTable[index_1][index_2] == 1))
              );
            }
          }
          return list;
        }
      )
    );

    // init Happiness
    fitness = List<List<double>>.generate(
      shiftRequests.length,
      (index) => [0,0,0,0,0,0,0]
    );
    calcFitness(0, 0, 0);

    return this;
  }
}

class Candidate{
  final int userIndex;
  bool assign;
  Candidate(this.userIndex, this.assign);

  Candidate copy(){
    return Candidate(userIndex, assign);
  }
}

class SemiCandidate{
  final int userIndex;
  int minutes;
  SemiCandidate(this.userIndex, this.minutes);
}

class Piece{
  Duration backward;
  Duration forward;
  Piece(this.backward, this.forward);
}

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト希望一括入力のためのクラス
////////////////////////////////////////////////////////////////////////////////////////////

class ShiftTableRule{
  ShiftTableRule({
    required this.week,
    required this.weekday,
    required this.timeDivs1,
    required this.timeDivs2,
    required this.response,
    required this.requester,
  });

  final int week;
  final int weekday;
  int timeDivs1;
  int timeDivs2;
  final int response;
  final int requester;
}