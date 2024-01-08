import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shift/src/components/form/button.dart';
import 'package:shift/src/components/form/modal_window.dart';
import 'package:shift/src/components/shift/shift_frame.dart';
import 'package:shift/src/components/style/style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DateTermInputWidget extends ConsumerStatefulWidget {
  final Function(
    DateTimeRange shiftTerm,
    DateTimeRange requestTerm,
    bool existPrepareTerm,
  ) onDateTermChanged;

  const DateTermInputWidget({
    super.key,
    required this.onDateTermChanged,
  });

  @override
  DateTermInputWidgetState createState() => DateTermInputWidgetState();
}

class DateTermInputWidgetState extends ConsumerState<DateTermInputWidget>
    with SingleTickerProviderStateMixin {
  double appBarHeight = 0;
  Size screenSize = const Size(0, 0);
  late TabController tabController;

  // シフト作成期間の日数を表す変数
  int templateShiftTermIndex = 0;
  int templateReqLimitIndex = 5;
  int tabIndex = 0;

  DateTime base = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

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
      start: DateTime.now().add(
        const Duration(days: 11),
      ),
      end: DateTime.now().add(
        const Duration(days: 30),
      ),
    ),
    DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(
        const Duration(days: 9),
      ),
    )
  ];

  bool existPrepareTerm = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    DateTime end = customDateRange[0]
        .start
        .subtract(const Duration(days: 1))
        .add(const Duration(minutes: 2));
    DateTime start = customDateRange[1]
        .end
        .add(const Duration(days: 1))
        .add(const Duration(minutes: 1));

    existPrepareTerm = (end.difference(start).inDays + 1 > 0);

    widget.onDateTermChanged(
      templateDateRange[0],
      templateDateRange[1],
      existPrepareTerm,
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
    screenSize = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,
    );

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                "② 「リクエスト期間」/「シフト期間」を設定して下さい。",
                style: isDark
                    ? Styles.defaultStyleWhite15
                    : Styles.defaultStyleBlack15,
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          TabBar(
            controller: tabController,
            indicatorColor: Styles.primaryColor,
            dividerColor: Colors.grey,
            labelStyle: Styles.headlineStyle13,
            labelColor: Styles.primaryColor,
            unselectedLabelColor: Colors.grey,
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
                  existPrepareTerm,
                );
              } else if (tabIndex == 1) {
                widget.onDateTermChanged(
                  customDateRange[0],
                  customDateRange[1],
                  existPrepareTerm,
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
              Text("※ ", style: Styles.defaultStyleRed13),
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
      ),
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
    DateTime end = templateDateRange[0]
        .start
        .subtract(const Duration(days: 1))
        .add(const Duration(minutes: 2));
    DateTime start = templateDateRange[1]
        .end
        .add(const Duration(days: 1))
        .add(const Duration(minutes: 1));

    bool exitPrepareTerm = (end.difference(start).inDays + 1 > 0);

    return Column(
      children: [
        Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(flex: 0.4),
            1: IntrinsicColumnWidth(flex: 0.1),
            2: IntrinsicColumnWidth(flex: 0.5),
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
                  widget.onDateTermChanged(
                    templateDateRange[0],
                    templateDateRange[1],
                    exitPrepareTerm,
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
                  widget.onDateTermChanged(
                    templateDateRange[0],
                    templateDateRange[1],
                    exitPrepareTerm,
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
              (!exitPrepareTerm)
                  ? Text(
                      "確保できません",
                      style: Styles.defaultStyleRed15,
                    )
                  : printDateTerm(DateTimeRange(start: start, end: end)),
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
    DateTime end = customDateRange[0].start;
    DateTime start = customDateRange[1].end;

    existPrepareTerm = (end.difference(start).inDays > 0);
    
    print(end);
    print(start);
    
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(flex: 0.4),
        1: IntrinsicColumnWidth(flex: 0.1),
        2: IntrinsicColumnWidth(flex: 0.5),
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
                widget.onDateTermChanged(
                  customDateRange[0],
                  customDateRange[1],
                  existPrepareTerm,
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
                widget.onDateTermChanged(
                  customDateRange[0],
                  customDateRange[1],
                  existPrepareTerm,
                );
              },
            ),
          ),
        ),
        tableRow(
          'シフト作成期間',
          (!existPrepareTerm)
              ? Text(
                  "確保できません",
                  style: Styles.defaultStyleRed15,
                )
              : printDateTerm(DateTimeRange(start: start, end: end)),
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
          style: Styles.defaultStyleGrey15,
          textAlign: TextAlign.right,
        ),
        Text(
          ' ⇨ ',
          style: Styles.defaultStyleGrey15,
          textAlign: TextAlign.center,
        ),
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
          style: Styles.headlineStyleGreen15,
        ),
        Text(
          " - ",
          style: Styles.headlineStyleGreen15,
        ),
        Text(
          DateFormat('MM/dd', 'ja_JP').format(dateTerm.end),
          style: Styles.headlineStyleGreen15,
        ),
        Text(
          " [ ${(dateTerm.end.difference(dateTerm.start).inDays + 1).toString().padLeft(2, ' ')}日 ]",
          style: Styles.headlineStyleGreen15,
        ),
      ],
    );
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
      text: items[selected],
      enable: true,
      width: screenSize.width * 0.445,
      height: 40,
      action: () async {
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
                    style: Styles.headlineStyle13,
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
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shadowColor: Styles.hiddenColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          side: const BorderSide(color: Styles.primaryColor),
        ),
        onPressed: () async {
          final x = pickDateRange(context, dateTerm);
          x.then((value) {
            dateTerm = value;
            onPressed(value);
          });
          setState(() {});
        },
        child: printDateTerm(dateTerm),
      ),
    );
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
    } else {
      print("index error");
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
