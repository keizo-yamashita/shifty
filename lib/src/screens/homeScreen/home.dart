////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';

// my package
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/dialog.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/screens/inputScreen/input_shift_request.dart';
import 'package:shift/src/functions/shift_table_provider.dart';
import 'package:shift/src/screens/createScreen/create_shift_table.dart';
import 'package:shift/src/screens/createScreen/add_shift_table.dart';
import 'package:shift/src/screens/manageScreen/manage_shift_table.dart';
import 'package:shift/src/screens/manageScreen/test.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// Home 画面
////////////////////////////////////////////////////////////////////////////////////////////

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);
  @override
  State<HomeWidget> createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {
  
  bool isOwner = false;

  @override
  Widget build(BuildContext context) {

    var appBarHeight    = AppBar().preferredSize.height;  
    var screenSize      = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: screenSize.height*0.12 + screenSize.height/60, right: screenSize.width/60),
        child: FloatingActionButton(
          foregroundColor: MyFont.backgroundColor,
          backgroundColor: MyFont.primaryColor,
          child: const Icon(Icons.add, size: 40),
          onPressed: () async {
            showSelectDialog(
              context, 
              "追加方法", "シフト表の作成方法を選択してください",
              ["シフト表を作成する", "シフト表を登録する"]
            ).then((value){
              if(value == 0){
                Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateShiftTableWidget()));
              }                
              if(value == 1){
                Navigator.push(context, MaterialPageRoute(builder: (c) => const AddShiftTableWidget()));
              }
            });
          }
        ),
      ),
    
      extendBody: true,
      extendBodyBehindAppBar: true,
    
      ////////////////////////////////////////////////////////////////////////////////////////////
      /// 登録しているシフト表の一覧を表示 (管理モード，従業員モードどちらも)
      /// StreamBuilder 使用
      ////////////////////////////////////////////////////////////////////////////////////////////
    
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.height/20 + appBarHeight),
              
              // 切り替えスイッチ (従業員としてのシフト表 or 管理者としてのシフト表 の表示)
              SizedBox(
                width: screenSize.width  * 0.8,
                child: ListTile(
                  title: Text((!isOwner) ? "登録したシフト表一覧" : "作成したシフト表一覧", style: MyFont.headlineStyleGreen20),
                  leading: CupertinoSwitch(
                    value: isOwner,
                    onChanged: (result){
                      setState(() {
                        isOwner = result;    
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: screenSize.height * 0.03),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                  .collection('shift-request')
                  .where('user-id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('SteremBuilder でエラーが発生しました: ${snapshot.error}');
                  }
    
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: MyFont.primaryColor);
                  }
                  return FutureBuilder<Widget>(
                    future: buildMyShift(isOwner),
                    builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(color: MyFont.primaryColor);
                      } else if (snapshot.hasError) {
                        return Text('FeatureBuilder でエラーが発生しました: ${snapshot.error}');
                      } else {
                        return snapshot.data!;
                      }
                    },
                  );
                },
              ),
              SizedBox(height: screenSize.height/10 + appBarHeight),
            ],
          ),
        ),
      )
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// 登録シフト表のアイテム化
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<Widget> buildMyShift([bool isOwner = false]) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth      auth      = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    final uid = user?.uid;

    if(!isOwner){
      /// 自分のユーザIDが含まれるシフトリクエストリストの表示
      var snapshot = await firestore.collection('shift-request').where('user-id', isEqualTo: uid).orderBy('created-at', descending: true).get();
      if(snapshot.docs.isEmpty){
        return Text("登録されているシフト表はありません", style: MyFont.defaultStyleGrey15);
      }else{
        // とってきたシフトリクエストが参照しているシフト表を取ってくる
        List<Widget> shiftCard = [];
        for(var request in snapshot.docs){
          DocumentReference  reference = request.get('table-reference');
          var table = ShiftTable();
          table.pullShiftRequest(request, await reference.get());
          shiftCard.add(
            table.buildShiftTableCard(
              table.tableName,
              (){
                table.initTable(); 
                Provider.of<InputShiftRequestProvider>(context, listen: false).shiftTable = table;
                Navigator.push(context, MaterialPageRoute(builder: (c) => const InputShiftRequestWidget()));
              },
              (){
                showConfirmDialog(context, "確認", "シフト表'${table.tableName}'を削除しますか？", "シフト表'${table.tableName}'を削除しました", (){
                  removeTableSoft(table.requestId);
                });
              }
            )
          );
        }
        return Column(
          children: [          
            for(var shift in shiftCard)
            shift
          ]
        );
      }
    }else{
      /// 自分のユーザIDが含まれるシフト表の表示
      var snapshot = await firestore.collection('shift-table').where('user-id', isEqualTo: uid).orderBy('created-at', descending: true).get();
      if(snapshot.docs.isEmpty){
        return Text("登録されているシフト表はありません", style: MyFont.defaultStyleGrey15);
      }else{
        // とってきたシフトリクエストが参照しているシフト表を取ってくる
        List<Widget> shiftCard = [];
        for(var doc in snapshot.docs){
          var table = ShiftTable();
          table.pullShiftTable(doc);
          shiftCard.add(
            table.buildShiftTableCard(
              table.tableName,
              (){
                Provider.of<InputShiftRequestProvider>(context, listen: false).shiftTable = table;
                // Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageShiftTableWidget()));
                Navigator.push(context, MaterialPageRoute(builder: (c) => const Test()));
              },
              (){
                showSelectDialog(
                  context, 
                  table.tableName,
                  "",
                  ["シフト表IDをコピーする", "シフト表をSNSで共有する", "シフト表を削除する"]
                ).then((value){
                  
                  if(value == 0){
                    Clipboard.setData(ClipboardData(text: table.tableId));
                    showAlertDialog( context, "確認", "ID:'${table.tableId}'を\nコピーしました！");
                  }
                  if(value == 1){
                    var message = "[Shifty] シフト表入力依頼です。\n";
                    message += "下記のリンクより入力してください。\n";
                    message += "　シフト期間　 : ${DateFormat('MM/dd').format(table.shiftDateRange[0].start)} - ${DateFormat('MM/dd').format(table.shiftDateRange[0].end)}\n";
                    message += "リクエスト期間 : ${DateFormat('MM/dd').format(table.shiftDateRange[1].start)} - ${DateFormat('MM/dd').format(table.shiftDateRange[1].end)}\n";
                    message += "shifty://user/?id=${table.tableId}";
                    Share.share(message);
                  }
                  if(value == 2){
                    showConfirmDialog(context, "確認",
                      "シフト表'${table.tableName}'\nを削除しますか？\n管理者が削除を行うと，\n'${table.tableName}'への登録データはすべて削除されます",
                      "シフト表'${table.tableName}'を削除しました",
                      (){
                        removeTableHard(table.tableId);
                      }
                    );
                  }
                });
              }
            )
          );
        }
        return Column(
          children: [          
            for(var shift in shiftCard)
            shift
          ]
        );
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// Firestoreからシフト表の削除(シフト表の削除)
  ////////////////////////////////////////////////////////////////////////////////////////////

  removeTableHard(String tableId) async {
    
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // シフト表を削除する
    firestore.collection('shift-table').doc(tableId).delete().then((_) {
    print("Document successfully deleted!");
    }).catchError((error) {
      print("Error removing document: $error");
    });
    
    // 削除したシフトと表を元にするシフトリクエストを削除する
    firestore.collection('shift-request').where('table-reference', isEqualTo: firestore.collection('shift-table').doc(tableId)).get().then((querySnapshot) {
      // 各ドキュメントに対して削除操作を行う
      for(var doc in querySnapshot.docs){
        doc.reference.delete().then((_) {
          print("Document successfully deleted!");
        }).catchError((error) {
          print("Error removing document: $error");
        });
        setState(() {});
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });
  }

  removeTableSoft(String id) async {
    
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // シフト表を削除する
    firestore.collection('shift-request').doc(id).delete().then((_) {
    print("Document successfully deleted!");
    }).catchError((error) {
      print("Error removing document: $error");
    });   
  }
}
