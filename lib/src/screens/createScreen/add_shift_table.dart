////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// my package
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/dialog.dart';
import 'package:shift/src/functions/shift_table.dart';


class AddShiftTableWidget extends StatefulWidget {
  const AddShiftTableWidget({Key? key}) : super(key: key);
  @override
  State<AddShiftTableWidget> createState() => AddShiftTableWidgetState();
}

class AddShiftTableWidgetState extends State<AddShiftTableWidget> {

  // set input text and cursor positon 
  final TextEditingController textTableIdConroller = TextEditingController();
  final TextEditingController textDisplayNameConroller    = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var appBarHeight = AppBar().preferredSize.height;
    var screenSize   = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        //AppBar
        appBar: AppBar(
          title: Text("シフト表の登録",style: MyFont.headlineStyleGreen20),
          backgroundColor: MyFont.backgroundColor.withOpacity(0.9),
          foregroundColor: MyFont.hiddenColor,
          bottomOpacity: 2.0,
          elevation: 2.0
        ),

        extendBody: true,
        extendBodyBehindAppBar: true,
    
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.height/10 + appBarHeight),
          
                ////////////////////////////////////////////////////////////////////////////
                /// シフト名の名前の入力
                ////////////////////////////////////////////////////////////////////////////
          
                Text("登録したいシフト表のIDを入力してください", style: MyFont.defaultStyleGrey15),
                SizedBox(height: screenSize.height/40),
                SizedBox(
                  width: screenSize.width * 0.90,
                  child: TextField(
                    controller: textTableIdConroller,
                    cursorColor: MyFont.primaryColor,
                    style: MyFont.headlineStyleGreen15,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
                      prefixIconColor: MyFont.primaryColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyFont.hiddenColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyFont.primaryColor,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.input),
                      hintText: 'シフト表のID (半角英数20文字)',
                      hintStyle: MyFont.defaultStyleGrey15,
                      
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.go,
                  )
                ),
                SizedBox(height: screenSize.height/40),
                Text("あなたの表示名を入力してください", style: MyFont.defaultStyleGrey15),
                SizedBox(height: screenSize.height/40),
                SizedBox(
                  width: screenSize.width * 0.90,
                  child: TextField(
                    controller: textDisplayNameConroller,
                    cursorColor: MyFont.primaryColor,
                    style: MyFont.headlineStyleGreen15,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
                      prefixIconColor: MyFont.primaryColor,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyFont.hiddenColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: MyFont.primaryColor,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.input),
                      hintText: '(ex) 福岡 太郎',
                      hintStyle: MyFont.defaultStyleGrey15
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.go
                  )
                ),
                SizedBox(height: screenSize.height / 20),
                SizedBox(
                  width: screenSize.width * 0.90,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: MyFont.backgroundColor,
                      shadowColor: MyFont.hiddenColor, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: MyFont.primaryColor),
                    ),
                    onPressed: () async { 
                      var tableId     = textTableIdConroller.text;
                      var displayName = textDisplayNameConroller.text;

                      if(tableId.isNotEmpty){
                        // Firestoreからシフト表を取ってくる (そのIDのシフト表が存在する確認する)                     
                        FirebaseFirestore.instance.collection('shift-table').doc(tableId).get().then((value){
                          
                          // 名前が入力されているか
                          if(value.exists){
                            if(displayName.isNotEmpty){                              
                              
                              // そのシフト表に登録されている希望表を全て抽出し，名前が重複しないことを確認
                              FirebaseFirestore.instance.collection('shift-request').where('table-reference', isEqualTo: value.reference).get().then((snapshots){
                              
                              var shiftTable = ShiftTable();
                              shiftTable.pullShiftTable(value);

                                var errorFlag = false;
                                for(var snapshot in snapshots.docs){
                                  if(displayName == snapshot.get('display-name')){
                                    showAlertDialog( context, "エラー", "すでに同じ表示名が使用されているようです。別の表示名を入力してください。");
                                    errorFlag = true;
                                    break;
                                  }
                                }
                                if(!errorFlag){
                                  showConfirmDialog(
                                    context,
                                    "確認", "'${shiftTable.tableName}'を登録しますか？",
                                    "'${shiftTable.tableName}'を登録しました",
                                    (){
                                      shiftTable.pushShiftRequest(value.reference, displayName);
                                      Navigator.pop(context);
                                    }
                                  );
                                }
                              });
                            }else{
                              showAlertDialog( context, "エラー", "あなたの表示名を\n入力してください");
                            }
                          }else{
                            // IDがなかった時
                            showAlertDialog( context, "エラー", "入力したIDのシフト表は\n見つかりませんでした");
                          }
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Text("登録", style: MyFont.headlineStyleGreen15),
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
}