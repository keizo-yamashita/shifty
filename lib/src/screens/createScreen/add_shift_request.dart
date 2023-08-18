////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/dialog.dart';
import 'package:shift/src/mylibs/sign_in/sign_in_provider.dart';
import 'package:shift/src/mylibs/shift/shift_frame.dart';
import 'package:shift/src/mylibs/shift/shift_request.dart';


class AddShiftRequestWidget extends StatefulWidget {
  const AddShiftRequestWidget({Key? key, this.tableId}) : super(key: key);

  final String? tableId;

  @override
  State<AddShiftRequestWidget> createState() => AddShiftRequestWidgetState();
}

class AddShiftRequestWidgetState extends State<AddShiftRequestWidget> {

  // set input text and cursor positon 
  late TextEditingController textTableIdConroller; 
  late TextEditingController textDisplayNameConroller;

  Size _screenSize         = const Size(0, 0);

  @override
  void initState() {
    super.initState();
    textTableIdConroller     = TextEditingController(text: (widget.tableId != null) ? widget.tableId : ""); 
    textDisplayNameConroller = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {

    _screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top);
    
    var signInProvider = Provider.of<SignInProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        //AppBar
        appBar: AppBar(
          title: Text("シフト表のフォロー",style: MyStyle.headlineStyleGreen20),
          bottomOpacity: 2.0,
          elevation: 2.0
        ),

        extendBody: true,
        extendBodyBehindAppBar: true,
    
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: _screenSize.height * 0.04),
                if(signInProvider.user == null)
                Column(
                  children: [
                    Text("注意 : 未ログイン状態です。", style: MyStyle.defaultStyleRed15),
                    Text("シフト表をフォローすることはできません。", style: MyStyle.defaultStyleRed15),
                    const SizedBox(height: 20),
                  ],
                ),
                ////////////////////////////////////////////////////////////////////////////
                /// シフト名の名前の入力
                ////////////////////////////////////////////////////////////////////////////
          
