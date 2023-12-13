////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:shift/src/mylibs/pop_icons.dart';
import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/shift/shift_table.dart';
import 'package:shift/src/mylibs/shift_editor/coordinate.dart';
import 'package:shift/src/mylibs/shift_editor/table_title.dart';
import 'package:shift/src/mylibs/shift_editor/table.dart';

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
  final ScrollController       controllerHorizontal_0;
  final ScrollController       controllerHorizontal_1;
  final ScrollController       controllerVertical_0;
  final ScrollController       controllerVertical_1;

  const ShiftTableEditor({
    Key? key,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.cellWidth,
    required this.cellHeight,
    required this.titleWidth,
    required this.titleHeight,
    required this.shiftTable,
    required this.controllerHorizontal_0,
    required this.controllerHorizontal_1,
    required this.controllerVertical_0,
    required this.controllerVertical_1,
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
            child: TableEditor(
              key: UniqueKey(),
              tableWidth:  sheetWidth,
              tableHeight: sheetHeight,
              titleWidth:  titleWidth,
              titleHeight: titleHeight,
              cellWidth:   cellWidth,
              cellHeight:  cellHeight,
              controllerHorizontal_0: controllerHorizontal_0,
              controllerHorizontal_1: controllerHorizontal_1,
              controllerVertical_0: controllerVertical_0,
              controllerVertical_1: controllerVertical_1,
              selected: Coordinate(column: 0, row: 0),
              onChangeSelect:  (Coordinate? test){},
              onInputEnd:  (){},
              enableEdit: false,
              isDark: isDark,
              columnTitles: getColumnTitles(titleHeight, cellWidth, shiftTable.shiftFrame.shiftDateRange[0].start, shiftTable.shiftFrame.shiftDateRange[0].end, isDark),
              rowTitles: getRowTitles(cellHeight, titleWidth, shiftTable.shiftFrame.timeDivs, isDark),
              cells: List<List<Widget>>.generate(
                shiftTable.shiftFrame.timeDivs.length, 
                (i){
                  return List.generate(
                    shiftTable.shiftFrame.shiftDateRange[0].end.difference(shiftTable.shiftFrame.shiftDateRange[0].start).inDays+1,
                    (j){
                      return Padding(
                        padding: EdgeInsets.only(top: (i == 0) ? 10 : 0, right: (j == shiftTable.shiftFrame.shiftDateRange[0].end.difference(shiftTable.shiftFrame.shiftDateRange[0].start).inDays+1) ? 10 : 0, left: (j == 0) ? 10 : 0, bottom: (i == shiftTable.shiftFrame.timeDivs.length) ? 10 : 0),
                        child: _cell(i, j, false)
                      );
                    }
                  );
                },
              ),
            ),
          )
        ],
      )
    );
  }

  ///////////////////////////////////////////////////////////////////////
  /// テーブルの要素を作るための関数
  //////////////////////////////////////////////////////////////////////

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

    var cellValue = Icon(PopIcons.ok, size: 14 * cellWidth / 20, color: MyStyle.primaryColor);
    if(value == 0){
      cellValue = Icon(PopIcons.cancel, size: 14 * cellWidth / 20, color: Colors.red); 
    }
    else if(value < 0.3){
      cellValue = Icon(PopIcons.cancel, size: 14 * cellWidth / 20, color: Colors.yellow[800]); 
    }
    else if(value < 0.7){
      cellValue = Icon(PopIcons.attention_alt, size: 14 * cellWidth / 20, color: Colors.red);
    }
    else if(value < 1.0){
      cellValue = Icon(PopIcons.attention_alt, size: 14 * cellWidth / 20, color: Colors.yellow[800]);
    }
    else if(value > 1.0){
      cellValue = Icon(PopIcons.ok, size: 14 * cellWidth / 20, color: Colors.yellow[800]);
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
    // canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // ここでは常に再描画するようにしていますが、パフォーマンスの観点から、
    // 描画に影響するプロパティが変更された場合のみtrueを返すようにすると良いでしょう。
    return false;
  }
}