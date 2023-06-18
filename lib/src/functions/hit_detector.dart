import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';
import 'package:shift/src/functions/font.dart';

/////////////////////////////////////////////////////////////////////////////////
// Matrix Class
/////////////////////////////////////////////////////////////////////////////////

class ColoringSheet extends StatelessWidget {
  final double sheetWidth;
  final double sheetHeight;
  final List<Widget> tableColumnTitle;
  final List<Widget> tableRowTitle;
  final List<List<int>> tableCell;
  final List<Color> colorTable;
  final Coordinate? selected;                  // selected point cordinate
  final Function(Coordinate?)? onChangeSelect; // chage select callback
  final Function?              onInputEnd;     // notifiy input end for create input buffer
  final Function(double?)?     onSwipeRight;   // swipe right
  final Function(double?)?     onSwipeLeft;    // swipe left
  final Function(double?)?     onSwipeUp;      // swipe up
  final Function(double?)?     onSwipeBottom;  // swipe bottom
  final Function(double?)?     onPinch;        // pinch
  final bool enableEdit;                       // true = matrx enable
  final bool enablePinch;
  final Widget? background;
  final int columnFirstIndex;
  final int rowFirstIndex;
  final int columnCount;
  final int rowCount;

  const ColoringSheet({
    Key? key,
    required this.sheetWidth,
    required this.sheetHeight,
    required this.tableColumnTitle,
    required this.tableRowTitle,
    required this.tableCell,
    required this.colorTable,
    this.selected,
    this.onChangeSelect,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.onSwipeUp,
    this.onSwipeBottom,
    this.onPinch,
    this.onInputEnd,
    this.enableEdit = true,
    this.enablePinch = false,
    this.background,
    this.columnFirstIndex=0,
    this.rowFirstIndex=0,
    this.columnCount = 5,
    this.rowCount = 5
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    double tableScale = 1.0;

    return AspectRatio(
      aspectRatio: 23/32,
      child: Stack(
        fit: StackFit.expand,
        children: [
          background ?? Container(),
          GestureDetector(
            onPanDown: (enablePinch) ? null : (detail) {
              if(enableEdit){
                _judgeHit(context, detail.globalPosition);
              }
            },
            onPanStart: (enablePinch) ? null : (detail) {
              if(enableEdit){
                _judgeHit(context, detail.globalPosition);
              }
            },
            onPanUpdate: (enablePinch) ? null : (detail) {
              if(enableEdit){
                _judgeHit(context, detail.globalPosition);
              }else{
                if (detail.delta.dx > 7) {
                  onSwipeLeft?.call(detail.delta.dx);
                } else if (detail.delta.dx < -7) {
                  onSwipeRight?.call(detail.delta.dx);
                }
                if (detail.delta.dy > 7) {
                  onSwipeUp?.call(detail.delta.dy);
                } else if (detail.delta.dy < -7) {
                  onSwipeBottom?.call(detail.delta.dy);
                }
              }
            },
            onPanEnd: (enablePinch) ? null : (details) {
              if(enableEdit){
                onInputEnd?.call();
              }
            },
            
            onScaleUpdate: (!enablePinch) ? null : (ScaleUpdateDetails data) {
              if(data.scale != 1.0){
                print(tableScale);
                tableScale = data.scale;
              }
            },
            onScaleEnd: (!enablePinch) ? null : (ScaleEndDetails data) {
              if(tableScale != 1.0){
                print("end ${tableScale}");
                onPinch?.call(tableScale);
                tableScale = 1.0;
              }
            },

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const <int, TableColumnWidth>{
                  0: IntrinsicColumnWidth()
                },
                children: [
                  TableRow(
                    children: [
                      Container(),
                      for (var column = columnFirstIndex; column < columnFirstIndex + columnCount; column++)
                        (column < tableColumnTitle.length)
                        ? tableColumnTitle[column]
                        : Column(
                          children: [
                            Text("-", style: MyFont.tableTitleStyle(Colors.black), textAlign: TextAlign.center, textHeightBehavior: MyFont.defaultBehavior),
                            Text("-", style: MyFont.tableTitleStyle(Colors.black), textAlign: TextAlign.center, textHeightBehavior: MyFont.defaultBehavior),
                          ],
                        ),
                    ],
                  ),
                  for (var row = rowFirstIndex; row < rowFirstIndex + rowCount; row++)
                  (row < tableRowTitle.length)
                  ? TableRow(
                    children: [
                      tableRowTitle[row],
                      for (var column = columnFirstIndex; column < columnFirstIndex + columnCount; column++)
                        ( column < tableColumnTitle.length)
                        ? _cell(row, column, colorTable[tableCell[row][column]], true)
                        : _cell(row, column, MyFont.hiddenColor, false)
                    ],
                  )
                  : TableRow(
                    children: [
                      Text("- - -", style: MyFont.tableTitleStyle(Colors.black), textAlign: TextAlign.center, textHeightBehavior: MyFont.defaultBehavior),
                      for (var column = columnFirstIndex; column < columnFirstIndex + columnCount; column++)
                      _cell(row, column, MyFont.hiddenColor, false)
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Matrix Cell Class Instance
  Widget _cell(int row, int column, Color color, bool editable) {

    final coordinate = Coordinate(column: column, row: row);
    
    // noticefy currennt cell diffarent from selected cell 
    void onSelected() {
      if (selected != coordinate) {
        onChangeSelect?.call(coordinate);
      }
    }

    if(!editable){
      return SheetCell(
        color: Colors.grey[300],
        isSelected: false,
        coordinate: coordinate,
        onSelected: (){},
      );
    }

    if (!enableEdit) {
      return SheetCell(
        color: color,
        isSelected: false,
        coordinate: coordinate,
        onSelected: onSelected,
      );
    }

    if (selected != null && selected!.row == row && selected!.column == column) {
      return SheetCell(
        color: color,
        isSelected: true,
        coordinate: coordinate,
        onSelected: onSelected,
      );
    } else {
      return SheetCell(
        color: color,
        isSelected: false,
        coordinate: coordinate,
        onSelected: onSelected,
      );
    }
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
// Matrix Cell Class
/////////////////////////////////////////////////////////////////////////////////

class SheetCell extends StatelessWidget {
  final Color? color;
  final Coordinate? coordinate;
  final bool isSelected; 
  final VoidCallback? onSelected;

  const SheetCell({
    Key? key,
    this.color,
    this.coordinate,
    this.isSelected = false,
    this.onSelected
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: HitTestDetector(
        onTouch: isSelected ? null : onSelected,
        child: _cell(isSelected, color),
      ),
    );
  }

  Widget _cell(bool isSelected, Color? color) {
    if (isSelected) {
      return _SelectedCell(color: color);
    } else {
      return _DeselectedCell(color: color);
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////
// Unselected Cell
/////////////////////////////////////////////////////////////////////////////////

class _DeselectedCell extends StatelessWidget {

  final Color? color;

  _DeselectedCell({
    Key? key,
    this.color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey
          ),
          color: color,
          borderRadius: BorderRadius.circular(2.0)
        ),
      )
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////
// Selected Cell Class
/////////////////////////////////////////////////////////////////////////////////

class _SelectedCell extends StatelessWidget {
  final Color? color;

  _SelectedCell({
    Key? key,
    this.color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey
          ),
          color: color,
          borderRadius: BorderRadius.circular(2.0)
        ),
      )
    );
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