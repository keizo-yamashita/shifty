////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:shift/src/screens/createScreen/create_shift_frame.dart';
import 'package:shift/src/screens/createScreen/add_shift_request.dart';
import 'package:shift/src/screens/manageScreen/manage_shift_table.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// Home 画面
////////////////////////////////////////////////////////////////////////////////////////////

class HomeWidget extends ConsumerStatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);
  @override
  HomeWidgetState createState() => HomeWidgetState();
}

class HomeWidgetState extends ConsumerState<HomeWidget> with SingleTickerProviderStateMixin {
  
  bool   isOwner       = false;
  double _appBarHeight = 0;     
  Size   _screenSize   = const Size(0, 0);

    // タブコントローラー
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // AppBar の高さの取得 & スクリーンサイズの取得 (AppBarはこのbuildでは作ってないので appbar の高さはいらない)
    _appBarHeight = MediaQuery.of(context).padding.top;
    _screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - _appBarHeight);

    String id = ref.read(deepLinkProvider).shiftFrameId;

    if(id != ""){
      Navigator.push(context, MaterialPageRoute(builder: (c) => AddShiftRequestWidget(tableId: id)));
      ref.read(deepLinkProvider).shiftFrameId = "";
    }
    ref.read(settingProvider).loadPreferences();

    List<Widget> tabList = const [
      Tab(text: 'フォロー中のシフト表'),
      Tab(text: '管理中のシフト表'),
    ];

    List<Widget> itemList = [
      // フォローしているシフト表
      SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('shift-follower').where('user-id', isEqualTo: FirebaseAuth.instance.currentUser?.uid).orderBy('created-at', descending: true).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: CircularProgressIndicator(color: MyStyle.defaultColor));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: MyStyle.primaryColor));
            }
            return FutureBuilder<Widget>(
              future: buildMyShiftRequest(snapshot.data!.docs, ref.read(settingProvider).enableDarkTheme ),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: MyStyle.primaryColor));
                } else if (snapshot.hasError) {
                  return const Center(child: CircularProgressIndicator(color: MyStyle.defaultColor));
                } else {
                  return snapshot.data!;
                }
              },
            );
          },
        ),
      ),
      // 管理中のシフト表
      SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('shift-leader').where('user-id', isEqualTo: FirebaseAuth.instance.currentUser?.uid).orderBy('created-at', descending: true).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: CircularProgressIndicator(color: MyStyle.defaultColor));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: MyStyle.primaryColor));
            }
            return FutureBuilder<Widget>(
              future: buildMyShiftFrame(snapshot.data!.docs, ref.read(settingProvider).enableDarkTheme),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: MyStyle.primaryColor));
                } else if (snapshot.hasError) {
                  return const Center(child: CircularProgressIndicator(color: MyStyle.defaultColor));
                } else {
                  return snapshot.data!;
                }
              },
            );
          },
        ),
      )
    ];

    if((ref.read(settingProvider).defaultShiftView)){
      tabList = tabList.reversed.toList();
      itemList = itemList.reversed.toList();
    }

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
              "追加方法", "シフト表の作成方法を選択してください。",
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
    
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: _appBarHeight),
          SizedBox(
            height: 60,
            child: TabBar(
              controller: _tabController,
              indicatorColor: MyStyle.primaryColor,
              labelStyle: MyStyle.headlineStyle15,
              labelColor: MyStyle.primaryColor,  
              unselectedLabelColor: Colors.grey, 
              tabs: tabList,
              onTap: (int index){
                if(index == 0){
                }else{
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SizedBox(
              height: _screenSize.height * 1 - 92,
              child: TabBarView(
                controller: _tabController,
                children: itemList,
              ),
            ),
          ),
        ],
      )
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// 登録シフト表のアイテム化
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<Widget> buildMyShiftRequest(List<QueryDocumentSnapshot<Object?>> docs, bool isDark) async {

    if(docs.isEmpty){
      return Text("フォロー中のシフト表はありません。", style: MyStyle.defaultStyleGrey15);
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
              showConfirmDialog(context, ref, "確認", "シフト表'${frame.shiftName}'のフォローを解除しますか？", "シフト表'${frame.shiftName}'のフォローを解除しました。", (){
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
      return Text("管理中のシフト表はありません。", style: MyStyle.defaultStyleGrey15, textAlign: TextAlign.center);
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
              var message = "[Shifty] シフト表の共有\n\n";
              message += "シフト名　　　 : ${frame.shiftName} \n";
              message += "リクエスト期間 : ${DateFormat('MM/dd').format(frame.shiftDateRange[1].start)} - ${DateFormat('MM/dd').format(frame.shiftDateRange[1].end)}\n";
              message += "シフト期間　　 : ${DateFormat('MM/dd').format(frame.shiftDateRange[0].start)} - ${DateFormat('MM/dd').format(frame.shiftDateRange[0].end)}\n\n";
              message += "下記のリンクよりシフトリクエストを入力して下さい。\n";
              message += "shifty://user/?id=${frame.shiftId}";
              message += "\n\n";
              message += "インストールがまだの方は ↓ から \n\n";
              message += "iOS : https://apps.apple.com/jp/app/shifty-%E3%82%B7%E3%83%95%E3%83%88%E8%A1%A8%E4%BD%9C%E6%88%90%E3%82%A2%E3%83%97%E3%83%AA/id6458593130 \n\n";
              message += "android : https://play.google.com/store/apps/details?id=com.kakupan.shift&pcampaignid=web_share \n";
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
                    "シフト表'${frame.shiftName}'\nを削除しますか？\n管理者が削除を行うと、\n'${frame.shiftName}'への登録データはすべて削除されます。",
                    "シフト表'${frame.shiftName}'を削除しました。",
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
    firestore.collection('shift-follower').where('reference', isEqualTo: firestore.collection('shift-leader').doc(tableId)).get().then(
      (querySnapshot) {
        // 各ドキュメントに対して削除操作を行う
        for(var doc in querySnapshot.docs){
          doc.reference.delete().then((_) {
            print("Document successfully deleted!");
          }).catchError((error) {
            print("Error removing document: $error");
          });
          setState(() {});
        }
      }
    ).catchError(
      (error) {
        print("Error getting documents: $error");
      }
    );
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
