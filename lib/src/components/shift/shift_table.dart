////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'dart:math';

import 'package:shift/src/components/shift/shift_frame.dart';
import 'package:shift/src/components/shift/shift_request.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// shift request class
////////////////////////////////////////////////////////////////////////////////////////////

class ShiftTable {
  late ShiftFrame shiftFrame;
  late List<ShiftRequest> requests;
  late List<List<double>> fitness;
  late List<List<List<Candidate>>> shiftTable;

  ShiftTable(this.shiftFrame, this.requests) {
    // init shiftTable
    shiftTable = List<List<List<Candidate>>>.generate(
      shiftFrame.assignTable.length,
      (ti) => List<List<Candidate>>.generate(
        shiftFrame.assignTable[0].length,
        (di) {
          List<Candidate> list = [];
          for (int ri = 0; ri < requests.length; ri++) {
            if (requests[ri].reqTable[ti][di] == 1) {
              list.add(
                Candidate(
                  ri,
                  (requests[ri].respTable[ti][di] == 1),
                ),
              );
            }
          }
          return list;
        },
      ),
    );

    // init Happiness
    fitness = List<List<double>>.generate(
      requests.length,
      (index) => [0, 0, 0, 0, 0, 0, 0],
    );
    calcFitness(0, 0, 0);
  }

  ////////////////////////////////////////////////////////////////////////////
  /// Response Table を Shift Table から作成する
  ////////////////////////////////////////////////////////////////////////////

