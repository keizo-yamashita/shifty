import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shift/src/functions/font.dart';
import 'package:provider/provider.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:shift/src/functions/shift_table_provider.dart';

const double _tableHeight      = 20;
const double _tableWidth       = 20;
const double _tableTitleHeight = 40;
const double _tableTitleWidth  = 60;

class Test extends StatefulWidget {

  const Test({Key? key}) : super(key: key);
   
  @override
  TestState createState() => TestState();
}

class TestState extends State<Test> {
  
  // ignore: unused_field
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController;

  ShiftTable _shiftTable = ShiftTable();
  @override
  Widget build(BuildContext context) {

    var screenSize = MediaQuery.of(context).size;

    _shiftTable = Provider.of<InputShiftRequestProvider>(context, listen: false).shiftTable;
    print("test");
    return Scaffold(   
      
      appBar: AppBar(
        title: Text(_shiftTable.tableName,style: MyFont.headlineStyleGreen20),
        backgroundColor: MyFont.backgroundColor.withOpacity(0.9),
        foregroundColor: MyFont.primaryColor,
        bottomOpacity: 2.0,
        elevation: 2.0,
      ),

      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.height/30),
            
              ////////////////////////////////////////////////////////////////////////////////////////////
              /// ツールボタン
              ////////////////////////////////////////////////////////////////////////////////////////////
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildIconButton( Icons.pinch, true, (){}, (){}),
                  buildIconButton( Icons.draw_rounded, true, (){}, (){}),
                  buildIconButton( Icons.hdr_auto_outlined, true, (){}, (){}),
                  buildIconButton( Icons.undo,  true, (){}, (){}),
                  buildIconButton( Icons.redo,  true, (){}, (){}),
                  buildIconButton( Icons.check, true, (){}, (){}),
                ],
              ),
              AspectRatio(
                aspectRatio: 24/32,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onPanDown:(detail) {
                        print("onPanDown");
                      },
                      onPanStart:(detail) {
                        print("onPanStart");
                      },
                      onPanUpdate: (detail) {
                        print("onPanUpdate");
                      },
                      onPanEnd: (details) {
                        print("onPanEnd");
                      },
                      child: createShiftTemplate()
                    )
                  ],
                )
              )
            ]
          )
        )
      )
    );
  }

  ///////////////////////////////////////////////////////////////////////
  /// テーブルの要素を作るための関数
  ///////////////////////////////////////////////////////////////////////

  List<Widget> _getTitleWidget(){

    List<String> weekdayJP = ["月", "火", "水", "木", "金", "土", "日"];
    Text         day, weekday;

    var columnNum = _shiftTable.shiftDateRange[0].end.difference(_shiftTable.shiftDateRange[0].start).inDays+1;

    var titleList = [Container(
        width: _tableTitleWidth,
        height: _tableTitleHeight,
        alignment: Alignment.center,
        child: Text("", style: MyFont.defaultStyleBlack10),
      )];

    for(int i = 0; i < columnNum; i++){
      DateTime     date = _shiftTable.shiftDateRange[0].start.add(Duration(days: i));

      if(date.weekday == 6){
        day     = Text('${date.day}', style: MyFont.tableTitleStyle(Colors.blue)); 
        weekday = Text(weekdayJP[date.weekday - 1], style: MyFont.tableTitleStyle(Colors.blue));
      }else if(date.weekday == 7){
        day     = Text('${date.day}', style: MyFont.tableTitleStyle(Colors.red)); 
        weekday = Text(weekdayJP[date.weekday - 1], style: MyFont.tableTitleStyle(Colors.red));
      }else{
        day     = Text('${date.day}', style: MyFont.tableTitleStyle(Colors.black)); 
        weekday = Text(weekdayJP[date.weekday - 1], style: MyFont.tableTitleStyle(Colors.black));
      }
      titleList.add(
        Container(
          width: _tableWidth,
          height: _tableTitleHeight,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              day,
              weekday
            ]
          )
        )
      );
    }

    return titleList;
  }

  Widget _generateFirstColumnsRow(BuildContext context, int index){
    return Container(
      width: _tableTitleWidth,
      height: _tableHeight,
      alignment: Alignment.center,
      child: Text(_shiftTable.timeDivs[index].name, style: MyFont.defaultStyleBlack10),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {

    return Row(
      children: _shiftTable.assignTable[index].asMap().entries.map<Widget>(
        (list) => Container(
          width: _tableWidth,
          height: _tableHeight,
          alignment: Alignment.center,
          child: _cell(index, list.key, true)
        )
      ).toList()
    );
  }

  Widget createShiftTemplate(){
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.only(top: 9, right: 15, left: 15, bottom: 0),
        child: SizedBox(
          child: HorizontalDataTable(
            leftHandSideColumnWidth: _tableTitleWidth,
            rightHandSideColumnWidth: (_shiftTable.shiftDateRange[0].end.difference(_shiftTable.shiftDateRange[0].start).inDays+1) * _tableWidth,
            isFixedHeader: true,
            headerWidgets: _getTitleWidget(),
            leftSideItemBuilder: _generateFirstColumnsRow,
            rightSideItemBuilder: _generateRightHandSideColumnRow,
            itemCount: _shiftTable.timeDivs.length,
            onScrollControllerReady: (vertical, horizontal) {
              _verticalScrollController = vertical;
              _horizontalScrollController = horizontal;
            },
            verticalScrollbarStyle: ScrollbarStyle(
              thumbColor: Colors.green[200],
              isAlwaysShown: false,
              thickness: 0.0,
              radius: const Radius.circular(5.0),
            ),
            horizontalScrollbarStyle: ScrollbarStyle(
              thumbColor: Colors.green[200],
              isAlwaysShown: false,
              thickness: 0.0,
              radius: const Radius.circular(5.0),
            ),
            scrollPhysics : NeverScrollableScrollPhysics(),
            horizontalScrollPhysics: NeverScrollableScrollPhysics()
          ),
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  ///  ページ上部のツールボタン作成に使用 (onPress OnLongPress 2つの関数を使用)
  ///  OnLongPress に 0.5 秒の検出時間がかかるので，GestureDetector で検出したほうがいいかも
  ////////////////////////////////////////////////////////////////////////////////////////////
  
  Widget buildIconButton(IconData icon, bool flag, Function onPressed, Function onLongPressed){
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: SizedBox(
        width: 50,
        height: 40,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: MyFont.backgroundColor,
            shadowColor: MyFont.hiddenColor, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: BorderSide(color: (flag) ? MyFont.primaryColor : MyFont.hiddenColor),
          ),
          onPressed: (){ 
            setState(() {
              onPressed();
            });
          },
          onLongPress: (){
            setState(() {
              onLongPressed();
            });
          },
          child: Icon(icon, color: (flag) ? MyFont.primaryColor : MyFont.hiddenColor, size: 20)
        ),
      ),
    );
  }

    // Matrix Cell Class Instance
  Widget _cell(int row, int column, bool editable) {

    final coordinate = Coordinate(column: column, row: row);
    
    void onSelected() {
      // if (selected != coordinate) {
      //   onChangeSelect?.call(coordinate);
      // }
    }
    
    var value = editable ? _shiftTable.assignTable[row][column] : 0;
    String cellValue;
    Color  cellColor;
    Color  cellFontColor;

    if(value.runtimeType == int){
      cellValue     = value.toString();
      cellColor     = colorTable[value][0];
      cellFontColor = colorTable[value][1];
    }else if(value.runtimeType == bool){
      if(value == true){ 
        cellValue = "OK";
        cellColor     = MyFont.primaryColor;
        cellFontColor = colorTable[8][1];
      }else{
        cellValue = "NG";
        cellColor     = colorTable[0][0];
        cellFontColor = colorTable[0][1];
      }
    }else{
      cellValue = '';
      cellColor     = Colors.black;
      cellFontColor = Colors.black;
    }

    return AspectRatio(
      aspectRatio: 1.0,
      child: HitTestDetector(
        onTouch: (editable) ? onSelected : null,
        child:  Padding(
          padding: const EdgeInsets.all(0.5),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all( color: Colors.grey),
              color: editable ? cellColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5)
            ),
            child: editable
              ? Center(child: Text(cellValue, style: TextStyle(color: cellFontColor, fontSize: 7), textHeightBehavior: MyFont.defaultBehavior, textAlign: TextAlign.center))
              : CustomPaint(painter: DiagonalLinePainter())
          )
        ),
      )
    );
  }

    // judge this cell is onTaped
  void _judgeHit(BuildContext context, Offset globalPosition) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final result = BoxHitTestResult();
    var local = box?.globalToLocal(globalPosition);

    if (box == null || local == null) {
      return;
    }

    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is HitTestDetectorRenderBox) {
          target.onHit?.call();
        }
      }
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////
// HitTest Detector Class
/////////////////////////////////////////////////////////////////////////////////

class HitTestDetector extends SingleChildRenderObjectWidget {

  final VoidCallback? onTouch;

  const HitTestDetector({Key? key, Widget? child, this.onTouch }) : super( key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return HitTestDetectorRenderBox()..onHit = onTouch;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant HitTestDetectorRenderBox renderObject,
  ) {
    super.updateRenderObject(context, renderObject);

    renderObject.onHit = onTouch;
  }
}

/////////////////////////////////////////////////////////////////////////////////
// HitTestDetectorRenderBox Class
/////////////////////////////////////////////////////////////////////////////////

class HitTestDetectorRenderBox extends RenderProxyBox {
  VoidCallback? onHit;
}

/////////////////////////////////////////////////////////////////////////////////
// Coordinate Class
/////////////////////////////////////////////////////////////////////////////////

class Coordinate {
  int column;
  int row;
  Coordinate({
    required this.column,
    required this.row,
  });
}

class DiagonalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    // 左下から右上に斜線を描く
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    // canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // ここでは常に再描画するようにしていますが、パフォーマンスの観点から、
    // 描画に影響するプロパティが変更された場合のみtrueを返すようにすると良いでしょう。
    return false;
  }
}