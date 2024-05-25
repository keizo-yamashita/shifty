import 'package:flutter/material.dart';
import 'package:shift/components/form/utility/button.dart';
import 'package:shift/components/style/style.dart';
import 'package:shift/components/form/utility/dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shift/main.dart';

class ContactPage extends ConsumerStatefulWidget {
  const ContactPage({super.key});

  @override
  ConsumerState<ContactPage> createState() => ContactPageState();
}

class ContactPageState extends ConsumerState<ContactPage>
    with SingleTickerProviderStateMixin {
  Size screenSize = const Size(0, 0);

  // TextField の動作をスムーズにするための変数
  final FocusNode focusNode = FocusNode();
  final TextEditingController textConroller = TextEditingController();

  // ご提案用の変数
  String suggestion = "";

  @override
  Widget build(BuildContext context) {

    Color bgColor = Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    // 画面サイズの取得
    var screenSize = Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height -
            ref.read(settingProvider).appBarHeight -
            ref.read(settingProvider).navigationBarHeight -
            ref.read(settingProvider).screenPaddingTop -
            ref.read(settingProvider).screenPaddingBottom);

    return GestureDetector(
      onTap: () {
        focusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('お問い合わせ / ご要望', style: Styles.defaultStyle18),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "本アプリがご期待に添えず、ご不便をお掛けしている場合は、どのようなご要望でもお申し付け下さい。",
                      style: Styles.defaultStyle13,
                    ),
                    SizedBox(height: screenSize.height / 40),
                    Text(
                      "例) 〇〇な機能が欲しい。〇〇が使いづらい。",
                      style: Styles.defaultStyle13,
                    )
                  ],
                ),
              ),
              // 要望入力欄
              SizedBox(
                width: screenSize.width * 0.95,
                child: TextField(
                  controller: textConroller,
                  cursorColor: Styles.primaryColor,
                  style: Styles.defaultStyle13,
                  focusNode: focusNode,
                  maxLines: 5,
                  maxLength: 500,
                  autofocus: false,
                  decoration: InputDecoration(
                    fillColor: bgColor,
                    filled: true,
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
                    hintText: 'ご要望はこちらに入力して下さい。',
                    hintStyle: Styles.defaultStyleGrey13,
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.go,
                  onTap: () {
                    FocusScope.of(context).requestFocus(focusNode);
                  },
                  onChanged: (value) {
                    suggestion = textConroller.text;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 提出ボタン
              CustomTextButton(
                icon: Icons.send,
                text: "送信",
                enable: true,
                width: screenSize.width * 0.95,
                height: 40,
                onPressed: () {
                  setState(
                    () {
                      if (suggestion != "") {
                        postSuggestion(suggestion);
                        showAlertDialog(
                          context,
                          ref,
                          "確認",
                          "送信しました。貴重なご意見ありがとうございます。",
                          false,
                        );
                        focusNode.unfocus();
                        textConroller.clear();
                      } else {
                        showAlertDialog(
                          context,
                          ref,
                          "エラー",
                          "ご要望が入力されていません。",
                          true,
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  postSuggestion(String suggestion) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    final User? user = auth.currentUser;
    final uid = user?.uid;

    Map<String, String> data;

    if (uid != null) {
      data = {
        'user-id': uid,
        'suggestion': suggestion,
      };
      await firestore.collection('suggestion').add(data);
    }
  }
}
