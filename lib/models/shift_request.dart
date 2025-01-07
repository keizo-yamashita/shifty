////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:shift/components/style/style.dart';
import 'package:shift/models/shift/shift_frame.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// shift request class
////////////////////////////////////////////////////////////////////////////////////////////

class ShiftRequest {
  late ShiftFrame shiftFrame;
  late String requestId;
  late String tableId;
  late String displayName;
  late List<List<int>> reqTable;
  late List<List<int>> respTable;
  late List<List<int>> lockedTable;
  late DateTime updateTime;

  ShiftRequest(
    this.shiftFrame, [
    String? requestId,
    String? tableId,
    String? displayName,
    List<List<int>>? reqTable,
    List<List<int>>? respTable,
    List<List<int>>? lockedTable,
    DateTime? updateTime,
  ]) {
    this.requestId = requestId ?? "";
    this.tableId = tableId ?? "";
    this.displayName = displayName ?? "";
    this.reqTable = reqTable ?? <List<int>>[];
    this.respTable = respTable ?? <List<int>>[];
    this.lockedTable = lockedTable ?? <List<int>>[];
    this.updateTime = updateTime ?? DateTime.now();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表の作成関数
  ////////////////////////////////////////////////////////////////////////////////////////////

  ShiftRequest initRequest() {
    int rowsLen = shiftFrame.getTimeDivsLen();
    int columnsLen = shiftFrame.getDateLen();
    bool isTimeDivsLenMismatch = rowsLen != reqTable.length;
    bool isDateLenMismatch = columnsLen != requestId[0].length;

    if (isTimeDivsLenMismatch || isDateLenMismatch) {
      reqTable = List<List<int>>.generate(
        rowsLen,
        (index) => List<int>.generate(columnsLen, (index) => 0),
      );

      respTable = List<List<int>>.generate(
        rowsLen,
        (index) => List<int>.generate(columnsLen, (index) => 0),
      );

      lockedTable = List<List<int>>.generate(
        rowsLen,
        (index) => List<int>.generate(columnsLen, (index) => 0),
      );
    }

    return this;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト希望表に希望ルールを1つ適用
  ////////////////////////////////////////////////////////////////////////////////////////////

  ShiftRequest applyRuleToRequest(RequestRule rule) {
    int startWeekday = shiftFrame.dateTerm[0].start.weekday;

    List<int> fifo1 = List<int>.generate(0, (index) => index);
    List<int> fifo2 = List<int>.generate(0, (index) => index);

    int weekdayTemp = startWeekday;

    weekdayTemp = startWeekday;
    fifo1.clear();
    fifo2.clear();

    /// fifo1にルールを適応すべき週間を入れていく
    if (rule.week == 0) {
      fifo1.addAll(
        List<int>.generate(reqTable[0].length, (index) => index),
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
        for (int j = 0; j < reqTable.length; j++) {
          reqTable[j][fifo2[i]] = rule.request;
        }
      }
    } else {
      for (int i = 0; i < fifo2.length; i++) {
        if (rule.timeDivs2 == 0 || rule.timeDivs1 == rule.timeDivs2) {
          if (shiftFrame.assignTable[rule.timeDivs1 - 1][fifo2[i]] != 0) {
            reqTable[rule.timeDivs1 - 1][fifo2[i]] = rule.request;
          }
        } else {
          for (int j = rule.timeDivs1 - 1; j < rule.timeDivs2; j++) {
            if (shiftFrame.assignTable[j][fifo2[i]] != 0) {
              reqTable[j][fifo2[i]] = rule.request;
            }
          }
        }
      }
    }
    return this;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  作成したシフト表を Firebase へ登録　(レスポンスの初期化もここで行う)
  ////////////////////////////////////////////////////////////////////////////////////////////

  pushShiftRequestResponse(
    DocumentReference<Map<String, dynamic>> reference,
    displayName,
  ) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    final uid = user?.uid;

    final data = {
      'user-id': uid,
      'display-name': displayName,
      'created-at': FieldValue.serverTimestamp(),
      'request': shiftFrame.assignTable.asMap().map((index, value) =>
          MapEntry(index.toString(), value.map((e) => 0).toList())),
      'response': shiftFrame.assignTable.asMap().map((index, value) =>
          MapEntry(index.toString(), value.map((e) => 0).toList())),
      'locked': shiftFrame.assignTable.asMap().map((index, value) =>
          MapEntry(index.toString(), value.map((e) => 0).toList())),
      'reference': reference,
    };

    await firestore.collection('shift-follower').add(data);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  入力したシフトリクエストを Firebase へ登録
  ////////////////////////////////////////////////////////////////////////////////////////////

  void updateShiftRequest() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final request = {
      'created-at': FieldValue.serverTimestamp(),
      'request': reqTable
          .asMap()
          .map((index, value) => MapEntry(index.toString(), value.toList())),
    };

    if (requestId.isNotEmpty) {
      await firestore
          .collection('shift-follower')
          .doc(requestId)
          .update(request)
          .then((_) {
        print("update shift request");
      }).catchError((error) {
        print("Failed to update shift request: $error");
      });
    } else {
      print("shift request id is empty");
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  入力したシフトレスポンスを Firebase へ登録
  ////////////////////////////////////////////////////////////////////////////////////////////

  void updateShiftResponse() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final request = {
      'response': respTable.asMap().map(
            (index, value) => MapEntry(
              index.toString(),
              value.toList(),
            ),
          ),
      'locked': lockedTable.asMap().map(
        (index, value) => MapEntry(
          index.toString(),
          value.toList(),
        ),
      ),
    };

    if (requestId.isNotEmpty) {
      await firestore
          .collection('shift-follower')
          .doc(requestId)
          .update(request)
          .then((_) {})
          .catchError(
        (error) {
          print("Failed to update shift request: $error");
        },
      );
    } else {
      print("shift request id is empty");
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  作成したシフトリクエスト・レスポンスを Firebase から取ってくる
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<ShiftRequest> pullShiftRequest(
    DocumentSnapshot<Object?> snapshotReq,
  ) async {

    DateTime now = DateTime.now();
    Map<String, dynamic> data = snapshotReq.data() as Map<String, dynamic>? ?? {};

    requestId = snapshotReq.id;
    displayName = data['display-name'] ?? "Name-Unknown";

    var requestMap = data['request'] as Map<String, dynamic>? ?? {};
    reqTable = List<List<int>>.generate(shiftFrame.getTimeDivsLen(),
        (index) => requestMap[index.toString()].cast<int>());

    var responseMap = data['response'] as Map<String, dynamic>? ?? {};
    respTable = List<List<int>>.generate(shiftFrame.getTimeDivsLen(),
        (index) => responseMap[index.toString()].cast<int>());

    var lockedMap = data['locked'] as Map<String, dynamic>?;
    lockedTable = lockedMap != null ? List<List<int>>.generate(
        shiftFrame.getTimeDivsLen(),
        (index) => lockedMap[index.toString()].cast<int>()
      ) : List<List<int>>.generate(
        shiftFrame.getTimeDivsLen(),
        (index) => List<int>.generate(shiftFrame.getDateLen(), (index) => 0),
      );

    updateTime = (data['created-at'] as Timestamp?)?.toDate() ?? now;
    
    return this;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  インスタンスのコピーメソッド
  ////////////////////////////////////////////////////////////////////////////////////////////

  ShiftRequest copy() {
    return ShiftRequest(
      shiftFrame,
      requestId,
      tableId,
      displayName,
      reqTable,
      respTable,
      lockedTable,
      updateTime,
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// シフト希望表をカード化する
  ////////////////////////////////////////////////////////////////////////////////////////////

  Widget buildShiftRequestCard(
    String title,
    double width,
    Function onPressed,
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        children: [
                          Text(
                            "$title ($displayName)",
                            style: (shiftFrame.isEndShiftTerm())
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
                      "　　シフト期間 : ${DateFormat('MM/dd').format(shiftFrame.dateTerm[0].start)} - ${DateFormat('MM/dd').format(shiftFrame.dateTerm[0].end)}",
                      style: (shiftFrame.isInShiftTerm())
                          ? Styles.defaultStyleGreen15
                          : Styles.defaultStyleGrey15,
                      textHeightBehavior: Styles.defaultBehavior,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "リクエスト期間 : ${DateFormat('MM/dd').format(shiftFrame.dateTerm[1].start)} - ${DateFormat('MM/dd').format(shiftFrame.dateTerm[1].end)}",
                      style: (shiftFrame.isInRequestTerm())
                          ? Styles.defaultStyleGreen15
                          : Styles.defaultStyleGrey15,
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
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト希望一括入力のためのクラス
////////////////////////////////////////////////////////////////////////////////////////////

class RequestRule {
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
