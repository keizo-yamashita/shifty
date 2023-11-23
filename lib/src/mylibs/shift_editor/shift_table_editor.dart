////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/shift/shift_table.dart';
import 'package:shift/src/mylibs/shift_editor/coordinate.dart';

/////////////////////////////////////////////////////////////////////////////////
// Matrix Class
/////////////////////////////////////////////////////////////////////////////////

class ShiftTableEditor extends StatelessWidget {
  final double                 sheetWidth;
  final double                 sheetHeight;
  final double                 cellWidth;
  final double                 cellHeight;
  final double                 titleWidth;
  final double                 titleHeight;
  final ShiftTable             shiftTable;
  final Coordinate?            selected;       // selected point cordinate
  final Function(Coordinate?)? onChangeSelect; // chage select callback
  final Function?              onInputEnd;     // notifiy input end for create input buffer
  final bool                   enableEdit;     // true = edit enable
  final bool                   isDark;

  const ShiftTableEditor({
    Key? key,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.cellWidth,
    required this.cellHeight,
    required this.titleWidth,
    required this.titleHeight,
    required this.shiftTable,
    this.selected,
    this.onChangeSelect,
    this.onInputEnd,
    this.enableEdit = false,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AspectRatio(
      aspectRatio: sheetWidth/sheetHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTapDown: (details){
              if(enableEdit){
                _judgeHit(context, details.globalPosition);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 3, left: 3),
              child: HorizontalDataTable(
                leftHandSideColBackgroundColor: Colors.transparent,
                rightHandSideColBackgroundColor: Colors.transparent,
                elevationColor: Colors.transparent,
                leftHandSideColumnWidth: titleWidth,
                rightHandSideColumnWidth: (shiftTable.shiftFrame.shiftDateRange[0].end.difference(shiftTable.shiftFrame.shiftDateRange[0].start).inDays+1) * cellWidth,
                isFixedHeader: true,
                headerWidgets: _getTitleWidget(),
                leftSideItemBuilder: _generateFirstColumnsRow,
                rightSideItemBuilder: _generateRightHandSideColumnRow,
                itemCount: shiftTable.shiftFrame.timeDivs.length,
                verticalScrollbarStyle: const ScrollbarStyle(
                  isAlwaysShown: false,
                  thickness: 0.0,
                ),
                horizontalScrollbarStyle: const ScrollbarStyle(
                  isAlwaysShown: false,
                  thickness: 0.0,
                ),
                scrollPhysics : null,
                horizontalScrollPhysics: null,
              ),
            ),
          ),
        ],
      )
    );
  }

  ///////////////////////////////////////////////////////////////////////
  /// テーブルの要素を作るための関数
  ///////////////////////////////////////////////////////////////////////

  List<Widget> _getTitleWidget(){

    List<String> weekdayJP = ["月", "火", "水", "木", "金", "土", "日"];
    Text         day, weekday;

    var columnNum = shiftTable.shiftFrame.shiftDateRange[0].end.difference(shiftTable.shiftFrame.shiftDateRange[0].start).inDays+1;

    var titleList = [Container(
        width: titleWidth,
        height: titleHeight,
        alignment: Alignment.center,
        child: Text("", style: MyStyle.defaultStyleBlack10),
      )];

    for(int i = 0; i < columnNum; i++){
      DateTime     date = shiftTable.shiftFrame.shiftDateRange[0].start.add(Duration(days: i));

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
          width: cellWidth,
          height: titleHeight,
          padding: const EdgeInsets.symmetric(vertical: 2),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: (titleHeight-4)/2, child: FittedBox(fit: BoxFit.fitWidth, child: day)),
              SizedBox(height: (titleHeight-4)/2, child: FittedBox(fit: BoxFit.fitWidth ,child: weekday))
            ]
          )
        )
      );
    }
    return titleList;
  }
  Widget _generateFirstColumnsRow(BuildContext context, int index){
    return Container(
      width: titleWidth,
      height: cellHeight,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(shiftTable.shiftFrame.timeDivs[index].name, style:  MyStyle.tableTitleStyle((isDark) ?Colors.white : Colors.black54)),
      )
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: shiftTable.shiftFrame.assignTable[index].asMap().entries.map<Widget>(
        (list) => Container(
          width: cellWidth,
          height: cellHeight,
          alignment: Alignment.center,
          child: _cell(index, list.key, (shiftTable.shiftFrame.assignTable[index][list.key] != 0))
        )
      ).toList()
    );
  }

  // Matrix Cell Class Instance
  Widget _cell(int row, int column, bool editable) {

    final coordinate = Coordinate(column: column, row: row);
    
    void onSelected() {
      if(editable){
        onChangeSelect?.call(coordinate);
      }
    }
    
    int assignNum = 0;
    for(int i = 0; i < shiftTable.shiftTable[row][column].length; i++){
      if(shiftTable.shiftTable[row][column][i].assign){
        assignNum++;
      }
    }

    var value = (assignNum / shiftTable.shiftFrame.assignTable[row][column]);

    var cellValue = Icon(CupertinoIcons.hand_thumbsup, size: 14 * cellWidth / 20, color: MyStyle.primaryColor);
    if(value == 0){
      cellValue = Icon(CupertinoIcons.clear_thick, size: 14 * cellWidth / 20, color: Colors.red); 
    }
    else if(value < 0.3){
      cellValue = Icon(CupertinoIcons.clear_thick, size: 14 * cellWidth / 20, color: Colors.yellow[800]); 
    }
    else if(value < 0.7){
      cellValue = Icon(CupertinoIcons.exclamationmark, size: 14 * cellWidth / 20, color: Colors.red);
    }
    else if(value < 1.0){
      cellValue = Icon(CupertinoIcons.exclamationmark, size: 14 * cellWidth / 20, color: Colors.yellow[800]);
    }
    else if(value > 1.0){
      cellValue = Icon(CupertinoIcons.hand_thumbsup, size: 14 * cellWidth / 20, color: Colors.yellow[800]);
    }

    Color  cellColor = (selected?.column == coordinate.column && selected?.row == coordinate.row) ? MyStyle.primaryColor.withAlpha(100) : Colors.transparent;
    var cellBoaderWdth = 1.0;

    return HitTestDetector(
      onTouch: onSelected,
      child:  Container(
        decoration: BoxDecoration(
          border: Border(
            top:    row == 0 ? BorderSide(width: cellBoaderWdth, color: Colors.grey) : BorderSide.none,
            bottom: BorderSide(width: cellBoaderWdth, color: Colors.grey),
            left:   column == 0 ? BorderSide(width: cellBoaderWdth, color: Colors.grey) : BorderSide.none,
            right:  BorderSide(width: cellBoaderWdth, color: Colors.grey),
          ),
          color: cellColor
        ),
        child: editable
          ? Center(child: cellValue)
          : SizedBox(width: cellWidth, height: cellHeight, child: CustomPaint(painter: DiagonalLinePainter(Colors.grey)))
      ),
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
// DiagonalLinePainter Class
// ... 斜線をセルに引くためのクラス
/////////////////////////////////////////////////////////////////////////////////

class DiagonalLinePainter extends CustomPainter {
  
  Color color;

  DiagonalLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.4;

    // 左下から右上に斜線を描く
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // ここでは常に再描画するようにしていますが、パフォーマンスの観点から、
    // 描画に影響するプロパティが変更された場合のみtrueを返すようにすると良いでしょう。
    return false;
  }
}