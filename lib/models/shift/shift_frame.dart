// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:shift/components/style/style.dart';
import 'package:shift/models/shift/assign_rule.dart';
import 'package:shift/models/shift/date_time_range_converter.dart';
import 'package:shift/models/time_division/time_division.dart';

part 'shift_frame.freezed.dart';
part 'shift_frame.g.dart';

const List<String> weekSelect = [
  "すべての週",
  "第1週",
  "第2週",
  "第3週",
  "第4週",
];
const List<String> weekdaySelect = [
  "すべての曜日",
  "月曜日",
  "火曜日",
  "水曜日",
  "木曜日",
  "金曜日",
  "土曜日",
  "日曜日"
];
const List<String> assignNumSelect = [
  "0 人",
  "1 人",
  "2 人",
  "3 人",
  "4 人",
  "5 人",
  "6 人",
  "7 人",
  "8 人",
  "9 人",
  "10 人"
];
const List<String> templateShiftTermSelect = [
  "1月ごと",
  "2週間ごと",
  "1週間ごと",
];
const List<String> templateReqLimitSelect = [
  "シフト開始 7 日前まで",
  "シフト開始 6 日前まで",
  "シフト開始 5 日前まで",
  "シフト開始 4 日前まで",
  "シフト開始 3 日前まで",
  "シフト開始 2 日前まで"
];

List<List<Color>> colorTable = List<List<Color>>.generate(
  11,
  (index) => [
    Color.fromARGB(
      Styles.primaryColor.alpha,
      (200 - ((200 - Styles.primaryColor.red) * (index) ~/ 10)).toInt(),
      (200 - ((200 - Styles.primaryColor.green) * (index) ~/ 10)).toInt(),
      (200 - ((200 - Styles.primaryColor.blue) * (index) ~/ 10)).toInt(),
    ),
    Colors.grey[600]!
  ],
);

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
  ///  シフト表の初期化
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  factory ShiftFrame.fromFirebase(DocumentSnapshot doc) {
    return ShiftFrame.fromJson(doc.data()! as Map<String, dynamic>);
  }

  // Firestoreにデータを保存するメソッド
  Future<void> pushToFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    final uid = user?.uid;

    final Map<String, dynamic> data = this.toJson();
    data['user-id'] = uid;
    data['created-at'] = FieldValue.serverTimestamp();

    await firestore.collection('shift-leader').add(data);
  }

  factory ShiftFrame.withDefaults({
    String? shiftId,
    String? shiftName,
    DateTime? updateTime,
    List<TimeDivision>? timeDivs,
    List<DateTimeRange>? dateTerm,
    List<List<int>>? assignTable,
    bool? isTestMode,
    String? userId,
  }) {
    return ShiftFrame(
      shiftId: shiftId ?? "",
      shiftName: shiftName ?? "シフト表名が設定されていません",
      updateTime: updateTime ?? DateTime.now(),
      timeDivs: timeDivs ?? <TimeDivision>[],
      dateTerm: dateTerm ??
          [
            DateTimeRange(
              start: DateTime(
                DateTime.now().year,
                DateTime.now().month + 1,
                1,
              ),
              end: DateTime(
                DateTime.now().year,
                DateTime.now().month + 2,
                0,
              ),
            ),
            DateTimeRange(
              start: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              ),
              end: DateTime(
                DateTime.now().year,
                DateTime.now().month + 1,
                0,
              ),
            ),
          ],
      assignTable: assignTable ?? <List<int>>[],
      isTestMode: isTestMode ?? false,
      userId: userId ?? "",
    );
  }

  ///j/////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表の初期化
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
