import 'package:flutter/material.dart';
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/shift/shift_frame.dart';

///////////////////////////////////////////////////////////////////////
/// テーブルの要素を作るための関数
///////////////////////////////////////////////////////////////////////

List<Widget> getColumnTitles(double height, double width, DateTime start, DateTime end, bool isDark){

  List<String> weekdayJP = ["月", "火", "水", "木", "金", "土", "日"];
  Text         month, day, weekday;

  var columnNum = end.difference(start).inDays+1;

  var titleList = [
    Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      child: Text("", style: MyStyle.defaultStyleBlack10),
    )
  ];
  
  for(int i = 0; i < columnNum; i++){
    DateTime date = start.add(Duration(days: i));

    if(i == 0){
      month = Text('${date.month}月', style: MyStyle.tableTitleStyle((isDark) ?Colors.white : Colors.black54)); 
    }else if(date.day == 1){
      month = Text('${date.month}月', style: MyStyle.tableTitleStyle((isDark) ?Colors.white : Colors.black54)); 
    }else{
      month = Text(' ', style: MyStyle.tableTitleStyle((isDark) ?Colors.white : Colors.black54)); 
    }

    if(date.weekday == 6){
      day     = Text('${date.day}', style: MyStyle.tableTitleStyle(Colors.blue)); 
      weekday = Text(weekdayJP[date.weekday - 1], style: MyStyle.tableTitleStyle(Colors.blue));
    }else if(date.weekday == 7){
      day     = Text('${date.day}', style: MyStyle.tableTitleStyle(Colors.red)); 
      weekday = Text(weekdayJP[date.weekday - 1], style: MyStyle.tableTitleStyle(Colors.red));
    }else{
      day     = Text('${date.day}', style: MyStyle.tableTitleStyle((isDark) ?Colors.white : Colors.black54)); 
      weekday = Text(weekdayJP[date.weekday - 1], style: MyStyle.tableTitleStyle((isDark) ?Colors.white : Colors.black54));
    }
    titleList.add(
      Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(vertical: 2),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: (height-4)/3, child: FittedBox(fit: BoxFit.fitWidth, child: month)),
            SizedBox(height: (height-4)/3, child: FittedBox(fit: BoxFit.fitWidth, child: day)),
            SizedBox(height: (height-4)/3, child: FittedBox(fit: BoxFit.fitWidth ,child: weekday))
          ]
        )
      )
    );
  }
  titleList.removeAt(0);
  return titleList;
}

List<Widget> getRowTitles(double height, double width, List<TimeDivision> timeDivs, bool isDark){
  return [
      for(int i = 0; i < timeDivs.length; i++)
      Container(
        width:  width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(timeDivs[i].name, style:  MyStyle.tableTitleStyle((isDark) ?Colors.white : Colors.black54)),
        )
      ),
    ];
  }
