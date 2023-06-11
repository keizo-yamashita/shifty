import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:shift/src/functions/show_modal_window.dart';

class InputTimeDivisions extends StatefulWidget {
  final ShiftTable _shiftTable;
  const InputTimeDivisions({Key? key, required ShiftTable shiftTable}) : _shiftTable = shiftTable, super(key: key);
  
  @override
  TimeDivisionState createState() => TimeDivisionState();
}

class TimeDivisionState extends State<InputTimeDivisions> {

  static DateTime _startTime = DateTime(1, 1, 1, 9, 0);
  static DateTime _endTime   = DateTime(1, 1, 1, 21, 0);
  static DateTime _duration  = DateTime(1, 1, 1, 0, 30);
  
  static List<TimeDivision>  _timeDivsTemp = [];
  static int                 _durationTemp = 30;
  
  @override
  Widget build(BuildContext context) {
    
    var appBarHeight = AppBar().preferredSize.height;
    var screenSize   = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenSize.height/10 + appBarHeight), 
          Row(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: MyFont.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("STEP 1", style: MyFont.headlineStyleWhite20),
              ),
              Text("時間区分の設定", style: MyFont.headlineStyleGreen20),
            ],             
          ),
          
          SizedBox(height: screenSize.height/30),
          Text("まずは，基本となる時間区分を設定しましょう", style: MyFont.defaultStyleGrey15),
          SizedBox(height: screenSize.height/30),
    
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildInputBox("始業時間", buildTimePicker(_startTime, DateTime(1,1,1,0,0), DateTime(1,1,1,23,59), 5, setStartTime)),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(" 〜 ", style: MyFont.headlineStyleGreen15),
              ),
              buildInputBox("終業時間", buildTimePicker(_endTime, _startTime.add(const Duration(hours: 1)), DateTime(1,1,1,23,59), 5, setEndTime)),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(" ... ", style: MyFont.headlineStyleGreen15),
              ),
              buildInputBox("管理間隔", buildTimePicker(_duration, DateTime(1,1,1,0,10), DateTime(1,1,1,6,0), 5, setDuration)),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text("     ", style: MyFont.headlineStyleGreen15),
              ),
              buildInputBox("", InkWell(
                onTap: () {
                  setState(() {
                    createMimimumDivision(_startTime, _endTime, _duration);
                  });
                },
                child: Container(
                  height: 50,
                  width: 60,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: MyFont.primaryColor,
                    borderRadius: BorderRadius.circular(9), 
                  ),
                  child: const Icon(
                    size: 20,
                    Icons.check,  
                    color: MyFont.backgroundColor
                  ),
                ),
              ))
            ],
          ),
    
          const Divider(height: 50, thickness: 1),
    
          // 登録した時間区分一覧
          (widget._shiftTable.timeDivs.isEmpty) ? Text("登録されている時間区分がありません", style: MyFont.defaultStyleGrey15) : buildScheduleEditor(),
          SizedBox(height: screenSize.height / 20 + appBarHeight),
        ],
      ),
    );
  }

  Widget buildTimePicker(DateTime init, DateTime min, DateTime max, int interval, Function(DateTime) callback){
    
    DateTime temp = init;

    return SizedBox(
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: MyFont.backgroundColor,
          shadowColor: MyFont.hiddenColor, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: MyFont.primaryColor),
        ),
        onPressed: () async {
          await showModalWindow(context, SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.maxFinite,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: init,
              minuteInterval: interval,
              minimumDate: min,
              maximumDate: max,
              onDateTimeChanged: (val){ setState(() { temp = val; callback(val); }); },
              use24hFormat: true,
              ),
            )
          );
        },
        child: Text('${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}', style: MyFont.headlineStyleGreen15)
      ),
    );
  }
  
  void setDuration(DateTime val){
    setState(() {
      _duration = val;
    });
  }
  void setStartTime(DateTime val){
    setState(() {   
      _startTime = val;
    });
  }
  void setEndTime(DateTime val){
    setState(() {
      _endTime = val;    
    });
  }

  Widget buildInputBox(String title, Widget child){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(title, style: MyFont.headlineStyleGreen15),
        ),
        Container(
          child: child
        )
      ],
    );
  }

  void createMimimumDivision(DateTime start, DateTime end, DateTime duration){
    setState(() {
      widget._shiftTable.timeDivs.clear();
      while(start.compareTo(end) < 0){
        var temp = start.add(Duration(hours: duration.hour, minutes: duration.minute));
        if(temp.compareTo(end) > 0){
          temp = end;
        }
        widget._shiftTable.addTimeDivision("${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} ~ ${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}", DateTime(1, 1, 1, start.hour, start.minute), DateTime(1, 1, 1, temp.hour, temp.minute));
        start = temp;
      }
      _timeDivsTemp = List.of(widget._shiftTable.timeDivs);
      _durationTemp = _duration.hour*60+_duration.minute;
    });
  }

  buildScheduleEditor(){
    double height = 40;
    double boader = 2;

    var timeDivs = widget._shiftTable.timeDivs;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 50,
          child: Column(
            children: [
              for(final timeDiv in _timeDivsTemp)
                SizedBox(
                  height: height + boader,
                  child: Text("${timeDiv.startTime.hour.toString().padLeft(2, '0')}:${timeDiv.startTime.minute.toString().padLeft(2, '0')} -", style: MyFont.headlineStyleGreen15, textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                ),
              SizedBox(
                height: height + boader,
                child: Text("${_timeDivsTemp.last.endTime.hour.toString().padLeft(2, '0')}:${_timeDivsTemp.last.endTime.minute.toString().padLeft(2, '0')} -", style: MyFont.headlineStyleGreen15, textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 150,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(5)),
              for(int i = 0; i < widget._shiftTable.timeDivs.length; i++)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(boader/2),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if(i+1 != timeDivs.length){
                            timeDivs[i].endTime =  timeDivs[i+1].endTime;
                            timeDivs[i].name = "${timeDivs[i].startTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].startTime.minute.toString().padLeft(2, '0')} 〜 ${timeDivs[i].endTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].endTime.minute.toString().padLeft(2, '0')}";
                            timeDivs.removeAt(i+1);
                          }
                        });
                      },
                      splashColor: MyFont.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: MyFont.primaryColor,
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        height: (height*(( (timeDivs[i].endTime.hour*60 + timeDivs[i].endTime.minute) - (timeDivs[i].startTime.hour*60+timeDivs[i].startTime.minute) ) / _durationTemp).ceil())
                        +(boader*((((timeDivs[i].endTime.hour*60 + timeDivs[i].endTime.minute) - (timeDivs[i].startTime.hour*60+timeDivs[i].startTime.minute)) / _durationTemp).ceil()-1)),
                        child: Center(
                          child: Text("${timeDivs[i].startTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].startTime.minute.toString().padLeft(2, '0')} 〜 ${timeDivs[i].endTime.hour.toString().padLeft(2, '0')}:${timeDivs[i].endTime.minute.toString().padLeft(2, '0')}", style: MyFont.defaultStyleWhite13, textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)
                        )
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
