import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shift/src/components/form/utility/button.dart';
import 'package:shift/src/components/form/utility/modal_window.dart';
import 'package:shift/src/components/style/style.dart';
import 'package:shift/src/components/shift/shift_frame.dart';
import 'package:shift/src/components/undo_redo.dart';

class InputTimeDivision extends StatefulWidget {
  final Function(
    List<TimeDivision> timeDivs,
  ) onTimeDivsChanged;

  const InputTimeDivision({
    required this.onTimeDivsChanged,
    super.key,
  });

  @override
  InputTimeDivisionState createState() => InputTimeDivisionState();
}

class InputTimeDivisionState extends State<InputTimeDivision> {
  Size screenSize = const Size(0, 0);
  bool isDark = false;

  // 時間区分のカスタムのための変数
  List<TimeDivision> timeDivs = [];
  List<TimeDivision> timeDivsAxis = [];
  int durationAxis = 60;

  // シフト時間区部設定のための parameters
  DateTime startTime = DateTime(1, 1, 1, 9, 0);
  DateTime endTime = DateTime(1, 1, 1, 21, 0);
  DateTime duration = DateTime(1, 1, 1, 0, 60);

  UndoRedo<List<TimeDivision>> undoredoCtrl = UndoRedo<List<TimeDivision>>(50);

