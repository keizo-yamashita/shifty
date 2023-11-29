////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:shift/src/mylibs/pop_icons.dart';

import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/shift/shift_request.dart';
import 'package:shift/src/mylibs/shift_editor/coordinate.dart';
import 'package:shift/src/mylibs/shift_editor/table_title.dart';

/////////////////////////////////////////////////////////////////////////////////
// Matrix Class
/////////////////////////////////////////////////////////////////////////////////

class ShiftRequestEditor extends StatelessWidget {
  final double                 sheetWidth;
  final double                 sheetHeight;
  final double                 cellWidth;
  final double                 cellHeight;
  final double                 titleWidth;
  final double                 titleHeight;
  final ShiftRequest           shiftRequest;
  final Coordinate?            selected;       // selected point cordinate
  final Function(Coordinate?)? onChangeSelect; // chage select callback
  final Function?              onInputEnd;     // notifiy input end for create input buffer
  final bool                   enableEdit;     // true = edit enable
  final bool                   isDark;

  const ShiftRequestEditor({
    Key? key,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.cellWidth,
    required this.cellHeight,
    required this.titleWidth,
    required this.titleHeight,
    required this.shiftRequest,
    this.selected,
    this.onChangeSelect,
    this.onInputEnd,
    this.enableEdit = false,
    this.isDark = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return AspectRatio(
      aspectRatio: sheetWidth/sheetHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onPanDown: (detail) {
              if(enableEdit){
                _judgeHit(context, detail.globalPosition);
              }
            },
            onPanStart: (detail) {
              if(enableEdit){
                _judgeHit(context, detail.globalPosition);
              }
            },
            onPanUpdate: (detail) {
              if(enableEdit){
                _judgeHit(context, detail.globalPosition);
              }
            },
            onPanEnd: (details) {
              if(enableEdit){
                onInputEnd?.call();
              }
            },
            onTapDown: (details){
              _judgeHit(context, details.globalPosition);
            },
            onTap: (){
              if(enableEdit){
                onInputEnd?.call();
              }
            }, 
            child: Container(
              color: Colors.transparent,
              child: Padding(
              padding: const EdgeInsets.only(right: 3, left: 3),
                child: HorizontalDataTable(
                  leftHandSideColBackgroundColor: Colors.transparent,
                  rightHandSideColBackgroundColor: Colors.transparent,
                  elevationColor: Colors.transparent,
                  leftHandSideColumnWidth: titleWidth,
                  rightHandSideColumnWidth: (shiftRequest.shiftFrame.shiftDateRange[0].end.difference(shiftRequest.shiftFrame.shiftDateRange[0].start).inDays+1) * cellWidth,
                  isFixedHeader: true,
                  headerWidgets: getColumnTitles(titleHeight, cellWidth, shiftRequest.shiftFrame.shiftDateRange[0].start, shiftRequest.shiftFrame.shiftDateRange[0].end, isDark),
                  leftSideItemBuilder: _generateFirstColumnsRow,
                  rightSideItemBuilder: _generateRightHandSideColumnRow,
                  itemCount: shiftRequest.shiftFrame.timeDivs.length,
                  verticalScrollbarStyle: const ScrollbarStyle(
                    isAlwaysShown: false,
                    thickness: 0.0,
                  ),
                  horizontalScrollbarStyle: const ScrollbarStyle(
                    isAlwaysShown: false,
                    thickness: 0.0,
                  ),
                  scrollPhysics : (!enableEdit) ? null : const NeverScrollableScrollPhysics(),
                  horizontalScrollPhysics: (!enableEdit) ? null : const NeverScrollableScrollPhysics()
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _generateFirstColumnsRow(BuildContext context, int index){
    return Container(
      width: titleWidth,
      height: cellHeight,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(shiftRequest.shiftFrame.timeDivs[index].name, style:  MyStyle.tableTitleStyle((isDark) ?Colors.white : Colors.black54)),
      )
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: shiftRequest.shiftFrame.assignTable[index].asMap().entries.map<Widget>(
        (list) => Container(
          width: cellWidth,
          height: cellHeight,
          alignment: Alignment.center,
          child: _cell(index, list.key, shiftRequest.shiftFrame.assignTable[index][list.key] != 0)
        )
      ).toList()
    );
  }

  // Matrix Cell Class Instance
  Widget _cell(int row, int column, bool editable) {

    final coordinate = Coordinate(column: column, row: row);
    
    void onSelected() {
      if (selected != coordinate) {
        onChangeSelect?.call(coordinate);
      }
    }
    
    var value = editable ? shiftRequest.requestTable[row][column] : 0;
    Icon cellValue;
    Color cellColor;

    if(value == 1){ 
      cellValue = Icon(PopIcons.circle_empty, size: 12 * cellWidth / 20, color: MyStyle.primaryColor);
      cellColor = MyStyle.primaryColor;
    }else{
      cellValue = Icon(PopIcons.cancel, size: 12 * cellWidth / 20, color: Colors.red);
      cellColor = Colors.red;
    }

    cellColor =  (selected?.column == coordinate.column && selected?.row == coordinate.row) ? cellColor.withAlpha(100) : Colors.transparent;
    var cellBoaderWdth = 1.0;

    return HitTestDetector(
      onTouch: (editable) ? onSelected : null,
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