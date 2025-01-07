////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

// Project imports:
import 'package:shift/components/form/create_screen/input_date_term.dart';
import 'package:shift/components/form/create_screen/input_shift_name.dart';
import 'package:shift/components/form/create_screen/input_time_division.dart';
import 'package:shift/components/form/utility/dialog.dart';
import 'package:shift/components/style/style.dart';
import 'package:shift/main.dart';
import 'package:shift/models/shift/shift_frame.dart';
import 'package:shift/models/time_division/time_division.dart';
import 'package:shift/screens/shiftScreen/register_shift_frame.dart';

// my package

class CreateShiftFramePage extends ConsumerStatefulWidget {
  const CreateShiftFramePage({Key? key}) : super(key: key);
  @override
  CreateShiftFramePageState createState() => CreateShiftFramePageState();
}

class CreateShiftFramePageState extends ConsumerState<CreateShiftFramePage>
    with SingleTickerProviderStateMixin {
  // シフト準備期間が確保されているか確認するためのbool値
  bool existPrepareTerm = false;

  ShiftFrame shiftFrame = ShiftFrame.withDefaults();
  double appBarHeight = 0;
  bool isDark = false;
  Size screenSize = const Size(0, 0);

  // TextField の動作をスムーズにするための変数
  final FocusNode focusNode = FocusNode();
  final TextEditingController textConroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ja_JP', null).then((_) => setState(() {}));
    ref.read(settingProvider).isEditting = false;
    shiftFrame = ref.read(shiftFrameProvider).shiftFrame;
  }

  @override
  Widget build(BuildContext context) {
    // 画面サイズの取得
    appBarHeight = ref.read(settingProvider).appBarHeight +
        ref.read(settingProvider).screenPaddingTop;
    screenSize = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height -
          ref.watch(settingProvider).appBarHeight -
          ref.watch(settingProvider).navigationBarHeight -
          ref.watch(settingProvider).screenPaddingTop -
          ref.watch(settingProvider).screenPaddingBottom,
    );

    isDark = ref.watch(settingProvider).enableDarkTheme;
    
    ref.read(settingProvider).isEditting = !(textConroller.text == '' && shiftFrame.timeDivs.isEmpty);

    // シフト表名の更新
    textConroller.text = shiftFrame.shiftName;

    return GestureDetector(
      onTap: () {
        focusNode.unfocus();
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          final NavigatorState navigator = Navigator.of(context);
          if (!ref.watch(settingProvider).isEditting) {
            navigator.pop();
          } else {
            final bool shouldPop = await showConfirmDialog(
              context: context,
              ref: ref,
              title: "注意",
              message1: "データが保存されていません。\n未登録のデータは破棄されます。",
              message2: "",
              onAccept: () {},
              confirm: false,
              error: true,
            );
            if (shouldPop) {
              navigator.pop();
            }
          }
        },
        child: Scaffold(
          //AppBar
          appBar: AppBar(
            centerTitle: true,
            title: Text("シフト表の作成", style: Styles.defaultStyleGreen20),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    size: 30,
                    color: Styles.primaryColor,
                  ),
                  tooltip: "使い方",
                  onPressed: () async {
                    showInfoDialog(isDark);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Styles.primaryColor,
                ),
                onPressed: () {
                  if (shiftFrame.timeDivs.isEmpty) {
                    showAlertDialog(
                      context,
                      ref,
                      "入力エラー",
                      "1つ以上の時間区分を入力して下さい。",
                      true,
                    );
                  } else if (shiftFrame.shiftName == '') {
                    showAlertDialog(
                      context,
                      ref,
                      "入力エラー",
                      "シフト表の名前を指定して下さい。",
                      true,
                    );
                  } else if (!existPrepareTerm) {
                    showAlertDialog(
                      context,
                      ref,
                      "入力エラー",
                      "リクエストに対するシフト作成期間が必要なため、\n「リクエスト期間」「シフト期間」には1日以上の間隔を空けて下さい。",
                      true,
                    );
                  } else {
                    shiftFrame.initTable();
                    ref.read(shiftFrameProvider).shiftFrame = shiftFrame.copyWith();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const CheckShiftTableWidget(),
                      ),
                    );
                  }
                },
              )
            ],
          ),
          extendBody: true,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: screenSize.height * 0.04 + appBarHeight),
                  InputShiftName(
                    textController: textConroller,
                    focusNode: focusNode,
                    onTextChanged: (String inputValue) {
                      shiftFrame = shiftFrame.copyWith(
                        shiftName: inputValue,
                      );
                    },
                  ),
                  SizedBox(height: screenSize.height * 0.1),
                  InputDateTerm(
                    onDateTermChanged: (DateTimeRange shiftTerm,
                        DateTimeRange requestTerm, bool existTerm) {
                      shiftFrame.dateTerm[0] = shiftTerm;
                      shiftFrame.dateTerm[1] = requestTerm;
                      existPrepareTerm = existTerm;
                    },
                  ),
                  SizedBox(height: screenSize.height * 0.1),
                  InputTimeDivision(
                    onTimeDivsChanged: (List<TimeDivision> timeDivs) {
                      shiftFrame = shiftFrame.copyWith(
                        timeDivs: timeDivs,
                      );
                    },
                  ),
                  SizedBox(height: screenSize.height * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  シフト管理画面の使い方を説明するための関数
  ////////////////////////////////////////////////////////////////////////////////////////////

  Future<int?> showInfoDialog(bool isDarkTheme) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              title: Text(
                "「シフト表の作成画面①」の使い方",
                style: Styles.headlineStyleGreen20,
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.95,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "この画面では、シフト表の基本設定を行います。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Text(
                              "以下の各項目を入力して下さい。",
                              style: Styles.headlineStyleGrey13,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text("1. シフト表名", style: Styles.headlineStyle15),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // hou to use Followed Shift
                            const SizedBox(height: 10),
                            Text(
                              "「作成するシフト表」の名前を入力して下さい。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Text(
                              "最大文字数は10文字です。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset(
                                "assets/how_to_use/create_1_1.png",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "2. シフト期間 / リクエスト期間",
                          style: Styles.headlineStyle15,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // hou to use Followed Shift
                            const SizedBox(height: 10),
                            Text(
                              "　　「シフト期間」... 作成するシフト表のシフト期間",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Text(
                              "「リクエスト期間」... シフト表のリクエスト募集期間",
                              style: Styles.headlineStyleGrey13,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "例)",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Text(
                              "'12/1 ~ 12/31' の間のシフトリクエストを '11/15 ~ 11/25' の間に受け取り、11/26 ~ 11/30 の間にシフトを組みたい場合",
                              style: Styles.headlineStyleGrey13,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "この場合、参考画像のように設定します。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/how_to_use/create_1_2.png",
                                  ),
                                  Image.asset(
                                    "assets/how_to_use/create_1_3.png",
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "「シフト期間」と「リクエスト期間」の間の期間で、シフトを組みます。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Text(
                              "そのため「シフト期間」と「リクエスト期間」の間は１日以上の間隔が必要です。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "3. 基本の時間区分",
                          style: Styles.headlineStyle15,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // hou to use Followed Shift
                            Text(
                              "「基本の時間区分」とは、シフト表の時間区分のことです。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Text(
                              "「始業時間」「就業時間」「管理間隔」を設定後、「入力ボタン」を押し、時間区分のリストを作成してください。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "例)",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Text(
                              "始業時間 8:00 ~ 就業時間 22:00 で 1 時間間隔でシフトを組む場合",
                              style: Styles.headlineStyleGrey13,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "この場合、参考画像のように設定します。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/how_to_use/create_1_4.png",
                                  ),
                                  Image.asset(
                                    "assets/how_to_use/create_1_5.png",
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "「始業時間」「就業時間」は、平均的な勤務日の「始業時間」「就業時間」を設定してください。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Text(
                              "平日や休日で勤務時間が異なる場合は、できるだけ「勤務時間」が長い方に合わせましょう。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "「入力ボタン」を押すと「始業時間」から「就業時間」までの時間が「管理間隔」で分割されたリストが表示されます。",
                              style: Styles.headlineStyleGrey13,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "4. 時間区分のカスタム",
                          style: Styles.headlineStyle15,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              "各時間区分をタップすると、その下部の時間区分と連結できます。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Text(
                              "理想の時間区分にカスタマイズしましょう。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "時間区分の変更履歴は「戻るボタン」で遡ることができます。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Image.asset(
                                    "assets/how_to_use/create_1_6.png",
                                  ),
                                  Image.asset(
                                    "assets/how_to_use/create_1_7.png",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          "5. 次の画面へ",
                          style: Styles.headlineStyle15,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              "各項目の入力が終了したら、画面右上の「次へボタン」より「勤務人数の設定画面」へと遷移します。",
                              style: Styles.headlineStyleGrey13,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Image.asset(
                                "assets/how_to_use/create_1_8.png",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('閉じる', style: Styles.headlineStyleGreen13),
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
  }
}
