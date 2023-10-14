////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// my package
import 'package:shift/main.dart';
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/dialog.dart';
import 'package:shift/src/mylibs/shift/shift_frame.dart';
import 'package:shift/src/mylibs/shift/shift_request.dart';
import 'package:shift/src/mylibs/shift/shift_table.dart';
import 'package:shift/src/screens/inputScreen/input_shift_request.dart';
import 'package:shift/src/screens/signInScreen/sign_in.dart';
import 'package:shift/src/screens/createScreen/create_shift_frame.dart';
import 'package:shift/src/screens/createScreen/add_shift_request.dart';
import 'package:shift/src/screens/manageScreen/manage_shift_table.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// Home 画面
////////////////////////////////////////////////////////////////////////////////////////////

class HomeWidget extends ConsumerStatefulWidget{
  const HomeWidget({Key? key}) : super(key: key);
  @override
  HomeWidgetState createState() => HomeWidgetState();
}

class HomeWidgetState extends ConsumerState<HomeWidget> {
  
  bool isOwner     = false;
  Size _screenSize = const Size(0, 0);

  @override
  Widget build(BuildContext context) {

    var appBarHeight = AppBar().preferredSize.height;
    _screenSize      = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - appBarHeight);

    String id = ref.read(deepLinkProvider).shiftFrameId;

    if(id != ""){
      Navigator.push(context, MaterialPageRoute(builder: (c) => AddShiftRequestWidget(tableId: id)));
      ref.read(deepLinkProvider).shiftFrameId = "";
    }
    ref.read(settingProvider).loadPreferences();    

