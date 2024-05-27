////////////////////////////////////////////////////////////////////////////////////////////
/// シフト表一括入力のためのクラス
////////////////////////////////////////////////////////////////////////////////////////////

class AssignRule {
  AssignRule({
    required this.week,
    required this.weekday,
    required this.timeDivs1,
    required this.timeDivs2,
    required this.assignNum,
  });

  final int week;
  final int weekday;
  int timeDivs1;
  int timeDivs2;
  final int assignNum;
}