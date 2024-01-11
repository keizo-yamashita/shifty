////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// my package
import 'package:shift/main.dart';
import 'package:shift/src/components/style/style.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// 登録の確認ダイアログ (確認機能付き)
/// title : タイトルの文章
/// message1 : 確認メッセージ
/// message2 : OK選択時に表示するメッセージ
/// onAccept : OK選択時に実行する関数
////////////////////////////////////////////////////////////////////////////////////////////

Future<bool> showConfirmDialog(
  BuildContext context,
  WidgetRef ref,
  String title,
  String message1,
  String message2,
  Function onAccept, [
  bool confirm = false,
  bool error = false,
]) async {
  ref.read(settingProvider).loadPreferences();
  bool isDark = ref.read(settingProvider).enableDarkTheme;

  bool accepted = false;

  await showDialog(
    context: context,
    builder: (_) {
      return Theme(
        data: isDark ? ThemeData.dark() : ThemeData.light(),
        child: CupertinoAlertDialog(
          title: Text(
            '$title\n',
            style:
                error ? Styles.defaultStyleRed15 : Styles.defaultStyleGreen15,
          ),
          content: Text(
            message1,
            style: Styles.defaultStyle13
          ),
          actions: <Widget>[
            // Apply Button
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: Styles.defaultStyleGreen15,
              ),
              onPressed: () {
                onAccept();
                Navigator.pop(context);
                accepted = true;
                if (confirm) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Theme(
                        data: isDark ? ThemeData.dark() : ThemeData.light(),
                        child: CupertinoAlertDialog(
                          title: Text(
                            '完了\n',
                            style: Styles.defaultStyleGreen15,
                          ),
                          content: Text(
                            message2,
                            style: Styles.defaultStyle13
                          ),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text(
                                'OK',
                                style: Styles.defaultStyleGreen15,
                              ),
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
              },
            ),
            // Canncel Button
            CupertinoDialogAction(
              child: Text('Cancel', style: Styles.defaultStyleRed15),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );

  return accepted;
}

////////////////////////////////////////////////////////////////////////////////////////////
/// 確認ボタン押すだけのダイアログ (OKボタンのみ)
/// title : タイトルの文章 message : 確認メッセージ
////////////////////////////////////////////////////////////////////////////////////////////

void showAlertDialog(
  BuildContext context,
  WidgetRef ref,
  String title,
  String message,
  bool error,
) {
  ref.read(settingProvider).loadPreferences();

  bool isDark = ref.read(settingProvider).enableDarkTheme;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Theme(
        data: isDark ? ThemeData.dark() : ThemeData.light(),
        child: CupertinoAlertDialog(
          title: Text(
            '$title\n',
            style: (!error)
                ? Styles.defaultStyleGreen15
                : Styles.defaultStyleRed15,
          ),
          content: Text(
            message,
            style: Styles.defaultStyle13,
          ),
          actions: <Widget>[
            // Apply Button
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: (!error)
                    ? Styles.defaultStyleGreen15
                    : Styles.defaultStyleRed15,
              ),
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
/// 選択ダイアログ (Futureで押された値を返す)
/// title : タイトルの文章 message : 選択のためのヒント
////////////////////////////////////////////////////////////////////////////////////////////

Future<int?> showSelectDialog(
  BuildContext context,
  WidgetRef ref,
  String title,
  String message,
  List<String> options,
) async {
  int? selectedOption;

  ref.read(settingProvider).loadPreferences();
  bool isDark = ref.read(settingProvider).enableDarkTheme;

  await showDialog(
    context: context,
    barrierColor:
        isDark ? Colors.grey.withOpacity(0.1) : Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return Theme(
        data: isDark ? ThemeData.dark() : ThemeData.light(),
        child: CupertinoAlertDialog(
          title: Text(
            '$title\n',
            style: Styles.defaultStyleGreen15,
          ),
          content: Column(
            children: [
              for (int i = 0; i < options.length; i++)
                CupertinoDialogAction(
                  child: Text(
                    options[i],
                    style: isDark
                        ? Styles.defaultStyleWhite13
                        : Styles.defaultStyleBlack13,
                  ),
                  onPressed: () {
                    selectedOption = i;
                    Navigator.pop(context);
                  },
                ),
            ],
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

Future<int?> showInfoDialog(
  BuildContext context,
  WidgetRef ref,
  String title,
  Widget description,
) async {
  int? selectedOption;
  ref.read(settingProvider).loadPreferences();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, SetState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            title: Text(
              title,
              style: Styles.defaultStyleGreen20,
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.90,
              child: SingleChildScrollView(
                child: description,
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
        },
      );
    },
  );

  return selectedOption;
}