    return Scaffold(
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _screenSize.height/60, right: _screenSize.width/60),
        child: FloatingActionButton(
          foregroundColor: MyStyle.backgroundColor,
          backgroundColor: MyStyle.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(Icons.add, size: 40),
          onPressed: () async {
            showSelectDialog(
              context, 
              ref,
              "追加方法", "シフト表の作成方法を選択してください",
              ["シフト表を作成する", "シフト表をフォローする"]
            ).then((value){
              if(value == 0){
                ref.read(shiftFrameProvider).shiftFrame = ShiftFrame();
                Navigator.push(context, MaterialPageRoute(builder: (c) => const CreateShiftTableWidget()));
              }                
              if(value == 1){
                Navigator.push(context, MaterialPageRoute(builder: (c) => const AddShiftRequestWidget()));
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
              SizedBox(height: _screenSize.height/20 + appBarHeight),
              SizedBox(height: _screenSize.height/40),
              
              // 切り替えスイッチ (従業員としてのシフト表 or 管理者としてのシフト表 の表示)
              SizedBox(
                width: _screenSize.width  * 0.8,
                child: ListTile(
                  title: Text((isOwner == ref.read(settingProvider).defaultShiftView) ? "フォロー中のシフト表" : "管理中のシフト表", style: MyStyle.headlineStyleGreen18),
                  leading: CupertinoSwitch(
                    thumbColor: MyStyle.primaryColor,
                    activeColor : MyStyle.primaryColor.withAlpha(100),
                    value: isOwner,
                    onChanged: (result){
                      setState(() {
                        isOwner = result;    
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: _screenSize.height * 0.03),

              (ref.read(signInProvider).user != null && isOwner != ref.read(settingProvider).defaultShiftView) ? StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('shift-leader').where('user-id', isEqualTo: FirebaseAuth.instance.currentUser?.uid).orderBy('created-at', descending: true).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('SteremBuilder でエラーが発生しました: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: MyStyle.primaryColor);
                  }
                  return FutureBuilder<Widget>(
                    future: buildMyShiftFrame(snapshot.data!.docs, ref.read(settingProvider).enableDarkTheme),
                    builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(color: MyStyle.primaryColor);
                      } else if (snapshot.hasError) {
                        return Text('FeatureBuilder でエラーが発生しました: ${snapshot.error}');
                      } else {
                        return snapshot.data!;
                      }
                    },
                  );
                },
              )
              : (ref.read(signInProvider).user != null)
              ? StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('shift-follower').where('user-id', isEqualTo: FirebaseAuth.instance.currentUser?.uid).orderBy('created-at', descending: true).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('SteremBuilder でエラーが発生しました: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: MyStyle.primaryColor);
                  }
                  return FutureBuilder<Widget>(
                    future: buildMyShiftRequest(snapshot.data!.docs, ref.read(settingProvider).enableDarkTheme ),
                    builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(color: MyStyle.primaryColor);
                      } else if (snapshot.hasError) {
                        return Text('FeatureBuilder でエラーが発生しました: ${snapshot.error}');
                      } else {
                        return snapshot.data!;
                      }
                    },
                  );
                },
              )
              : Column(
                children: [
                  Text("シフト表を表示するには", style: MyStyle.defaultStyleGrey15),
                  Text("ログインする必要があります。", style: MyStyle.defaultStyleGrey15),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    child: OutlinedButton(
                      child: Text('ログイン画面へ', style: MyStyle.headlineStyleGreen15),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const SignInScreen()));
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: _screenSize.height/10 + appBarHeight),
            ],
          ),
        ),
      )
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// 登録シフト表のアイテム化
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<Widget> buildMyShiftRequest(List<QueryDocumentSnapshot<Object?>> docs, bool isDark) async {

    if(docs.isEmpty){
      return Text("フォロー中のシフト表はありません", style: MyStyle.defaultStyleGrey15);
    }else{
      // とってきたシフトリクエストが参照しているシフト表を取ってくる
      List<Widget> shiftCard = [];
      for(var snapshotReq in docs){
        // 参照している Shift Frame を取ってくる
        DocumentReference  refShiftFrame      = snapshotReq.get('reference');
        var                snapshotShiftFrame = await refShiftFrame.get();
        // Shift Frame のインスタンス化
        var frame = await ShiftFrame().pullShiftFrame(snapshotShiftFrame);
        
        // Shift Request のインスタンス化
        var request  = await ShiftRequest(frame).pullShiftRequest(snapshotReq);

        shiftCard.add(
          request.buildShiftRequestCard(
            frame.shiftName,
            _screenSize.width * 0.8,
            (){
              ref.read(shiftRequestProvider).shiftRequest = request;
              Navigator.push(context, MaterialPageRoute(builder: (c) => const InputShiftRequestWidget()));
            },
            isDark,
            (){
              showConfirmDialog(context, ref, "確認", "シフト表'${frame.shiftName}'のフォローを解除しますか？", "シフト表'${frame.shiftName}'のフォローを解除しました", (){
                removeTableSoft(request.requestId);
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

  Future<Widget> buildMyShiftFrame(List<QueryDocumentSnapshot<Object?>> docs, bool isDark) async {

    /// 自分のユーザIDが含まれるシフト表の表示
    if(docs.isEmpty){
      return Text("管理中のシフト表はありません", style: MyStyle.defaultStyleGrey15);
    }else{
      // とってきたシフトリクエストが参照しているシフト表を取ってくる
      List<Widget> shiftCard = [];
      for(var snapshotMyShiftFrame in docs){
        var frame = await ShiftFrame().pullShiftFrame(snapshotMyShiftFrame);
        var followersNum = 0;
        await FirebaseFirestore.instance.collection('shift-follower').where('reference', isEqualTo: snapshotMyShiftFrame.reference).orderBy('created-at', descending: false).get().then(
          (snapshotReqs) async {
            followersNum = snapshotReqs.docs.length;
          }
        );
        shiftCard.add(
          frame.buildShiftTableCard(
            frame.shiftName,
            _screenSize.width * 0.8,
            followersNum,
            () async{
              List<ShiftRequest> requests = [];
              FirebaseFirestore.instance.collection('shift-follower').where('reference', isEqualTo: snapshotMyShiftFrame.reference).orderBy('created-at', descending: false).get().then(
                (snapshotReqs) async {
                  for(var snapshotReq in snapshotReqs.docs){
                    var request = await ShiftRequest(frame).pullShiftRequest(snapshotReq);
                    requests.add(request.copy());
                  }
                  if(context.mounted){
                    ref.read(shiftTableProvider).shiftTable = ShiftTable(frame, requests);
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageShiftTableWidget()));
                  }
                }
              );
            },
            (){
              var message = "[Shifty] シフト表入力依頼です。\n";
              message += "下記のリンクより入力してください。\n";
              message += "シフト名      : ${frame.shiftName} \n";
              message += "　シフト期間　 : ${DateFormat('MM/dd').format(frame.shiftDateRange[0].start)} - ${DateFormat('MM/dd').format(frame.shiftDateRange[0].end)}\n";
              message += "リクエスト期間 : ${DateFormat('MM/dd').format(frame.shiftDateRange[1].start)} - ${DateFormat('MM/dd').format(frame.shiftDateRange[1].end)}\n";
              message += "shifty://user/?id=${frame.shiftId}";
              Share.share(message);
            },
            isDark,
            (){
              showSelectDialog(
                context,
                ref,
                frame.shiftName,
                "",
                ["シフト表IDをコピーする", "シフト表をSNSで共有する", "シフト表を削除する"]
              ).then((value){
                
                if(value == 0){
                  Clipboard.setData(ClipboardData(text: frame.shiftId));
                  showAlertDialog( context, ref, "確認", "ID:'${frame.shiftId}'を\nコピーしました！", false);
                }
                if(value == 1){
                  var message = "[Shifty] シフト表入力依頼です。\n";
                  message += "下記のリンクより入力してください。\n";
                  message += "シフト名      : ${frame.shiftName} \n";
                  message += "　シフト期間　 : ${DateFormat('MM/dd').format(frame.shiftDateRange[0].start)} - ${DateFormat('MM/dd').format(frame.shiftDateRange[0].end)}\n";
                  message += "リクエスト期間 : ${DateFormat('MM/dd').format(frame.shiftDateRange[1].start)} - ${DateFormat('MM/dd').format(frame.shiftDateRange[1].end)}\n";
                  message += "shifty://user/?id=${frame.shiftId}";
                  Share.share(message);
                }
                if(value == 2){
                  showConfirmDialog(context, ref, "確認",
                    "シフト表'${frame.shiftName}'\nを削除しますか？\n管理者が削除を行うと，\n'${frame.shiftName}'への登録データはすべて削除されます",
                    "シフト表'${frame.shiftName}'を削除しました",
                    (){
                      removeTableHard(frame.shiftId);
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

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// Firestoreからシフト表の削除(シフト表の削除)
  ////////////////////////////////////////////////////////////////////////////////////////////

  removeTableHard(String tableId) async {
    
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // シフト表を削除する
    firestore.collection('shift-leader').doc(tableId).delete().then((_) {
    print("Document successfully deleted!");
    }).catchError((error) {
      print("Error removing document: $error");
    });
    
    // 削除したシフトと表を元にするシフトリクエストを削除する
    firestore.collection('shift-follower').where('reference', isEqualTo: firestore.collection('shift-leader').doc(tableId)).get().then((querySnapshot) {
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
    firestore.collection('shift-follower').doc(id).delete().then((_) {
    print("Document successfully deleted!");
    }).catchError((error) {
      print("Error removing document: $error");
    });   
  }
}
