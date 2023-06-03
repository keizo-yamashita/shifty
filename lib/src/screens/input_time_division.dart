import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';

class InputTimeDivisions extends StatefulWidget {
  final ShiftTable shiftTable;
  const InputTimeDivisions({Key? key, required this.shiftTable}) : super(key: key);
   
  @override
  TimeDivisionState createState() => TimeDivisionState();
}

class TimeDivisionState extends State<InputTimeDivisions> {
  final myController = TextEditingController();

  DateTime _startTime = DateTime(1, 1, 1, 9, 0);
  DateTime _endTime   = DateTime(1, 1, 1, 21, 0);
  DateTime _duration  = DateTime(1, 1, 1, 0, 30);

  void createMimimumDivision(DateTime start, DateTime end, DateTime duration){
    setState(() {
      widget.shiftTable.timeDivs.clear();
      while(start.compareTo(end) < 0){
        var temp = start.add(Duration(hours: duration.hour, minutes: duration.minute));
        if(temp.compareTo(end) > 0){
          temp = end;
        }
        widget.shiftTable.addTimeDivision("${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} ~ ${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}", TimeOfDay(hour: start.hour, minute: start.minute), TimeOfDay(hour: temp.hour, minute: temp.minute));
        start = temp;
      }
    });
  }

  @override
  void initState() {
    createMimimumDivision(_startTime, _endTime, _duration);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    var screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("STEP 1", style: MyFont.headlineStyleWhite20),
            ),
            Text("時間区分の設定", style: MyFont.headlineStyleGreen20),
          ],             
        ),
        
        SizedBox(height: screenSize.height/30),
        Text("まずは，基本となる時間区分を設定しましょう\n勤務開始時間と勤務終了時間を入力してください", style: MyFont.defaultStyleGrey15),
        SizedBox(height: screenSize.height/30),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text("始業時間", style: MyFont.headlineStyleGreen15),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                    ),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: CupertinoButton(
                    onPressed: () async {
                      final DateTime? picked = await showCupertinoModalPopup(
                        context: context,
                        builder: (_) => Container(
                          height: 200,
                          color: CupertinoColors.white,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            minuteInterval: 5,
                            initialDateTime: _startTime,
                            onDateTimeChanged: (val) {
                              setState(() {
                                _startTime = val;
                                createMimimumDivision(_startTime, _endTime, _duration);
                              });
                            },
                            use24hFormat: true,
                          ),
                        ),
                      );
                    },
                    child: Text('${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}', style: MyFont.headlineStyleGreen15)
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(" 〜 ", style: MyFont.headlineStyleGreen15),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text("終業時間", style: MyFont.headlineStyleGreen15),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                    ),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: CupertinoButton(
                    onPressed: () async {
                      final DateTime? picked = await showCupertinoModalPopup(
                        context: context,
                        builder: (_) => Container(
                          height: 200,
                          color: CupertinoColors.white,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            minuteInterval: 5,
                            initialDateTime: _endTime,
                            minimumDate: _startTime.add(const Duration(hours: 1)),
                            onDateTimeChanged: (val) {
                              setState(() {
                                _endTime = val;
                                createMimimumDivision(_startTime, _endTime, _duration);
                              });
                            },
                            use24hFormat: true,
                          )
                        )
                      );
                    },
                    child: Text('${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}', style: MyFont.headlineStyleGreen15)
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(" ... ", style: MyFont.headlineStyleGreen15),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text("管理間隔", style: MyFont.headlineStyleGreen15),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                    ),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: CupertinoButton(
                    onPressed: () async {
                      final DateTime? picked = await showCupertinoModalPopup(
                        context: context,
                        builder: (_) => Container(
                          height: 200,
                          color: CupertinoColors.white,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            initialDateTime: _duration,
                            minuteInterval: 5,                            
                            minimumDate: DateTime(1, 1, 1, 0, 10),
                            maximumDate: DateTime(1, 1, 1, 6, 0),
                            onDateTimeChanged: (val) {
                              setState(() {
                                _duration = val;
                                createMimimumDivision(_startTime, _endTime, _duration);
                              });
                            },
                            use24hFormat: true,
                          )
                        )
                      );
                    },
                    child: Text('${_duration.hour.toString().padLeft(2, '0')}:${_duration.minute.toString().padLeft(2, '0')}', style: MyFont.headlineStyleGreen15)
                  ),
                ),
              ],
            ),
          ],
        ),
        
        SizedBox(height: screenSize.height / 20),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text("↓  設定される時間区分一覧", style: MyFont.headlineStyleGreen15),
        ),

        // 登録した時間区分一覧
        Container(
          height:  70,
          width: screenSize.width * 0.8,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: widget.shiftTable.timeDivs.length,
            itemBuilder: (context, i) => buildItem(widget.shiftTable.timeDivs[i], i, context),
          ),
        ),
        SizedBox(height: screenSize.height / 20),
      ],
    );
  }

  Widget buildItem(TimeDivision item, int index, BuildContext context) {
    return SizedBox(
      child: Card(
        key: Key(index.toString()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),      
        ),
        color: Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text("${item.startTime.hour.toString().padLeft(2, '0')}:${item.startTime.minute.toString().padLeft(2, '0')}\n 〜 \n${item.endTime.hour.toString().padLeft(2, '0')}:${item.endTime.minute.toString().padLeft(2, '0')}", style: MyFont.defaultStyleWhite13, textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              iconSize: 20,
              onPressed: () {
                widget.shiftTable.removeTimeDivision(index);
                setState(() {});
              },
              icon: const Icon(Icons.delete),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
