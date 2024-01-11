////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shift/src/components/style/style.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// grobal variable
////////////////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////////////////
/// shift frame class
////////////////////////////////////////////////////////////////////////////////////////////

class ShiftFrame {
  late String shiftId;
  late String shiftName;
  late List<TimeDivision> timeDivs;
  late List<DateTimeRange> dateTerm;
  late List<List<int>> assignTable;
  late DateTime updateTime;
  late bool isTestMode;

  ShiftFrame([
    String? shiftId,
    String? shiftName,
    List<TimeDivision>? timeDivs,
    List<DateTimeRange>? dateTerm,
    List<List<int>>? assignTable,
    DateTime? updateTime,
    bool? isTestMode,
  ]) {
    this.shiftId = shiftId ?? "";
    this.shiftName = shiftName ?? "";
    this.timeDivs = timeDivs ?? <TimeDivision>[];
    this.dateTerm = dateTerm ??
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
        ];
    this.updateTime = updateTime ?? DateTime.now();
    this.assignTable = assignTable ?? <List<int>>[];
    this.isTestMode = isTestMode ?? false;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表の作成関数
  ////////////////////////////////////////////////////////////////////////////////////////////

  ShiftFrame initTable() {
    bool isTimeDivsLenMismatch = (getTimeDivsLen() != assignTable.length);

    bool isDateLenMismatch = isTimeDivsLenMismatch ? false : (getDateLen() != assignTable[0].length);

    if (isTimeDivsLenMismatch || isDateLenMismatch) {
      assignTable = List<List<int>>.generate(
        timeDivs.length,
        (index) => List<int>.generate(
          getDateLen(),
          (index) => 0,
        ),
      );
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
  ///  作成したシフト表を Firebase へ登録
  ////////////////////////////////////////////////////////////////////////////////////////////

  pushShiftFrame() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    final uid = user?.uid;

    final table = {
      'user-id': uid,
      'name': shiftName,
      'created-at': FieldValue.serverTimestamp(),
      'request-start': dateTerm[1].start,
      'request-end': dateTerm[1].end,
      'work-start': dateTerm[0].start,
      'work-end': dateTerm[0].end,
      'time-division': FieldValue.arrayUnion(List.generate(
          timeDivs.length,
          (index) => {
                'name': timeDivs[index].name,
                'start-time': timeDivs[index].startTime,
                'end-time': timeDivs[index].endTime
              })),
      'assignment': assignTable
          .asMap()
          .map((index, value) => MapEntry(index.toString(), value))
    };
    await firestore.collection('shift-leader').add(table);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  作成したシフト表を Firebase から取ってくる
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<ShiftFrame> pullShiftFrame(DocumentSnapshot<Object?> snapshot) async {
    DateTime now = DateTime.now();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>? ?? {};

    shiftId = snapshot.id;
    shiftName = data['name'] ?? 'Default Name';
    updateTime = (data['created-at'] as Timestamp?)?.toDate() ?? now;

    var timeDivsMap = data['time-division'] as List<dynamic>? ?? [];

    dateTerm = [
      DateTimeRange(
        start: (data['work-start'] as Timestamp?)?.toDate() ?? now,
        end: (data['work-end'] as Timestamp?)?.toDate() ?? now,
      ),
      DateTimeRange(
        start: (data['request-start'] as Timestamp?)?.toDate() ?? now,
        end: (data['request-end'] as Timestamp?)?.toDate() ?? now,
      ),
    ];

    timeDivs = timeDivsMap.map((item) {
      return TimeDivision(
        name: item['name'] ?? 'Default TimeDivision Name',
        startTime: (item['start-time'] as Timestamp?)?.toDate() ?? now,
        endTime: (item['end-time'] as Timestamp?)?.toDate() ?? now,
      );
    }).toList();

    var assignMap = data['assignment'] as Map<String, dynamic>? ?? {};

    assignTable = List.generate(
      timeDivs.length,
      (index) {
        var assignList = assignMap[index.toString()] as List<dynamic>? ?? [];
        return assignList.map((e) => e as int).toList();
      },
    );

    isTestMode = data['test-mode'] ?? false;

    return this;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  インスタンスのコピーメソッド
  ////////////////////////////////////////////////////////////////////////////////////////////

  ShiftFrame copy() {
    return ShiftFrame(
      shiftId,
      shiftName,
      timeDivs,
      dateTerm,
      assignTable,
    );
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
                backgroundColor: isDark ? Colors.grey[800] : Styles.bgColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isTestMode)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(
                                Icons.build_circle,
                                size: 20,
                                color: (isEndShiftTerm())
                                    ? Colors.grey
                                    : Styles.primaryColor,
                              ),
                            ),
                          Text(
                            title,
                            style: (isEndShiftTerm())
                                ? Styles.headlineStyleGrey15
                                : Styles.headlineStyleGreen15,
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
                          ? Styles.headlineStyleGreen15
                          : Styles.headlineStyleGrey15,
                      textHeightBehavior: Styles.defaultBehavior,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "リクエスト期間 : ${DateFormat('MM/dd').format(dateTerm[1].start)} - ${DateFormat('MM/dd').format(dateTerm[1].end)}",
                      style: (isInRequestTerm())
                          ? Styles.headlineStyleGreen15
                          : Styles.headlineStyleGrey15,
                      textHeightBehavior: Styles.defaultBehavior,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "　フォロワー数 : $followersNum 人",
                      style: Styles.headlineStyleGrey15,
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
                style: Styles.headlineStyleGrey15,
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

////////////////////////////////////////////////////////////////////////////////////////////
///  時間区分のクラス
////////////////////////////////////////////////////////////////////////////////////////////

class TimeDivision {
  TimeDivision({
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  DateTime startTime;
  DateTime endTime;
  String name;

  TimeDivision.copy(TimeDivision origin)
      : this(
          name: origin.name,
          startTime: origin.startTime,
          endTime: origin.endTime,
        );
}

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト表一括入力のためのクラス
////////////////////////////////////////////////////////////////////////////////////////////

class AssignRule {
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
