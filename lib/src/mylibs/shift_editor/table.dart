
import 'package:flutter/material.dart';
import 'package:shift/src/mylibs/style.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hatchout Scroll',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TopPage(),
    );
  }
}

class TopPage extends StatefulWidget {
  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {

  final _controllerX = ScrollController();
  final _controllerX_title = ScrollController();
  final _controllerY = ScrollController();
  final _controllerY_title = ScrollController();

  final double _titleHeight = 60;
  final double _titleWidth  = 80;
  final double _cellHeight  = 20;
  final double _cellWidth   = 20;

  final bool isDark = false;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('縦横斜めスクロール表'),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: screenSize.width * 0.98,
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Container(color: Colors.white, width: _titleWidth, height: _titleHeight),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // コンテナの背景色
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // 影の色
                              spreadRadius: 0, // 影の広がり度合い
                              blurRadius: 5, // 影のぼかし度合い
                              offset: Offset(5, 0), // 水平方向に5ピクセルずらす
                            ),
                          ],
                        ),
                        width: screenSize.width * 0.98 - 80,
                        child: SingleChildScrollView(
                          controller: _controllerX_title,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: getDateTitle(_titleHeight, _cellWidth, DateTime.now(), DateTime.now().add(Duration(days: 30)), isDark),
                          )
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // コンテナの背景色
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // 影の色
                              spreadRadius: 0, // 影の広がり度合い
                              blurRadius: 5, // 影のぼかし度合い
                              offset: Offset(0, 5), // 水平方向に5ピクセルずらす
                            ),
                          ],
                        ),   
                        height: screenSize.height * 0.8 - 80,
                        child: SingleChildScrollView(
                            controller: _controllerY_title,
                            child: _generateFirstColumnsRow(List.generate(60, (index) => index)),
                        ),
                      ),
                      SizedBox(
                        width: screenSize.width * 0.98 - 80,
                        height: screenSize.height * 0.8 - 80,
                        child: SingleChildScrollView(
                          controller: _controllerY,
                          child: SingleChildScrollView(
                            controller: _controllerX,
                            scrollDirection: Axis.horizontal,
                            child: buildPlaid(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(width: _titleWidth, height: _titleHeight),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                ),
                onPanUpdate: (DragUpdateDetails data) {
                  _controllerX.jumpTo(_controllerX.offset + (data.delta.dx * -1));
                  _controllerX_title.jumpTo(_controllerX_title.offset + (data.delta.dx * -1));
                  _controllerY.jumpTo(_controllerY.offset + (data.delta.dy * -1));
                  _controllerY_title.jumpTo(_controllerY_title.offset + (data.delta.dy * -1));
                },
              ),
            ],
          ),
        ),
      )
    );
  }
  Widget buildPlaid() {
    var list1 = List.generate(60, (index){return index;});
    var list2 = List.generate(30, (index){return index;});
    return _generateRightHandSideColumnRow(list1, list2);
  }

  List<Widget> getDateTitle(double height, double width, DateTime start, DateTime end, isDark){

  List<String> weekdayJP = ["月", "火", "水", "木", "金", "土", "日"];
  Text         month, day, weekday;

  var columnNum = end.difference(start).inDays+1;

  List<Widget> titleList = [];
  
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
  return titleList;
}

  Widget _generateFirstColumnsRow(List<int> list){
    return Column(
      children: [
        for(int i = 0; i < list.length; i++)
        Container(
          width: _titleWidth,
          height: _cellHeight,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text("$i", style:  MyStyle.tableTitleStyle((isDark) ?Colors.white : Colors.black54)),
          )
        ),
      ],
    );
  }

  Widget _generateRightHandSideColumnRow(List<int> list_1, List<int> list_2) {
    return Column(
      children: [
        for(int i = 0; i < list_1.length; i++)
        Row(
          children: [
            for(int j = 0; j < list_2.length; j++)
            _cell(i, j)
          ],
        )
      ],
    );
  }

    Widget _cell(int row, int column) {
    return Container(width: _cellWidth, height: _cellHeight,
    decoration: BoxDecoration(
          border: Border(
            top:    row == 0 ? BorderSide(width: 2, color: Colors.grey) : BorderSide.none,
            bottom: BorderSide(width: 2, color: Colors.grey),
            left:   column == 0 ? BorderSide(width: 2, color: Colors.grey) : BorderSide.none,
            right:  BorderSide(width: 2, color: Colors.grey),
          ),
        )
    );
  }
}
