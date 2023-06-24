////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shift/src/functions/dialog.dart';

// my package
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/screens/inputScreen/input_shift_request.dart';
import 'package:shift/src/functions/shift_table_provider.dart';
import 'package:shift/src/screens/createScreen/create_shift_table.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// Home 画面
////////////////////////////////////////////////////////////////////////////////////////////

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);
  @override
  State<HomeWidget> createState() => HomeWidgetState();
}

class HomeWidgetState extends State<HomeWidget> {

  @override
  Widget build(BuildContext context) {

    var appBarHeight = AppBar().preferredSize.height;
    var screenSize   = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: appBarHeight + screenSize.height/40, right: screenSize.width/20),
        child: Builder(
          builder: (context) {
            return FloatingActionButton(
              foregroundColor: MyFont.backgroundColor,
              backgroundColor: MyFont.primaryColor,
              child: const Icon(Icons.add, size: 40),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateShiftTableWidget()));
              },
            );
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
              SizedBox(height: screenSize.height/10 + appBarHeight),
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
                    future: buildMyShift(),
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

  Future<Widget> buildMyShift() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth      auth      = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    final uid = user?.uid;

    // 自分のユーザIDが含まれるシフトリクエストをとってくる
    var snapshot = await firestore.collection('shift-request').where('user-id', isEqualTo: uid).get();

    // とってきたシフトリクエストが参照しているシフト表を取ってくる
    List<Widget> shiftCard = [];
    for(var doc in snapshot.docs){
      String                    id = doc.id;
      DocumentReference  reference = doc.get('table-refarence');
      DocumentSnapshot    refTable = await reference.get();
      shiftCard.add(buildShiftCard(id, refTable, uid));
    }

    // ウィジェットを作成する
    if(snapshot.docs.isEmpty){
      return Text("登録されているシフト表はありません", style: MyFont.defaultStyleGrey15);
    }else{
      return Column(
        children: [          
          for(var shift in shiftCard)
          shift
        ]
      );
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// Firestoreからシフト表の削除(シフト表の削除)
  ////////////////////////////////////////////////////////////////////////////////////////////  
  
  Widget buildShiftCard(String id, DocumentSnapshot reference, String? uid){
    
    var tableName = reference.get('name');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              backgroundColor: MyFont.secondaryBackgroundColor,
              foregroundColor: MyFont.secondaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(tableName, style: MyFont.headlineStyleGreen20, textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                  ),
                  Text("リクエスト期間 : ${DateFormat('yy/MM/dd').format(reference.get('request-start').toDate())} - ${DateFormat('yyyy/MM/dd').format(reference.get('request-end').toDate())}", style: MyFont.defaultStyleGrey15, textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                  Text("　シフト期間　 : ${DateFormat('yy/MM/dd').format(reference.get('work-start').toDate())} - ${DateFormat('yyyy/MM/dd').format(reference.get('work-end').toDate())}", style: MyFont.defaultStyleGrey15, textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            onPressed: () { 
              var shiftTable = ShiftTable();
              shiftTable.pullShiftTable(reference);
              shiftTable.initTable(); 
              Provider.of<InputShiftRequestProvider>(context, listen: false).shiftTable = shiftTable;
              Navigator.push(context, MaterialPageRoute(builder: (c) => const InputShiftRequestWidget()));
            },
            onLongPress: () {
              if(reference.get('user-id') == uid) {
                showConfirmDialog(context, "確認",
                  "シフト表'$tableName'\nを削除しますか？\n管理者が削除を行うと，\n'$tableName'への登録データはすべて削除されます",
                  "シフト表'$tableName'を削除しました", (){
                  removeTableHard(reference.id);
                  Navigator.pop(context);
                });
              } else {
                showConfirmDialog(context, "確認", "シフト表'$tableName'を削除しますか？", "シフト表'$tableName'を削除しました", (){
                  removeTableSoft(id);
                  removeTableHard(reference.id);
                  Navigator.pop(context);
                });
              }
            },
          ),

          // もしそのシフト表の管理者だったら右上に管理者アイコンを表示
          if(reference.get('user-id') == uid)
          const Positioned(
            right: 20,
            top: 20,
            child: Icon(Icons.admin_panel_settings, size: 30.0, color: MyFont.primaryColor),
          ),
        ],
      ),
    );
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
    firestore.collection('shift-request').where('table-refarence', isEqualTo: firestore.collection('shift-table').doc(tableId)).get().then((querySnapshot) {
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