                Text("シフト表のIDを入力して下さい (半角英数20文字)", style: MyStyle.defaultStyleGrey15),
                SizedBox(height: _screenSize.height * 0.04),
                SizedBox(
                  width: _screenSize.width * 0.9,
                  child: TextField(
                    controller: textTableIdConroller,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), // 英数のみを許可する
                      LengthLimitingTextInputFormatter(20),
                    ],
                    cursorColor: MyStyle.primaryColor,
                    style: MyStyle.headlineStyleGreen15,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
                      prefixIconColor: MyStyle.primaryColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyStyle.hiddenColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyStyle.primaryColor,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.input),
                      hintText: 'シフト表のID (半角英数20文字)',
                      hintStyle: MyStyle.defaultStyleGrey15,
                      
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.go,
                  )
                ),
                SizedBox(height: _screenSize.height * 0.04),
          
                // (textTableIdConroller.text != "") ? 
                // StreamBuilder<DocumentSnapshot>(
                //   stream: FirebaseFirestore.instance.collection('shift-table').doc(textTableIdConroller.text).snapshots(),
                //   builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                //     if (snapshot.hasError) {
                //       return Text('SteremBuilder でエラーが発生しました: ${snapshot.error}');
                //     }
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return const CircularProgressIndicator(color: MyStyle.primaryColor);
                //     }
                //     return buildExistChecker(snapshot.data);
                //   },
                // )
                // : Container(),
                
                SizedBox(height: _screenSize.height * 0.04),
          
                Text("あなたの表示名を入力して下さい (最大6文字)", style: MyStyle.defaultStyleGrey15),
                
                SizedBox(height: _screenSize.height * 0.04),
                
                SizedBox(
                  width: _screenSize.width * 0.90,
                  child: TextField(
                    controller: textDisplayNameConroller,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                    ],
                    cursorColor: MyStyle.primaryColor,
                    style: MyStyle.headlineStyleGreen15,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
                      prefixIconColor: MyStyle.primaryColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyStyle.hiddenColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyStyle.primaryColor,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.input),
                      hintText: '(ex) 福岡 太郎',
                      hintStyle: MyStyle.defaultStyleGrey15
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.go
                  )
                ),
                SizedBox(height: _screenSize.height * 0.08),
                SizedBox(
                  width: _screenSize.width * 0.90,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shadowColor: MyStyle.hiddenColor, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: MyStyle.primaryColor),
                    ),
                    onPressed: () async { 
                      var tableId     = textTableIdConroller.text;
                      var displayName = textDisplayNameConroller.text;
                      
                      if(signInProvider.user == null){
                        showAlertDialog(context, "ログインエラー", "未ログイン状態では\nフォローできません。\n'ホーム画面'及び'アカウント画面'から\n'ログイン画面'に移動してください。", true);
                      }
                      else{
                        // Table ID が入力されているか
                        if(tableId.isNotEmpty){
                          // Firestoreからシフト表を取ってくる (そのIDのシフト表が存在する確認する)
                          FirebaseFirestore.instance.collection('shift-leader').doc(tableId).get().then((value){
                            if(value.exists){
                              
                              // リクエスト募集中かどうか確認
                              var now           = DateTime.now();
                              var requestEnd   = value.get('request-end').toDate();
                              var requestStart = value.get('request-start').toDate();
                              if(now.compareTo(requestStart) >= 0 && now.compareTo(requestEnd) <= 0){

                                // 名前が入力されているか
                                if(displayName.isNotEmpty){                              
                                  // そのシフト表に登録されている希望表を全て抽出し，名前が重複しないことを確認
                                  FirebaseFirestore.instance.collection('shift-follower').where('reference', isEqualTo: value.reference).get().then((snapshots){                
                                    var shiftFrame = ShiftFrame();
                                    shiftFrame.pullShiftFrame(value);
                                    var errorFlag = false;
            
                                    for(var snapshot in snapshots.docs){
                                      if(displayName == snapshot.get('display-name')){
                                        showAlertDialog( context, "エラー", "すでに同じ表示名が使用されているようです\n別の表示名を入力してください", true);
                                        errorFlag = true;
                                        break;
                                      }
                                    }
            
                                    if(!errorFlag){
                                      
                                      showConfirmDialog(
                                        context,
                                        "確認", "'${shiftFrame.shiftName}'をフォローしますか？",
                                        "'${shiftFrame.shiftName}'をフォローしました",
                                        (){
                                          var shiftRequest = ShiftRequest(shiftFrame);
                                          shiftRequest.pushShiftRequest(value.reference, displayName);
                                          Navigator.pop(context);
                                        }
                                      );
                                      
                                    }
                                  });
                                }else{
                                  showAlertDialog( context, "エラー", "あなたの表示名を\n入力してください", true);
                                }
                              }else{
                                showAlertDialog( context, "エラー", "このシフト表は現在リクエスト期間中ではないようです\n管理者に確認してください", true);
                              }
                            }else{
                              // IDがなかった時
                              showAlertDialog( context, "エラー", "入力したIDのシフト表は\n見つかりませんでした", true);
                            }
                          });
                        }
                        else{
                          // IDが入力されていない
                          showAlertDialog( context, "エラー", "シフト表のIDが\n入力されていません。", true);
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Text("フォローする", style: MyStyle.headlineStyleGreen15),
                    )
                  ),
                )
              ]
            ),
          ),
        )
      ),
    );
  }

  @override
  void dispose() {
    textTableIdConroller.dispose();
    super.dispose();
  }

  Widget buildExistChecker(DocumentSnapshot<Object?>? doc){
    if(doc!.exists){
      return Container(
        child: Column(
          children: [
            Text("シフト表が見つかりました！", style: MyStyle.headlineStyleGreen15),
            Text("シフト表名 : ${doc.get('name')}", style: MyStyle.headlineStyleGreen15),
          ],
        ),
      );
    }
    else{
      return Column(
        children: [
          Text("このIDを持つシフト表はしないようです", style: MyStyle.defaultStyleRed15),
          Text("IDをもう一度確認してください", style: MyStyle.defaultStyleRed15),
        ],
      );
    }
  }
} 