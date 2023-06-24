import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// my package
import 'package:shift/src/functions/font.dart';



////////////////////////////////////////////////////////////////////////////////////////////
///  登録の確認ダイアログ (確認機能付き)
////////////////////////////////////////////////////////////////////////////////////////////

void showConfirmDialog(BuildContext context, String title, String message1, String message2, Function onAccept){
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('$title\n', style: MyFont.headlineStyleGreen15),
        content: Text(message1, style: MyFont.headlineStyleBlack15),
        actions: <Widget>[
          // Apply Button
          CupertinoDialogAction(
            child: Text('OK', style: MyFont.headlineStyleGreen15),
            onPressed: () {
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
                          onAccept();
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