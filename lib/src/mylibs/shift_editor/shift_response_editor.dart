////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shift/src/mylibs/pop_icons.dart';

import 'package:shift/src/mylibs/style.dart';
import 'package:shift/src/mylibs/shift/shift_request.dart';
import 'package:shift/src/mylibs/shift_editor/coordinate.dart';
import 'package:shift/src/mylibs/shift_editor/table_title.dart';
import 'package:shift/src/mylibs/shift_editor/table.dart';


/////////////////////////////////////////////////////////////////////////////////
// Matrix Class
/////////////////////////////////////////////////////////////////////////////////

class ShiftResponseEditor extends StatelessWidget {
  final double                 sheetWidth;
  final double                 sheetHeight;
  final double                 cellWidth;
  final double                 cellHeight;
  final double                 titleWidth;
  final double                 titleHeight;
  final double                 titleMargin;
  final ShiftRequest           shiftRequest;
  final Coordinate?            selected;       // selected point cordinate
  final Function(Coordinate?)? onChangeSelect; // chage select callback
  final Function?              onInputEnd;     // notifiy input end for create input buffer
  final bool                   enableEdit;     // true = edit enable
  final bool                   isDark;
  final ScrollController       controllerHorizontal_0;
  final ScrollController       controllerHorizontal_1;
  final ScrollController       controllerVertical_0;
  final ScrollController       controllerVertical_1;

  const ShiftResponseEditor({
    Key? key,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.cellWidth,
    required this.cellHeight,
    required this.titleWidth,
    required this.titleHeight,
    required this.titleMargin,
    required this.shiftRequest,
    required this.controllerHorizontal_0,
    required this.controllerHorizontal_1,
    required this.controllerVertical_0,
    required this.controllerVertical_1,
    this.selected,
    this.onChangeSelect,
    this.onInputEnd,
    this.enableEdit = false,
    this.isDark = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    int rowLength    = shiftRequest.shiftFrame.shiftDateRange[0].end.difference(shiftRequest.shiftFrame.shiftDateRange[0].start).inDays + 1;
    int columnLength = shiftRequest.shiftFrame.timeDivs.length;

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
            // child: Container(
            //   color: Colors.transparent,
            //   child: TableEditor(
            //     key: UniqueKey(),
            //     tableWidth:  sheetWidth,
            //     tableHeight: sheetHeight,
            //     titleWidth:  titleWidth,
            //     titleHeight: titleHeight,
            //     cellWidth:   cellWidth,
            //     cellHeight:  cellHeight,
            //     titleMargin: titleMargin,
            //     controllerHorizontal_0: controllerHorizontal_0,
            //     controllerHorizontal_1: controllerHorizontal_1,
            //     controllerVertical_0: controllerVertical_0,
            //     controllerVertical_1: controllerVertical_1,
            //     selected: selected,
            //     onChangeSelect:  onChangeSelect,
            //     onInputEnd:  onInputEnd,
            //     enableEdit: enableEdit,
            //     isDark: isDark,
            //     columnTitles: getColumnTitles(titleHeight, cellWidth, shiftRequest.shiftFrame.shiftDateRange[0].start, shiftRequest.shiftFrame.shiftDateRange[0].end, isDark),
            //     rowTitles: getRowTitles(cellHeight, titleWidth, shiftRequest.shiftFrame.timeDivs, isDark),
            //     cells: List<List<Widget>>.generate(
            //       columnLength, 
            //       (i){
            //         return List.generate(
            //           rowLength,
            //           (j){
            //             return Padding(
            //               padding: EdgeInsets.only(top: (i == 0) ? 10 : 0, right: (j == rowLength) ? 10 : 0, left: (j == 0) ? 10 : 0, bottom: (i == columnLength) ? 10 : 0),
            //               child: _cell(i, j, shiftRequest.shiftFrame.assignTable[i][j] != 0)
            //             );
            //           }
            //         );
            //       },
            //     ),
            //   ),
            // ),
          ),
        ],
      )
    );
  }

  ///////////////////////////////////////////////////////////////////////
  /// テーブルの要素を作るための関数
  ///////////////////////////////////////////////////////////////////////

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
      cellValue = Icon((shiftRequest.responseTable[row][column] == 1) ? PopIcons.circle : PopIcons.circle_empty, size: 12 * cellWidth / 20, color: MyStyle.primaryColor);
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
        width: cellWidth,
        height: cellHeight,
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
          ? Center(child: SizedBox(width: cellWidth, height: cellHeight,child: cellValue))
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
