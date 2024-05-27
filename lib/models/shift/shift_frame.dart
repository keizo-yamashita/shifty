import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import '../time_division/time_division.dart';
import 'assign_rule.dart';
import 'date_time_range_converter.dart';
import 'package:intl/intl.dart';
import 'package:shift/components/style/style.dart';

part 'shift_frame.freezed.dart';
part 'shift_frame.g.dart';

@freezed
class ShiftFrame with _$ShiftFrame {

  const ShiftFrame._();
  const factory ShiftFrame({
    required String shiftId,
    required String shiftName,
    required DateTime updateTime,
    required List<TimeDivision> timeDivs,
    @DateTimeRangeConverter() required List<DateTimeRange> dateTerm,
    required List<List<int>> assignTable,
    required bool isTestMode,
    required String userId,
  }) = _ShiftFrame;

  factory ShiftFrame.fromJson(Map<String, dynamic> json) => _$ShiftFrameFromJson(json);

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表の作成関数
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  ShiftFrame initTable() {
    bool isTimeDivsLenMismatch = (getTimeDivsLen() != assignTable.length);
    bool isDateLenMismatch = isTimeDivsLenMismatch ? false : (getDateLen() != assignTable[0].length);

    if (isTimeDivsLenMismatch || isDateLenMismatch) {
      final newAssignTable = List<List<int>>.generate(
        timeDivs.length,
        (index) => List<int>.generate(
          getDateLen(),
          (index) => 0,
        ),
      );

      return copyWith(assignTable: newAssignTable);
    }

    return this;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表の column, row の長さを返す関数
  ////////////////////////////////////////////////////////////////////////////////////////////

  int getDateLen() {
    return dateTerm[0].end.difference(dateTerm[0].start).inDays + 1;
  }

  int getTimeDivsLen() {
    return timeDivs.length;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// リクエスト期間，シフト期間，シフト準備期間であるかを返す関数
  ////////////////////////////////////////////////////////////////////////////////////////////

  bool isInRequestTerm() {
    DateTime now = DateTime.now();

    bool isRequestStart = now.compareTo(dateTerm[1].start) >= 0;
    bool isRequestEnd = now.compareTo(dateTerm[1].end) > 0;

    return isRequestStart && !isRequestEnd;
  }

  bool isInPrepareTerm() {
    DateTime now = DateTime.now();

    bool isRequestEnd = now.compareTo(dateTerm[1].end) > 0;
    bool isShiftStart = now.compareTo(dateTerm[0].start) < 0;

    return isShiftStart && isRequestEnd;
  }

  bool isInShiftTerm() {
    DateTime now = DateTime.now();

    bool isShiftStart = now.compareTo(dateTerm[0].start) >= 0;
    bool isShiftEnd = now.compareTo(dateTerm[0].end) > 0;

    return isShiftStart && !isShiftEnd;
  }

  bool isEndShiftTerm() {
    DateTime now = DateTime.now();

    bool isShiftEnd = now.compareTo(dateTerm[0].end) > 0;

    return isShiftEnd;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表に勤務人数のルールを1つ適用
  ////////////////////////////////////////////////////////////////////////////////////////////

  ShiftFrame applyRuleToShiftFrame(AssignRule rule) {
    int startWeekday = dateTerm[0].start.weekday;
    List<int> fifo1 = List<int>.generate(0, (index) => index);
    List<int> fifo2 = List<int>.generate(0, (index) => index);

    int weekdayTemp = startWeekday;

    weekdayTemp = startWeekday;
    fifo1.clear();
    fifo2.clear();

    /// fifo1にルールを適応すべき週間を入れていく
    if (rule.week == 0) {
      fifo1.addAll(
        List<int>.generate(assignTable[0].length, (index) => index),
      );
    } else {
      fifo1.addAll(
        List<int>.generate(7, (index) => (rule.week - 1) * 7 + index),
      );
    }
    // fifo1からfifo2へ特定の曜日のみを抽出する
    if (rule.weekday != 0) {
      weekdayTemp = (fifo1[0] + weekdayTemp - 1) % 7 + 1;

      for (int i = 0; i < fifo1.length; i++) {
        if (rule.weekday == weekdayTemp) {
          fifo2.add(fifo1[i]);
        }
        weekdayTemp++;
        if (weekdayTemp > 7) {
          weekdayTemp = weekdayTemp - 7;
        }
      }
    } else {
      fifo2 = fifo1;
    }
    // 指定された時間区分に対してルールを適応していく
    if (rule.timeDivs1 == 0) {
      for (int i = 0; i < fifo2.length; i++) {
        for (int j = 0; j < assignTable.length; j++) {
          assignTable[j][fifo2[i]] = rule.assignNum;
        }
      }
    } else {
      for (int i = 0; i < fifo2.length; i++) {
        if (rule.timeDivs2 == 0 || rule.timeDivs1 == rule.timeDivs2) {
          assignTable[rule.timeDivs1 - 1][fifo2[i]] = rule.assignNum;
        } else {
          for (int j = rule.timeDivs1 - 1; j < rule.timeDivs2; j++) {
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

  bool addTimeDivision(String name, DateTime startTime, DateTime endTime) {
    for (int i = 0; i < getTimeDivsLen(); i++) {
      if (timeDivs[i].name == name) {
        return false;
      }
    }
    timeDivs.add(
      TimeDivision(name: name, startTime: startTime, endTime: endTime),
    );
    return true;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// シフト表をカード化する
  ////////////////////////////////////////////////////////////////////////////////////////////

  Widget buildShiftTableCard(
    String title,
    double width,
    int followersNum,
    Function onPressed,
    Function onPressedShare,
    bool isDark,
    Function onLongPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          SizedBox(
            width: width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: isDark ? Styles.darkColor : Styles.lightColor,
                surfaceTintColor: isDark ? Styles.darkColor : Styles.lightColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isTestMode)
                            Icon(
                              Icons.build_circle,
                              size: 20,
                              color: (isEndShiftTerm())
                                  ? Colors.grey
                                  : Styles.primaryColor,
                            ),
                          Text(
                            title,
                            style: (isEndShiftTerm())
                                ? Styles.defaultStyleGrey15
                                : Styles.defaultStyleGreen15,
                            textHeightBehavior: Styles.defaultBehavior,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "　　シフト期間 : ${DateFormat('MM/dd').format(dateTerm[0].start)} - ${DateFormat('MM/dd').format(dateTerm[0].end)}",
                      style: (isInShiftTerm())
                          ? Styles.defaultStyleGreen15
                          : Styles.defaultStyleGrey15,
                      textHeightBehavior: Styles.defaultBehavior,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "リクエスト期間 : ${DateFormat('MM/dd').format(dateTerm[1].start)} - ${DateFormat('MM/dd').format(dateTerm[1].end)}",
                      style: (isInRequestTerm())
                          ? Styles.defaultStyleGreen15
                          : Styles.defaultStyleGrey15,
                      textHeightBehavior: Styles.defaultBehavior,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "　フォロワー数 : $followersNum 人",
                      style: Styles.defaultStyleGrey15,
                      textHeightBehavior: Styles.defaultBehavior,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              onPressed: () {
                onPressed();
              },
              onLongPress: () {
                onLongPressed();
              },
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: SizedBox(
              width: width * 0.4,
              child: Text(
                DateFormat('MM/dd hh:mm').format(updateTime),
                style: Styles.defaultStyleGrey15,
                textHeightBehavior: Styles.defaultBehavior,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (!isEndShiftTerm())
            Positioned(
              right: 10,
              top: 0,
              child: IconButton(
                onPressed: () {
                  onPressedShare();
                },
                icon: const Icon(
                  Icons.ios_share,
                  size: 25,
                  color: Styles.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}