  @override
  void initState() {
    super.initState();
    insertBuffer(timeDivs);
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            fit: BoxFit.fill,
            child: Text(
              "③ 基本となる時間区分を設定して下さい。",
              style: Styles.defaultStyle15,
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),

        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildInputBox(
                SizedBox(
                  height: 20,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      "始業時間",
                      style: Styles.defaultStyle13,
                    ),
                  ),
                ),
                buildTimePicker(
                  startTime,
                  DateTime(1, 1, 1, 0, 0),
                  DateTime(1, 1, 1, 23, 59),
                  5,
                  setStartTime,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Text("〜", style: Styles.defaultStyleGreen13),
              ),
              buildInputBox(
                SizedBox(
                  height: 20,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      "終業時間",
                      style: Styles.defaultStyle13,
                    ),
                  ),
                ),
                buildTimePicker(
                  endTime,
                  startTime.add(const Duration(hours: 1)),
                  DateTime(1, 1, 1, 23, 59),
                  5,
                  setEndTime,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Text("...", style: Styles.headlineStyleGreen13),
              ),
              buildInputBox(
                SizedBox(
                  height: 20,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      "管理間隔",
                      style: Styles.defaultStyle13,
                    ),
                  ),
                ),
                buildTimePicker(
                  duration,
                  DateTime(1, 1, 1, 0, 10),
                  DateTime(1, 1, 1, 6, 0),
                  5,
                  setDuration,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextButton(
              text: "入力",
              enable: true,
              width: screenSize.width * 0.44,
              height: 30,
              onPressed: () {
                setState(
                  () {
                    createMimimumDivision(startTime, endTime, duration);
                    insertBuffer(timeDivs);
                    widget.onTimeDivsChanged(timeDivs);
                  },
                );
              },
            ),
            CustomTextButton(
              text: "戻す",
              enable: undoredoCtrl.enableUndo(),
              width: screenSize.width * 0.44,
              height: 30,
              onPressed: () {
                setState(
                  () {
                    timeDivsUndoRedo(true);
                    widget.onTimeDivsChanged(timeDivs);
                  },
                );
              },
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.04),

        ////////////////////////////////////////////////////////////////////////////
        /// 登録した時間区分一覧
        ////////////////////////////////////////////////////////////////////////////
        Text(
          "時間区分一覧（タップで結合）",
          style: Styles.defaultStyle13,
          textAlign: TextAlign.left,
        ),
        SizedBox(height: screenSize.height * 0.04),
        (timeDivs.isEmpty)
            ? Text(
                "登録されている時間区分がありません。",
                style: Styles.defaultStyle13,
              )
            : buildScheduleEditor(),
      ],
    );
  }

  Widget buildTimePicker(DateTime init, DateTime min, DateTime max,
      int interval, Function(DateTime) callback,) {
    DateTime temp = init;

    return CustomTextButton(
      width: screenSize.width / 4,
      height: 40,
      enable: true,
      icon: Icons.watch_later_outlined,
      text:
          '${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}',
      onPressed: () async {
        await showModalWindow(
          context,
          0.4,
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.maxFinite,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: init,
              minuteInterval: interval,
              minimumDate: min,
              maximumDate: max,
              onDateTimeChanged: (val) {
                setState(
                  () {
                    temp = val;
                    callback(val);
                  },
                );
              },
              use24hFormat: true,
            ),
          ),
        );
      },
    );
  }

  void createMimimumDivision(DateTime start, DateTime end, DateTime duration) {
    setState(
      () {
        timeDivs.clear();
        while (start.compareTo(end) < 0) {
          var temp = start
              .add(Duration(hours: duration.hour, minutes: duration.minute));
          if (temp.compareTo(end) > 0) {
            temp = end;
          }
          timeDivs.add(
            TimeDivision(
              name:
                  "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}-${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}",
              startTime: DateTime(1, 1, 1, start.hour, start.minute),
              endTime: DateTime(1, 1, 1, temp.hour, temp.minute),
            ),
          );
          start = temp;
        }
        timeDivsAxis = List.of(timeDivs);
        durationAxis = duration.hour * 60 + duration.minute;
      },
    );
  }

  void setDuration(DateTime val) {
    setState(
      () {
        duration = val;
      },
    );
  }

  void setStartTime(DateTime val) {
    setState(
      () {
        startTime = val;
      },
    );
  }

  void setEndTime(DateTime val) {
    setState(
      () {
        endTime = val;
      },
    );
  }

  Widget buildInputBox(Widget? title, Widget child) {
    return Column(
      children: [
        child,
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: title,
          ),
      ],
    );
  }

  ///////////////////////////////////////////////////////////////////////////////////
  /// Build Schedule Editor
  ///////////////////////////////////////////////////////////////////////////////////

  buildScheduleEditor() {
    double height = 40;
    double boader = 4;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: Column(
            children: [
              for (final timeDiv in timeDivsAxis)
                SizedBox(
                  height: height + boader,
                  child: Text(
                    "${timeDiv.startTime.hour.toString().padLeft(2, '0')}:${timeDiv.startTime.minute.toString().padLeft(2, '0')}-",
                    style: Styles.defaultStyle13,
                    textHeightBehavior: Styles.defaultBehavior,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              SizedBox(
                height: height + boader,
                child: Text(
                  "${timeDivsAxis.last.endTime.hour.toString().padLeft(2, '0')}:${timeDivsAxis.last.endTime.minute.toString().padLeft(2, '0')}-",
                  style: Styles.defaultStyle13,
                  textHeightBehavior: Styles.defaultBehavior,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 180,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(6)),
              for (int i = 0; i < timeDivs.length; i++)
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(boader / 2),
                      child: InkWell(
                        onTap: () {
                          setState(
                            () {
                              if (i + 1 != timeDivs.length) {
                                timeDivs[i].endTime = timeDivs[i + 1].endTime;
                                timeDivs[i].name =
                                    "${timeDivs[i].startTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].startTime.minute.toString().padLeft(2, '0')}-${timeDivs[i].endTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].endTime.minute.toString().padLeft(2, '0')}";
                                timeDivs.removeAt(i + 1);
                              }
                            },
                          );
                          insertBuffer(timeDivs);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Styles.hiddenColor),
                              borderRadius: BorderRadius.circular(3.0)),
                          height: ((height + boader) *
                                  (calcDurationInMinute(timeDivs[i]) /
                                          durationAxis)
                                      .ceil()) -
                              boader,
                          child: Center(
                            child: Text(
                              "${timeDivs[i].startTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].startTime.minute.toString().padLeft(2, '0')} - ${timeDivs[i].endTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].endTime.minute.toString().padLeft(2, '0')}",
                              style: Styles.defaultStyleGreen13,
                              textHeightBehavior: Styles.defaultBehavior,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ],
    );
  }

  int calcDurationInMinute(TimeDivision timeDiv) {
    return (timeDiv.endTime.hour * 60 + timeDiv.endTime.minute) -
        (timeDiv.startTime.hour * 60 + timeDiv.startTime.minute);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  redo undo 機能の実装
  ////////////////////////////////////////////////////////////////////////////////////////////

  void insertBuffer(List<TimeDivision> timeDivs) {
    setState(() {
      undoredoCtrl
          .insertBuffer(timeDivs.map((e) => TimeDivision.copy(e)).toList());
    });
  }

  void timeDivsUndoRedo(bool undo) {
    setState(() {
      if (undo) {
        timeDivs =
            undoredoCtrl.undo().map((e) => TimeDivision.copy(e)).toList();
      } else {
        timeDivs =
            undoredoCtrl.redo().map((e) => TimeDivision.copy(e)).toList();
      }
    });
  }
}
