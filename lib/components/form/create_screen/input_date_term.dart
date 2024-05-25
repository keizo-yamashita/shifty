import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shift/components/form/utility/button.dart';
import 'package:shift/components/form/utility/modal_window.dart';
import 'package:shift/models/shift_frame.dart';
import 'package:shift/components/style/style.dart';

class InputDateTerm extends StatefulWidget {
  final Function(
    DateTimeRange shiftTerm,
    DateTimeRange requestTerm,
    bool existPrepareTerm,
  ) onDateTermChanged;

  const InputDateTerm({
    super.key,
    required this.onDateTermChanged,
  });

  @override
  InputDateTermState createState() => InputDateTermState();
}

class InputDateTermState extends State<InputDateTerm>
    with SingleTickerProviderStateMixin {
  Size screenSize = const Size(0, 0);
  late TabController tabController;

  // シフト作成期間の日数を表す変数
  int templateShiftTermIndex = 0;
  int templateReqLimitIndex = 5;
  int tabIndex = 0;

  final List<DateTimeRange> templateDateRange = [
    DateTimeRange(
      start: DateTime(
        DateTime.now().add(const Duration(days: 1)).year,
        DateTime.now().add(const Duration(days: 1)).month + 1,
        1,
      ),
      end: DateTime(
        DateTime.now().add(const Duration(days: 1)).year,
        DateTime.now().add(const Duration(days: 2)).month + 2,
        0,
      ),
    ),
    DateTimeRange(
      start: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      end: DateTime(
        DateTime.now().add(const Duration(days: 1)).year,
        DateTime.now().add(const Duration(days: 1)).month + 1,
        -1,
      ),
    ),
  ];

  final List<DateTimeRange> customDateRange = [
    DateTimeRange(
        start: DateTime(
          DateTime.now().add(const Duration(days: 11)).year,
          DateTime.now().add(const Duration(days: 11)).month,
          DateTime.now().add(const Duration(days: 11)).day,
        ),
        end: DateTime(
          DateTime.now().add(const Duration(days: 30)).year,
          DateTime.now().add(const Duration(days: 30)).month,
          DateTime.now().add(const Duration(days: 30)).day,
        )),
    DateTimeRange(
      start: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      end: DateTime(
        DateTime.now().add(const Duration(days: 9)).year,
        DateTime.now().add(const Duration(days: 9)).month,
        DateTime.now().add(const Duration(days: 9)).day,
      ),
    )
  ];

  bool existTemplatePrepareTerm = false;
  bool existCustomPrepareTerm = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    DateTime end = templateDateRange[0].start.subtract(const Duration(days: 1));
    DateTime start = templateDateRange[1].end.add(const Duration(days: 1));

    existTemplatePrepareTerm = (end.difference(start).inDays >= 0);

    widget.onDateTermChanged(
      templateDateRange[0],
      templateDateRange[1],
      existTemplatePrepareTerm,
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    tabController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Text(
              "② 「リクエスト期間」/「シフト期間」を設定して下さい。",
              style: Styles.defaultStyle15,
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        TabBar(
          controller: tabController,
          indicatorColor: Styles.primaryColor,
          dividerColor: Colors.grey,
          labelStyle: Styles.defaultStyle13,
          labelColor: Styles.primaryColor,
          tabs: const [
            Tab(text: 'テンプレート'),
            Tab(text: 'カスタム'),
          ],
          onTap: (int index) {
            tabIndex = index;
            if (tabIndex == 0) {
              widget.onDateTermChanged(
                templateDateRange[0],
                templateDateRange[1],
                existTemplatePrepareTerm,
              );
            } else if (tabIndex == 1) {
              widget.onDateTermChanged(
                customDateRange[0],
                customDateRange[1],
                existCustomPrepareTerm,
              );
            }
            setState(() {});
          },
        ),
        SizedBox(height: screenSize.height * 0.02),
        tabBarView(),
        SizedBox(height: screenSize.height * 0.02),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("※ ", style: Styles.headlineStyleRed13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "リクエスト期間中はシフトを組むことができません。",
                    style: Styles.defaultStyleRed13,
                    maxLines: 4,
                  ),
                  Text(
                    "リクエスト期間終了日からシフト開始日までの期間がシフト作成期間となります。(1日以上の期間を設けて下さい。)",
                    style: Styles.defaultStyleRed13,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  ///////////////////////////////////////////////
  /// メインのタブビュー
  ///////////////////////////////////////////////

  Widget tabBarView() {
    switch (tabIndex) {
      case 0:
        return buildTempleteSelector();
      case 1:
        return buildCustomSelector();
      default:
        return buildTempleteSelector();
    }
  }

  ///////////////////////////////////////////////
  /// テンプレートの UI
  ///////////////////////////////////////////////

  Widget buildTempleteSelector() {
    DateTime end = templateDateRange[0].start.subtract(const Duration(days: 1));
    DateTime start = templateDateRange[1].end.add(const Duration(days: 1));
    existTemplatePrepareTerm = (end.difference(start).inDays >= 0);

    return Column(
      children: [
        Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(flex: 0.35),
            1: IntrinsicColumnWidth(flex: 0.05),
            2: IntrinsicColumnWidth(flex: 0.6),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            tableRow(
              'シフト表の周期',
              buildTemplateSettingPicker(
                templateShiftTermSelect,
                templateShiftTermIndex,
                (int index) {
                  templateShiftTermIndex = index;
                  updateTemplateShiftRange();
                  DateTime end = templateDateRange[0].start.subtract(
                        const Duration(days: 1),
                      );
                  DateTime start = templateDateRange[1].end.add(
                        const Duration(days: 1),
                      );
                  existTemplatePrepareTerm =
                      (end.difference(start).inDays >= 0);
                  widget.onDateTermChanged(
                    templateDateRange[0],
                    templateDateRange[1],
                    existTemplatePrepareTerm,
                  );
                  setState(() {});
                },
              ),
            ),
            tableRow(
              'リクエスト入力期限',
              buildTemplateSettingPicker(
                templateReqLimitSelect,
                templateReqLimitIndex,
                (int index) {
                  templateReqLimitIndex = index;
                  updateTemplateShiftRange();
                  DateTime end = templateDateRange[0]
                      .start
                      .subtract(const Duration(days: 1));
                  DateTime start =
                      templateDateRange[1].end.add(const Duration(days: 1));
                  existTemplatePrepareTerm =
                      (end.difference(start).inDays >= 0);
                  widget.onDateTermChanged(
                    templateDateRange[0],
                    templateDateRange[1],
                    existTemplatePrepareTerm,
                  );
                  setState(() {});
                },
              ),
            ),
            tableRow(
              'シフトリクエスト期間',
              printDateTerm(templateDateRange[1]),
            ),
            tableRow(
              'シフト期間',
              printDateTerm(templateDateRange[0]),
            ),
            tableRow(
              'シフト作成期間',
              (!existTemplatePrepareTerm)
                  ? Container(
                      alignment: Alignment.center,
                      child: Text(
                        "確保できません",
                        style: Styles.defaultStyleRed13,
                      ),
                    )
                  : printDateTerm(
                      DateTimeRange(
                        start: start,
                        end: end,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  ///////////////////////////////////////////////
  /// カスタム用の UI
  ///////////////////////////////////////////////

  Widget buildCustomSelector() {
    DateTime end = customDateRange[0].start.subtract(const Duration(days: 1));
    DateTime start = customDateRange[1].end.add(const Duration(days: 1));
    existCustomPrepareTerm = (end.difference(start).inDays >= 0);

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(flex: 0.35),
        1: IntrinsicColumnWidth(flex: 0.05),
        2: IntrinsicColumnWidth(flex: 0.6),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        tableRow(
          'シフトリクエスト期間',
          buildInputBox(
            null,
            buildDateRangePicker(
              customDateRange[1],
              (value) {
                customDateRange[1] = value;
                DateTime end =
                    customDateRange[0].start.subtract(const Duration(days: 1));
                DateTime start =
                    customDateRange[1].end.add(const Duration(days: 1));
                existCustomPrepareTerm = (end.difference(start).inDays >= 0);
                widget.onDateTermChanged(
                  customDateRange[0],
                  customDateRange[1],
                  existCustomPrepareTerm,
                );
              },
            ),
          ),
        ),
        tableRow(
          'シフト期間',
          buildInputBox(
            null,
            buildDateRangePicker(
              customDateRange[0],
              (value) {
                customDateRange[0] = value;
                DateTime end =
                    customDateRange[0].start.subtract(const Duration(days: 1));
                DateTime start =
                    customDateRange[1].end.add(const Duration(days: 1));
                existCustomPrepareTerm = (end.difference(start).inDays >= 0);
                widget.onDateTermChanged(
                  customDateRange[0],
                  customDateRange[1],
                  existCustomPrepareTerm,
                );
              },
            ),
          ),
        ),
        tableRow(
          'シフト作成期間',
          (!existCustomPrepareTerm)
              ? Container(
                  alignment: Alignment.center,
                  child: Text(
                    "確保できません",
                    style: Styles.defaultStyleRed13,
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(left: screenSize.width * 0.03),
                  child: SizedBox(
                    width: screenSize.width * 0.6,
                    height: 40,
                    child: printDateTerm(
                      DateTimeRange(
                        start: start,
                        end: end,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  ///////////////////////////////////////////////
  /// タブビュー内の要素のラッパー
  ///////////////////////////////////////////////

  TableRow tableRow(String title, Widget child) {
    return TableRow(
      children: [
        Text(
          title,
          style: Styles.defaultStyle13,
          textAlign: TextAlign.right,
        ),
        Container(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            width: screenSize.width * 0.45,
            height: 40,
            child: child,
          ),
        ),
      ],
    );
  }

  ///////////////////////////////////////////////
  /// DateTimeRange をプリントする
  ///////////////////////////////////////////////

  Widget printDateTerm(DateTimeRange dateTerm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          DateFormat('MM/dd', 'ja_JP').format(dateTerm.start),
          style: Styles.defaultStyleGreen13,
        ),
        Text(
          " - ",
          style: Styles.defaultStyleGreen13,
        ),
        Text(
          DateFormat('MM/dd', 'ja_JP').format(dateTerm.end),
          style: Styles.defaultStyleGreen13,
        ),
        Text(
          "  ( ${(dateTerm.end.difference(dateTerm.start).inDays + 1).toString().padLeft(2, ' ')}日 )",
          style: Styles.defaultStyleGreen13,
        ),
      ],
    );
  }

  String textDateTerm(DateTimeRange dateTerm) {
    return "${DateFormat('MM/dd', 'ja_JP').format(dateTerm.start)} - ${DateFormat('MM/dd', 'ja_JP').format(dateTerm.end)}  ( ${(dateTerm.end.difference(dateTerm.start).inDays + 1).toString().padLeft(2, ' ')}日 )";
  }

  //////////////////////////////////////////
  /// テンプレートの設定を開くボタン
  //////////////////////////////////////////

  Widget buildTemplateSettingPicker(
    List<String> items,
    int selected,
    Function(int) onPressed,
  ) {
    return CustomTextButton(
      icon: Icons.menu,
      text: items[selected],
      enable: true,
      width: screenSize.width * 0.6,
      height: 40,
      onPressed: () async {
        showModalWindow(
          context,
          0.5,
          buildModalWindowContainer(
            context,
            List<Widget>.generate(
              items.length,
              (index) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    items[index],
                    style: Styles.defaultStyle15,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            0.5,
            (BuildContext context, int index) {
              onPressed(index);
            },
          ),
        );
      },
    );
  }

  //////////////////////////////////////////
  /// カスタムの設定を開くボタン
  //////////////////////////////////////////

  Widget buildDateRangePicker(
    DateTimeRange dateTerm,
    Function(DateTimeRange) onPressed,
  ) {
    return CustomTextButton(
        onPressed: () async {
          final x = pickDateRange(context, dateTerm);
          x.then((value) {
            dateTerm = value;
            onPressed(value);
          });
          setState(() {});
        },
        enable: true,
        width: screenSize.width * 0.6,
        height: 40,
        icon: Icons.calendar_month_outlined,
        text: textDateTerm(dateTerm));
  }

  Future<DateTimeRange> pickDateRange(
    BuildContext context,
    DateTimeRange initialDateRange,
  ) async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime.now().subtract(const Duration(days: 10)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              dividerColor: Styles.primaryColor.withAlpha(100),
              shadowColor: Styles.primaryColor,
              dayBackgroundColor:
                  MaterialStateProperty.all<Color>(Styles.primaryColor),
              rangeSelectionBackgroundColor: Styles.primaryColor.withAlpha(100),
            ),
          ),
          child: child!,
        );
      },
    );
    if (newDateRange != null) {
      setState(() {});
      return Future<DateTimeRange>.value(newDateRange);
    } else {
      setState(() {});
      return Future<DateTimeRange>.value(initialDateRange);
    }
  }

  /////////////////////////////////////////////////////////////
  /// シフト期間テンプレートを使った時の処理
  /////////////////////////////////////////////////////////////

  void updateTemplateShiftRange() {
    var date = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).add(
      Duration(days: 7 - templateReqLimitIndex - 1),
    );
    var now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    DateTime startDate = date;
    DateTime endDate = date;

    if (templateShiftTermIndex == 0) {
      // 月ごとの場合
      startDate = DateTime(date.year, date.month + 1, 1);
      endDate = DateTime(date.year, date.month + 2, 0);
    } else if (templateShiftTermIndex == 1) {
      // 二週毎の場合
      DateTime startOfThisWeek = date.subtract(
        Duration(
          days: date.add(const Duration(days: 1)).weekday - 2,
        ),
      );
      startDate = startOfThisWeek.add(const Duration(days: 7));
      endDate = startDate.add(const Duration(days: 13));
    } else if (templateShiftTermIndex == 2) {
      // 一週毎の場合
      DateTime startOfThisWeek = date.subtract(
        Duration(
          days: date.add(const Duration(days: 1)).weekday - 2,
        ),
      );
      startDate = startOfThisWeek.add(const Duration(days: 7));
      endDate = startDate.add(const Duration(days: 6));
    }

    templateDateRange[0] = DateTimeRange(
      start: startDate,
      end: endDate,
    );
    templateDateRange[1] = DateTimeRange(
      start: now,
      end: startDate.subtract(
        Duration(days: 7 - templateReqLimitIndex),
      ),
    );
  }

  Widget buildInputBox(Widget? title, Widget child) {
    return Column(
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: title,
          ),
        child
      ],
    );
  }
}