  void copyshiftTable2ResponseTable() {
    for (int ti = 0; ti < shiftTable.length; ti++) {
      for (int di = 0; di < shiftTable[ti].length; di++) {
        for (int ri = 0; ri < shiftTable[ti][di].length; ri++) {
          var temp = shiftTable[ti][di][ri];
          requests[temp.userIndex].respTable[ti][di] = temp.assign ? 1 : 0;
        }
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  /// その時間区分に何人割り当てられているか確認する関数
  ////////////////////////////////////////////////////////////////////////////

  bool getAssignedFin(int ti, int di) {
    int count = 0;
    for (int i = 0; i < shiftTable[ti][di].length; i++) {
      if (shiftTable[ti][di][i].assign) {
        count++;
      }
    }
    // 目標人数に達していない && 全員を割り当て終わっていない
    return !(count < shiftFrame.assignTable[ti][di] &&
        count != shiftTable[ti][di].length);
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

  calcFitness(int baseTime, int minTime, int baseConDay) {
    // date range
    int date = shiftFrame.dateTerm[0].end
            .difference(shiftFrame.dateTerm[0].start)
            .inDays +
        1;
    int time = shiftFrame.timeDivs.length;
    List<int> duration = List.generate(
        time,
        (index) => shiftFrame.timeDivs[index].endTime
            .difference(shiftFrame.timeDivs[index].startTime)
            .inMinutes);

    // init Happiness
    for (var ri = 0; ri < requests.length; ri++) {
      var request = requests[ri];

      double requestTotal = 0;
      double responseTotal = 0;
      bool assignDateFlag = false; // その日 assign されたかを示すフラグ
      int assignDateCnt = 0; // assign された日をカウントするフラグ
      int dailyTotal = 0; // １日の勤務時間
      int baseTimeOver = 0; // １日の勤務時間の基本勤務時間を超過した時間の累積値
      int minTimeUnder = 0; // １日の勤務時間が最短勤務時間に満たない時間の累積
      int conDayCnt = 0; // 連続勤務回数
      int baseConDayOver = 0; // 連続勤務回数

      for (var di = 0; di < shiftFrame.getDateLen(); di++) {
        dailyTotal = 0;
        for (var ti = 0; ti < shiftFrame.getTimeDivsLen(); ti++) {
          if (shiftFrame.assignTable[ti][di] != 0) {
            if (request.reqTable[ti][di] == 1) {
              requestTotal += duration[ti];
              if (request.respTable[ti][di] == 1) {
                dailyTotal += duration[ti];
                // その日1日でも割り当てられたら， True
                assignDateFlag = true;
              }
            }
          }
        }
        if (assignDateFlag) {
          conDayCnt++;
          assignDateCnt++;
          responseTotal += dailyTotal;
          if (baseTime != 0 && baseTime < dailyTotal) {
            baseTimeOver += dailyTotal - baseTime;
          }
          if (minTime != 0 && minTime > dailyTotal) {
            minTimeUnder += minTime - dailyTotal;
          }
          dailyTotal = 0;
        } else {
          if (baseConDay != 0 && baseConDay < conDayCnt) {
            baseConDayOver += conDayCnt - baseConDay;
          }
          conDayCnt = 0;
        }
        assignDateFlag = false;
      }
      if (conDayCnt != 0) {
        baseConDayOver += conDayCnt - baseConDay;
        conDayCnt = 0;
      }

      fitness[ri][0] = requestTotal;
      fitness[ri][1] = responseTotal;
      fitness[ri][2] =
          (requestTotal != 0.0) ? responseTotal / requestTotal : 0.0;
      fitness[ri][3] = assignDateCnt.toDouble();
      fitness[ri][4] = baseTimeOver.toDouble();
      fitness[ri][5] = minTimeUnder.toDouble();
      fitness[ri][6] = baseConDayOver.toDouble();
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  /// 自動でシフト表を入力する関数
  ////////////////////////////////////////////////////////////////////////////
  autoFill(int baseTime, int minTime, int baseConDay) {
    int minMinutes = baseTime;

    final int timeDivsLen = shiftFrame.getTimeDivsLen();
    final int dateLen = shiftFrame.getDateLen();

    // 全ての希望を初期化
    for (var ti = 0; ti < timeDivsLen; ti++) {
      for (var di = 0; di < dateLen; di++) {
        for (int ci = 0; ci < shiftTable[ti][di].length; ci++) {
          shiftTable[ti][di][ci].assign = false;
          requests[shiftTable[ti][di][ci].userIndex].respTable[ti][di] = 0;
        }
      }
    }

    // 各時間区分前後の連続勤務可能時間 table[requesterIndex][DateIndex][timeIndex]
    var table = List<List<List<Piece>>>.generate(
      requests.length,
      (ri) => List<List<Piece>>.generate(
        dateLen,
        (dateIndex) {
          // backward を作成
          List<Piece> list = [];
          Duration count = const Duration(hours: 0);
          for (int ti = 0; ti < timeDivsLen; ti++) {
            if (requests[ri].reqTable[ti][dateIndex] == 1) {
              count += shiftFrame.timeDivs[ti].endTime
                  .difference(shiftFrame.timeDivs[ti].startTime);
            } else {
              count = const Duration(hours: 0);
            }
            list.add(Piece(count, const Duration(hours: 0)));
          }
          // forward を作成
          int currIndex = 0;
          List<Duration> buf = [];
          for (int ti = 0; ti < timeDivsLen; ti++) {
            if (list[ti].backward.inSeconds == 0) {
              if (buf.isNotEmpty) {
                for (Duration value in buf.reversed) {
                  list[currIndex].forward = value;
                  currIndex++;
                }
                currIndex++;
                buf = [];
              } else {
                currIndex++;
              }
            } else {
              buf.add(list[ti].backward);
            }
          }
          if (buf.isNotEmpty) {
            for (Duration value in buf.reversed) {
              list[currIndex].forward = value;
              currIndex++;
            }
          }
          return list;
        },
      ),
    );

    // 最初は必ず割り当てる必要がある人を割り当てる
    for (var ti = 0; ti < timeDivsLen; ti++) {
      for (var di = 0; di < dateLen; di++) {
        // 制限人数の限界まで割り当てる
        if (shiftTable[ti][di].length <= shiftFrame.assignTable[ti][di]) {
          for (int ci = 0; ci < shiftTable[ti][di].length; ci++) {
            shiftTable[ti][di][ci].assign = true;
            requests[shiftTable[ti][di][ci].userIndex].respTable[ti][di] = 1;
          }
        }
      }
    }
    // １日ずつ割り当てていく
    for (int di = 0; di < dateLen; di++) {
      for (int ti = 0; ti < timeDivsLen; ti++) {
        // すでに割り当て人数に達しているか確認する
        while (!getAssignedFin(ti, di)) {
          List<SemiCandidate> semiCandidate = [];
          // 達していなければ，候補の候補者リストを作る
          for (int ci = 0; ci < shiftTable[ti][di].length; ci++) {
            if (!shiftTable[ti][di][ci].assign) {
              semiCandidate.add(
                SemiCandidate(
                  ci,
                  table[shiftTable[ti][di][ci].userIndex][di][ti]
                      .forward
                      .inMinutes
                      .clamp(0, minMinutes),
                ),
              );
            }
          }
          if (semiCandidate.isNotEmpty) {
            double maxScore = -10000000000000000000000.0;
            int optIndex = 0;

            for (int sci = 0; sci < semiCandidate.length; sci++) {
              // shiftRequest(Response) のバックアップ
              int ri =
                  shiftTable[ti][di][semiCandidate[sci].userIndex].userIndex;
              var shiftResponseBackup = requests[ri]
                  .respTable
                  .map((e) => List.from(e).cast<int>())
                  .toList();

              // 実際にシフトに当てはめる部分
              int changeDuration = semiCandidate[sci].minutes;
              int count = 0;
              while (changeDuration > 0) {
                requests[ri].respTable[ti + count][di] = 1;
                changeDuration -= shiftFrame.timeDivs[ti + count].endTime
                    .difference(shiftFrame.timeDivs[ti + count].startTime)
                    .inMinutes;
                count++;
              }

              double score = 0;
              for (int i = 0; i < requests.length; i++) {
                calcFitness(baseTime, minTime, baseConDay + 1);
                // 円の関数に従って勤務者の適合率を求める
                score += sqrt(1 - pow((fitness[i][2]) - 1, 2)) * 100;
                score -= fitness[i][4] * 2;
                score -= fitness[i][5] * 3;
                score -= fitness[i][6] / dateLen * 100;
              }
              if (score > maxScore) {
                maxScore = score;
                optIndex = sci;
              }
              // shiftRequest(Response) の復元
              requests[ri].respTable = shiftResponseBackup
                  .map((e) => List.from(e).cast<int>())
                  .toList();
            }

            // 決定版のシフトを入力する部分
            int changeDuration = semiCandidate[optIndex].minutes;
            var optCandidate =
                shiftTable[ti][di][semiCandidate[optIndex].userIndex];

            int count = 0;
            while (changeDuration > 0) {
              for (int ci = 0; ci < shiftTable[ti + count][di].length; ci++) {
                var candidate = shiftTable[ti + count][di][ci];
                if (requests[candidate.userIndex].displayName ==
                    requests[optCandidate.userIndex].displayName) {
                  candidate.assign = true;
                  break;
                }
              }
              requests[optCandidate.userIndex].respTable[ti + count][di] = 1;
              changeDuration -= shiftFrame.timeDivs[ti + count].endTime
                  .difference(shiftFrame.timeDivs[ti + count].startTime)
                  .inMinutes;
              count++;
            }
          }
        }
      }
    }
  }

  pushShiftTable() async {
    for (var request in requests) {
      request.updateShiftResponse();
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト希望表に希望ルールを1つ適用
  ////////////////////////////////////////////////////////////////////////////////////////////

  ShiftTable applyRuleToShift(ShiftTableRule rule) {
    int startWeekday = shiftFrame.dateTerm[0].start.weekday;

    List<int> weeks = List<int>.generate(0, (index) => index);
    List<int> days = List<int>.generate(0, (index) => index);

    int weekdayTemp = startWeekday;

    weekdayTemp = startWeekday;
    weeks.clear();
    days.clear();

    if (rule.requester != null) {
      /// fifo1にルールを適応すべき週間を入れていく
      if (rule.week == 0) {
        weeks.addAll(
          List<int>.generate(
            requests[rule.requester!].reqTable[0].length,
            (index) => index,
          ),
        );
      } else {
        weeks.addAll(
          List<int>.generate(
            7,
            (index) => (rule.week - 1) * 7 + index,
          ),
        );
      }

      // fifo1からfifo2へ特定の曜日のみを抽出する
      if (rule.weekday != 0) {
        weekdayTemp = (weeks[0] + weekdayTemp - 1) % 7 + 1;

        for (int i = 0; i < weeks.length; i++) {
          if (rule.weekday == weekdayTemp) {
            days.add(weeks[i]);
          }
          weekdayTemp++;
          if (weekdayTemp > 7) {
            weekdayTemp = weekdayTemp - 7;
          }
        }
      } else {
        days = weeks;
      }

      // 指定された時間区分に対してルールを適応していく
      if (rule.time1 == 0) {
        for (int i = 0; i < days.length; i++) {
          for (int j = 0; j < requests[rule.requester!].reqTable.length; j++) {
            if (requests[rule.requester!].reqTable[j][days[i]] == 1) {
              requests[rule.requester!].respTable[j][days[i]] = rule.response;
            }
          }
        }
      } else {
        for (int i = 0; i < days.length; i++) {
          if (rule.time2 == 0 || rule.time1 == rule.time2) {
            if (shiftFrame.assignTable[rule.time1 - 1][days[i]] != 0) {
              if (requests[rule.requester!].reqTable[rule.time1 - 1][days[i]] ==
                  1) {
                requests[rule.requester!].respTable[rule.time1 - 1][days[i]] =
                    rule.response;
              }
            }
          } else {
            for (int j = rule.time1 - 1; j < rule.time2; j++) {
              if (shiftFrame.assignTable[j][days[i]] != 0) {
                if (requests[rule.requester!].reqTable[j][days[i]] == 1) {
                  requests[rule.requester!].respTable[j][days[i]] =
                      rule.response;
                }
              }
            }
          }
        }
      }
    } else {
      for (int ri = 0; ri < requests.length; ri++) {
        /// fifo1にルールを適応すべき週間を入れていく
        if (rule.week == 0) {
          weeks.addAll(
            List<int>.generate(
              requests[ri].reqTable[0].length,
              (index) => index,
            ),
          );
        } else {
          weeks.addAll(
            List<int>.generate(
              7,
              (index) => (rule.week - 1) * 7 + index,
            ),
          );
        }

        // fifo1からfifo2へ特定の曜日のみを抽出する
        if (rule.weekday != 0) {
          weekdayTemp = (weeks[0] + weekdayTemp - 1) % 7 + 1;

          for (int i = 0; i < weeks.length; i++) {
            if (rule.weekday == weekdayTemp) {
              days.add(weeks[i]);
            }
            weekdayTemp++;
            if (weekdayTemp > 7) {
              weekdayTemp = weekdayTemp - 7;
            }
          }
        } else {
          days = weeks;
        }

        // 指定された時間区分に対してルールを適応していく
        if (rule.time1 == 0) {
          for (int i = 0; i < days.length; i++) {
            for (int j = 0; j < requests[ri].reqTable.length; j++) {
              if (requests[ri].reqTable[j][days[i]] == 1) {
                requests[ri].respTable[j][days[i]] = rule.response;
              }
            }
          }
        } else {
          for (int i = 0; i < days.length; i++) {
            if (rule.time2 == 0 || rule.time1 == rule.time2) {
              if (shiftFrame.assignTable[rule.time1 - 1][days[i]] != 0) {
                if (requests[ri].reqTable[rule.time1 - 1][days[i]] == 1) {
                  requests[ri].respTable[rule.time1 - 1][days[i]] =
                      rule.response;
                }
              }
            } else {
              for (int j = rule.time1 - 1; j < rule.time2; j++) {
                if (shiftFrame.assignTable[j][days[i]] != 0) {
                  if (requests[ri].reqTable[j][days[i]] == 1) {
                    requests[ri].respTable[j][days[i]] = rule.response;
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
        (index_2) {
          List<Candidate> list = [];
          for (int index = 0; index < requests.length; index++) {
            if (requests[index].reqTable[index_1][index_2] == 1) {
              list.add(
                Candidate(
                  index,
                  (requests[index].respTable[index_1][index_2] == 1),
                ),
              );
            }
          }
          return list;
        },
      ),
    );

    // init Happiness
    fitness = List<List<double>>.generate(
      requests.length,
      (index) => [0, 0, 0, 0, 0, 0, 0],
    );
    calcFitness(0, 0, 0);

    return this;
  }
}

class Candidate {
  final int userIndex;
  bool assign;
  Candidate(
    this.userIndex,
    this.assign,
  );

  Candidate copy() {
    return Candidate(
      userIndex,
      assign,
    );
  }
}

class SemiCandidate {
  final int userIndex;
  int minutes;
  SemiCandidate(
    this.userIndex,
    this.minutes,
  );
}

class Piece {
  Duration backward;
  Duration forward;
  Piece(
    this.backward,
    this.forward,
  );
}

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト希望一括入力のためのクラス
////////////////////////////////////////////////////////////////////////////////////////////

class ShiftTableRule {
  ShiftTableRule({
    required this.week,
    required this.weekday,
    required this.response,
    required this.time1,
    required this.time2,
    this.requester,
  });

  final int week;
  final int weekday;
  final int response;
  final int time1;
  final int time2;
  final int? requester;
}
