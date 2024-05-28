////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shift/main.dart';
import 'package:shift/components/form/utility/button.dart';
import 'package:shift/components/style/style.dart';
import 'package:shift/components/form/utility/dialog.dart';
import 'package:shift/models/shift/shift_frame.dart';
import 'package:shift/models/shift_request.dart';

class FollowShiftFramePage extends ConsumerStatefulWidget {
  const FollowShiftFramePage({Key? key, this.tableId}) : super(key: key);

  final String? tableId;

  @override
  FollowShiftFramePageState createState() => FollowShiftFramePageState();
}

class FollowShiftFramePageState extends ConsumerState<FollowShiftFramePage> {
  // set input text and cursor positon
  late TextEditingController textTableIdConroller;
  late TextEditingController textDisplayNameConroller;

  Size screenSize = const Size(0, 0);

  @override
  void initState() {
    super.initState();
    textTableIdConroller = TextEditingController(
      text: (widget.tableId != null) ? widget.tableId : "",
    );
    textDisplayNameConroller = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    screenSize = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height -
          AppBar().preferredSize.height -
          MediaQuery.of(context).padding.top,
    );
    
    Color bgColor = Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        //AppBar
        appBar: AppBar(
          centerTitle: true,
          title: Text("シフト表のフォロー", style: Styles.defaultStyleGreen20),
          bottomOpacity: 2.0,
          elevation: 2.0,
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.height * 0.04),
                if (ref.read(signInProvider).user == null)
                  Column(
                    children: [
                      Text(
                        "注意 : 未ログイン状態です。",
                        style: Styles.defaultStyleRed15,
                      ),
                      Text(
                        "シフト表をフォローすることはできません。",
                        style: Styles.defaultStyleRed15,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ////////////////////////////////////////////////////////////////////////////
                /// シフト名の名前の入力
                ////////////////////////////////////////////////////////////////////////////
                Align(
                  alignment: Alignment.topLeft,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      "シフト表のIDを入力して下さい。 (半角英数20文字)",
                      style: Styles.defaultStyle15,
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.04),

                TextField(
                  controller: textTableIdConroller,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9]'),
                    ),
                    LengthLimitingTextInputFormatter(20),
                  ],
                  cursorColor: Styles.primaryColor,
                  style: Styles.defaultStyleGreen15,
                  decoration: InputDecoration(
                    fillColor: bgColor,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    prefixIconColor: Styles.primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                        color: Styles.hiddenColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                        color: Styles.primaryColor,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.input),
                    hintText: 'シフト表のID (半角英数20文字)',
                    hintStyle: Styles.defaultStyle15,
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.go,
                ),
                SizedBox(height: screenSize.height * 0.02),
                Align(
                  alignment: Alignment.topLeft,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      "あなたの表示名を入力して下さい。(最大6文字)",
                      style: Styles.defaultStyle15,
                    ),
                  ),
                ),

                SizedBox(height: screenSize.height * 0.04),

                TextField(
                  controller: textDisplayNameConroller,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(6),
                  ],
                  cursorColor: Styles.primaryColor,
                  style: Styles.defaultStyleGreen15,
                  decoration: InputDecoration(
                    fillColor: bgColor,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    prefixIconColor: Styles.primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                        color: Styles.hiddenColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                        color: Styles.primaryColor,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.input),
                    hintText: '(ex) 福岡 太郎',
                    hintStyle: Styles.defaultStyleGrey15,
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.go,
                ),

                SizedBox(height: screenSize.height * 0.08),

                CustomTextButton(
                  icon: Icons.add,
                  text: "フォローする",
                  enable: true,
                  width: screenSize.width * 0.9,
                  height: 40,
                  onPressed: () async {
                    var tableId = textTableIdConroller.text;
                    var displayName = textDisplayNameConroller.text;

                    if (ref.read(signInProvider).user == null) {
                      showAlertDialog(
                        context,
                        ref,
                        "ログインエラー",
                        "未ログイン状態では\nフォローできません。\n'ホーム画面'及び'アカウント画面'から\n'ログイン画面'に移動してください。",
                        true,
                      );
                    } else {
                      // Table ID が入力されているか
                      if (tableId.isNotEmpty) {
                        // Firestoreからシフト表を取ってくる (そのIDのシフト表が存在する確認する)
                        FirebaseFirestore.instance
                            .collection('shift-leader')
                            .doc(tableId)
                            .get()
                            .then(
                          (value) {
                            if (value.exists) {
                              // リクエスト募集中かどうか確認
                              var now = DateTime.now();
                              var requestEnd =
                                  value.get('request-end').toDate();
                              var requestStart =
                                  value.get('request-start').toDate();
                              if (now.compareTo(requestStart) >= 0 &&
                                  now.compareTo(requestEnd) <= 0) {
                                // 名前が入力されているか
                                if (displayName.isNotEmpty) {
                                  // そのシフト表に登録されている希望表を全て抽出し，名前が重複しないことを確認
                                  FirebaseFirestore.instance
                                      .collection('shift-follower')
                                      .where(
                                        'reference',
                                        isEqualTo: value.reference,
                                      )
                                      .get()
                                      .then(
                                    (snapshots) {
                                      var shiftFrame = ShiftFrame.fromFirebase(
                                        value,
                                      );
                                      var errorFlag = false;

                                      for (var snapshot in snapshots.docs) {
                                        if (displayName ==
                                            snapshot.get('display-name')) {
                                          showAlertDialog(
                                            context,
                                            ref,
                                            "エラー",
                                            "すでに同じ表示名が使用されているようです。\n別の表示名を入力してください。",
                                            true,
                                          );
                                          errorFlag = true;
                                          break;
                                        }
                                      }

                                      if (!errorFlag) {
                                        showConfirmDialog(
                                          context: context,
                                          ref: ref,
                                          title: "確認",
                                          message1: "'${shiftFrame.shiftName}'をフォローしますか？",
                                          message2: "'${shiftFrame.shiftName}'をフォローしました。",
                                          onAccept: () {
                                            var shiftRequest = ShiftRequest(
                                              shiftFrame,
                                            );
                                            shiftRequest
                                                .pushShiftRequestResponse(
                                              value.reference,
                                              displayName,
                                            );
                                            Navigator.pop(context);
                                          },
                                          confirm: true,
                                        );
                                      }
                                    },
                                  );
                                } else {
                                  showAlertDialog(
                                    context,
                                    ref,
                                    "エラー",
                                    "あなたの表示名を\n入力してください。",
                                    true,
                                  );
                                }
                              } else {
                                showAlertDialog(
                                  context,
                                  ref,
                                  "エラー",
                                  "このシフト表は現在リクエスト期間中ではないようです。\n管理者に確認してください。",
                                  true,
                                );
                              }
                            } else {
                              // IDがなかった時
                              showAlertDialog(
                                context,
                                ref,
                                "エラー",
                                "入力したIDのシフト表は\n見つかりませんでした。",
                                true,
                              );
                            }
                          },
                        );
                      } else {
                        // IDが入力されていない
                        showAlertDialog(
                          context,
                          ref,
                          "エラー",
                          "シフト表のIDが\n入力されていません。",
                          true,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    textTableIdConroller.dispose();
    super.dispose();
  }
}
