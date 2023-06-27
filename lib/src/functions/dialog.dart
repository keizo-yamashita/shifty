////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// my package
import 'package:shift/src/functions/font.dart';



////////////////////////////////////////////////////////////////////////////////////////////
/// 登録の確認ダイアログ (確認機能付き)
/// title : タイトルの文章 message1 : 確認メッセージ message2 : OK選択時に表示するメッセージ
/// onAccept : OK選択時に実行する関数 
////////////////////////////////////////////////////////////////////////////////////////////

void showConfirmDialog(BuildContext context, String title, String message1, String message2, Function onAccept){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(title, style: MyFont.headlineStyleGreen20),
        content: Text(message1, style: MyFont.headlineStyleBlack15),
        actions: <Widget>[
          // Apply Button
          CupertinoDialogAction(
            child: Text('OK', style: MyFont.headlineStyleGreen15),
            onPressed: () {
              onAccept();
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: Text('完了\n', style: MyFont.headlineStyleGreen20),
                    content: Text(message2, style: MyFont.headlineStyleBlack15),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('OK', style: MyFont.headlineStyleGreen15),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Canncel Button
          CupertinoDialogAction(
            child: Text('Cancel', style: MyFont.defaultStyleRed15),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

////////////////////////////////////////////////////////////////////////////////////////////
/// 確認ボタン押すだけのダイアログ (OKボタンのみ)
/// title : タイトルの文章 message : 確認メッセージ
////////////////////////////////////////////////////////////////////////////////////////////

void showAlertDialog(BuildContext context, String title, String message){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('$title\n', style: MyFont.headlineStyleGreen15),
        content: Text(message,  style: MyFont.headlineStyleBlack15),
        actions: <Widget>[
          // Apply Button
          CupertinoDialogAction(
            child: Text('OK', style: MyFont.headlineStyleGreen15),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    },
  );
}

////////////////////////////////////////////////////////////////////////////////////////////
/// 選択ダイアログ (Futureで値押された値を返す)
/// title : タイトルの文章 message : 選択のためのヒント
////////////////////////////////////////////////////////////////////////////////////////////

Future<int?> showSelectDialog(BuildContext context, String title, String message, List<String> options) async {
  
  int? selectedOption;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('$title\n', style: MyFont.headlineStyleGreen15),
        content: Column(
          children: [
            for(int i = 0; i < options.length; i++)
            CupertinoDialogAction(
              child: Text(options[i], style: MyFont.defaultStyleBlack15),
              onPressed: () {
                selectedOption = i;
                Navigator.pop(context);
              }
            )
          ]
        ),
      );
    },
  );

  return selectedOption;
}