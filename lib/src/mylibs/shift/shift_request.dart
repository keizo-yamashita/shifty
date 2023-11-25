////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/shift/shift_frame.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// shift request class
////////////////////////////////////////////////////////////////////////////////////////////

class ShiftRequest {
  late ShiftFrame       shiftFrame;
  late String           requestId;
  late String           tableId;
  late String           displayName;
  late List<List<int>>  requestTable;
  late List<List<int>>  responseTable;
  late DateTime         updateTime;

  ShiftRequest(
    this.shiftFrame,
    [
      String?             requestId,
      String?             tableId,
      String?             displayName,
      List<List<int>>?    requestTable,
      List<List<int>>?    responseTable,
      DateTime?           updateTime,
    ]
  ){
    this.requestId      = requestId ?? "";
    this.tableId        = tableId ?? "";
    this.displayName    = displayName ?? "";
    this.requestTable   = requestTable ?? <List<int>>[];
    this.responseTable  = responseTable ?? <List<int>>[];
    this.updateTime     = updateTime ?? DateTime.now();
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト表の作成関数
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  ShiftRequest initRequest(){
    /// 初期化を必要とする場合，及び時間区分，シフト期間が変更された場合に初期化
    if(shiftFrame.timeDivs.length !=  requestTable.length || 
        shiftFrame.shiftDateRange[0].end.difference(shiftFrame.shiftDateRange[0].start).inDays+1 != requestId[0].length){
      
      requestTable = List<List<int>>.generate(
        shiftFrame.timeDivs.length,
        (index) => List<int>.generate(shiftFrame.shiftDateRange[0].end.difference(shiftFrame.shiftDateRange[0].start).inDays+1, (index) => 0)
      );

      responseTable = List<List<int>>.generate(
        shiftFrame.timeDivs.length,
        (index) => List<int>.generate(shiftFrame.shiftDateRange[0].end.difference(shiftFrame.shiftDateRange[0].start).inDays+1, (index) => 0)
      );
    }

    return this;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト希望表に希望ルールを1つ適用
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  ShiftRequest applyRuleToRequest(RequestRule rule){
    int startWeekday = shiftFrame.shiftDateRange[0].start.weekday;

    List<int> fifo1 = List<int>.generate(0, (index) => index);
    List<int> fifo2 = List<int>.generate(0, (index) => index);
    
    int weekdayTemp = startWeekday;

    weekdayTemp = startWeekday;
    fifo1.clear();
    fifo2.clear();
    
    /// fifo1にルールを適応すべき週間を入れていく
    if(rule.week == 0){
      fifo1.addAll(List<int>.generate(requestTable[0].length, (index) => index));
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
          if(shiftFrame.assignTable[rule.timeDivs1-1][fifo2[i]] != 0){
            requestTable[rule.timeDivs1-1][fifo2[i]] = rule.request;
          }
        }else{
          for(int j = rule.timeDivs1-1; j < rule.timeDivs2; j++){
            if(shiftFrame.assignTable[j][fifo2[i]] != 0){
              requestTable[j][fifo2[i]] = rule.request;
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

  pushShiftRequestResponse(DocumentReference<Map<String, dynamic>> reference, displayName) async{

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth      auth      = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    final uid = user?.uid;

    var snapshotRef = await reference.get();
    var assignMap   = snapshotRef.data()!['assignment'];
    
    requestTable = List<List<int>>.generate(
      shiftFrame.timeDivs.length,
      (index) => assignMap[index.toString()].cast<int>()
    );

    final data = {
      'user-id'      : uid,
      'display-name' : displayName,
      'created-at'   : FieldValue.serverTimestamp(),
      'request'      : shiftFrame.assignTable.asMap().map((index, value) => MapEntry(index.toString(), value.map((e) => 0).toList())),
      'response'     : shiftFrame.assignTable.asMap().map((index, value) => MapEntry(index.toString(), value.map((e) => 0).toList())),
      'reference'    : reference,
    };

    await firestore.collection('shift-follower').add(data);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  入力したシフトリクエストを Firebase へ登録 
  ////////////////////////////////////////////////////////////////////////////////////////////

  void updateShiftRequest() async{

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final request = {
      'created-at' : FieldValue.serverTimestamp(),
      'request'    : requestTable.asMap().map((index, value) => MapEntry(index.toString(), value.toList())),
    };

    if(requestId.isNotEmpty){
      await firestore.collection('shift-follower').doc(requestId).update(request).then((_){
        print("update shift request");
      }).catchError((error) {
        print("Failed to update shift request: $error");
      });
    }else{
      print("shift request id is empty");
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  入力したシフトレスポンスを Firebase へ登録 
  ////////////////////////////////////////////////////////////////////////////////////////////

  void updateShiftResponse() async{

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final request = {
      'response' : responseTable.asMap().map((index, value) => MapEntry(index.toString(), value.toList())),
    };

    if(requestId.isNotEmpty){
      await firestore.collection('shift-follower').doc(requestId).update(request).then((_){
      }).catchError((error) {
        print("Failed to update shift request: $error");
      });
    }else{
      print("shift request id is empty");
    }
  }
  
  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  作成したシフトリクエスト・レスポンスを Firebase から取ってくる
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  Future<ShiftRequest> pullShiftRequest(DocumentSnapshot<Object?> snapshotReq) async{
    
    requestId      = snapshotReq.id;
    displayName    = snapshotReq.get('display-name');

    var requestMap = snapshotReq.get('request');
    requestTable = List<List<int>>.generate(
      shiftFrame.timeDivs.length,
      (index) => requestMap[index.toString()].cast<int>()
    );

    var responseMap = snapshotReq.get('response');
    responseTable = List<List<int>>.generate(
      shiftFrame.timeDivs.length,
      (index) => responseMap[index.toString()].cast<int>()
    );

    updateTime = snapshotReq.get('created-at').toDate();

    return this;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  インスタンスのコピーメソッド
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  ShiftRequest copy(){
    return ShiftRequest(
      shiftFrame,
      requestId,
      tableId,
      displayName,
      requestTable,
      responseTable,
      updateTime,
    );
  }


  ////////////////////////////////////////////////////////////////////////////////////////////
  /// シフト希望表をカード化する
  ////////////////////////////////////////////////////////////////////////////////////////////  
  
  Widget buildShiftRequestCard(String title, double width, Function onPressed, bool isDark, Function onLongPressed){

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children : [
          SizedBox(
            width: width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                backgroundColor:  isDark ? Colors.grey[800] : MyStyle.backgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(title, style: MyStyle.headlineStyleGreen20, textHeightBehavior: MyStyle.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      "　シフト期間　 : ${DateFormat('MM/dd').format(shiftFrame.shiftDateRange[0].start)} - ${DateFormat('MM/dd').format(shiftFrame.shiftDateRange[0].end)}", 
                      style: (DateTime.now().compareTo(shiftFrame.shiftDateRange[0].start) >= 0 && DateTime.now().compareTo(shiftFrame.shiftDateRange[0].end) <= 0) ? MyStyle.headlineStyleGreen15 : MyStyle.defaultStyleGrey15,
                      textHeightBehavior: MyStyle.defaultBehavior, 
                      textAlign: TextAlign.center, 
                      overflow: TextOverflow.ellipsis
                    ),
                    Text("リクエスト期間 : ${DateFormat('MM/dd').format(shiftFrame.shiftDateRange[1].start)} - ${DateFormat('MM/dd').format(shiftFrame.shiftDateRange[1].end)}", 
                      style: (DateTime.now().compareTo(shiftFrame.shiftDateRange[1].start) >= 0 && DateTime.now().compareTo(shiftFrame.shiftDateRange[1].end) <= 0) ? MyStyle.headlineStyleGreen15 : MyStyle.defaultStyleGrey15,
                      textHeightBehavior: MyStyle.defaultBehavior, 
                      textAlign: TextAlign.center, 
                      overflow: TextOverflow.ellipsis
                    ),
                  ],
                ),
              ),
              onPressed: () {
                onPressed();
              },
              onLongPress: () {
                onLongPressed();
              }
            ),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: SizedBox(
              width: width * 0.4,
              child: Text(DateFormat('MM/dd hh:mm').format(updateTime), style: MyStyle.defaultStyleGrey15, textHeightBehavior: MyStyle.defaultBehavior, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)
            )
          ),
          Positioned(
            left: 10,
            top: 10,
            child: SizedBox(
              width: width * 0.4,
              child: Text("表示名 : $displayName", style: MyStyle.defaultStyleGrey15, textHeightBehavior: MyStyle.defaultBehavior, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis)
            )
          ),
        ]
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト希望一括入力のためのクラス
////////////////////////////////////////////////////////////////////////////////////////////

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
