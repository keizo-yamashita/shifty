////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// my package
import 'package:shift/src/functions/style.dart';
import 'package:shift/src/functions/setting_provider.dart';



////////////////////////////////////////////////////////////////////////////////////////////
/// 登録の確認ダイアログ (確認機能付き)
/// title : タイトルの文章 message1 : 確認メッセージ message2 : OK選択時に表示するメッセージ
/// onAccept : OK選択時に実行する関数 
////////////////////////////////////////////////////////////////////////////////////////////

void showConfirmDialog(BuildContext context, String title, String message1, String message2, Function onAccept){

  var settingProvider = Provider.of<SettingProvider>(context, listen: false);
  settingProvider.loadPreferences();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: settingProvider.enableDarkTheme ? ThemeData.dark() : ThemeData.light(),
        child: CupertinoAlertDialog(
          title: Text('$title\n', style: MyStyle.headlineStyleGreen15),
          content: Text(message1, style:   settingProvider.enableDarkTheme ? MyStyle.defaultStyleWhite13 : MyStyle.defaultStyleBlack13),
          actions: <Widget>[
            // Apply Button
            CupertinoDialogAction(
              child: Text('OK', style: MyStyle.headlineStyleGreen15),
              onPressed: () {
                onAccept();
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Theme(
                      data: settingProvider.enableDarkTheme ? ThemeData.dark() : ThemeData.light(),
                      child: CupertinoAlertDialog(
                        title: Text('完了\n', style: MyStyle.headlineStyleGreen15),
                        content: Text(message2, style: settingProvider.enableDarkTheme ? MyStyle.defaultStyleWhite13 : MyStyle.defaultStyleBlack13,),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            child: Text('OK', style: MyStyle.headlineStyleGreen15),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            // Canncel Button
            CupertinoDialogAction(
              child: Text('Cancel', style: MyStyle.defaultStyleRed15),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}

////////////////////////////////////////////////////////////////////////////////////////////
/// 確認ボタン押すだけのダイアログ (OKボタンのみ)
/// title : タイトルの文章 message : 確認メッセージ
////////////////////////////////////////////////////////////////////////////////////////////

void showAlertDialog(BuildContext context, String title, String message, bool error){
  
  var settingProvider = Provider.of<SettingProvider>(context, listen: false);
  settingProvider.loadPreferences();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: settingProvider.enableDarkTheme ? ThemeData.dark() : ThemeData.light(),
        child: CupertinoAlertDialog(
          title: Text('$title\n', style: (!error) ? MyStyle.headlineStyleGreen15 : MyStyle.defaultStyleRed15),
          content: Text(message,  style: settingProvider.enableDarkTheme ? MyStyle.defaultStyleWhite13 : MyStyle.defaultStyleBlack13),
          actions: <Widget>[
            // Apply Button
            CupertinoDialogAction(
              child: Text('OK', style: (!error) ? MyStyle.headlineStyleGreen15 : MyStyle.defaultStyleRed15),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
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

  var settingProvider = Provider.of<SettingProvider>(context, listen: false);
  settingProvider.loadPreferences();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: settingProvider.enableDarkTheme ? ThemeData.dark() : ThemeData.light(),
        child: CupertinoAlertDialog(
          title: Text('$title\n', style: MyStyle.headlineStyleGreen15),
          content: Column(
            children: [
              for(int i = 0; i < options.length; i++)
              CupertinoDialogAction(
                child: Text(options[i], style: settingProvider.enableDarkTheme ? MyStyle.defaultStyleWhite13 : MyStyle.defaultStyleBlack13),
                onPressed: () {
                  selectedOption = i;
                  Navigator.pop(context);
                }
              )
            ]
          ),
        ),
      );
    },
  );

  return selectedOption;
}

////////////////////////////////////////////////////////////////////////////////////////////
/// 選択ダイアログ (Futureで値押された値を返す)
/// title : タイトルの文章 message : 選択のためのヒント
////////////////////////////////////////////////////////////////////////////////////////////

Future<int?> showInfoDialog(BuildContext context, String title, Widget description) async {
  
  int? selectedOption;

  var settingProvider = Provider.of<SettingProvider>(context, listen: false);
  settingProvider.loadPreferences();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, SetState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            title: Text(title, style:  MyStyle.headlineStyleGreen20, textAlign: TextAlign.center),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.90,
              child: SingleChildScrollView(
                child: description
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('閉じる'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      );
    }
  );

  return selectedOption;
}