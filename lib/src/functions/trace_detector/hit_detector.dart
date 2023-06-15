import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shift/src/functions/font.dart';

/////////////////////////////////////////////////////////////////////////////////
// Matrix Class
/////////////////////////////////////////////////////////////////////////////////

class Matrix extends StatelessWidget {
  final Coordinate? selected;                  // selected point cordinate
  final Function(Coordinate?)? onChangeSelect; // chage select callback
  final bool enable;                           // true = matrx enable
  final Widget? background;
  final int columnCount;
  final int rowCount;

  const Matrix({ Key? key, this.selected, this.onChangeSelect, this.enable = true, this.background, this.columnCount = 5, this.rowCount = 5 }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height*0.6,

      child: Container(
        foregroundDecoration: enable ? null : BoxDecoration(
          color: Colors.grey.withOpacity(0.8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            background ?? Container(),
            GestureDetector(
              onPanDown: (detail) {
                _judgeHit(context, detail.globalPosition);
              },
              onPanStart: (detail) {
                _judgeHit(context, detail.globalPosition);
              },
              onPanUpdate: (detail) {
                _judgeHit(context, detail.globalPosition);
              },
              child: Container(
                decoration: const BoxDecoration(
                  // color: Colors.red
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Center(
                    child: Table(
                      children: [
                        for (var row = 0; row < rowCount; row++)
                          TableRow(
                            children: [
                              for (var column = 0; column < columnCount; column++)
                              _cell(row, column)
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Matrix Cell Class Instance
  Widget _cell(int row, int column) {
    
    final coordinate = Coordinate(column: column, row: row);
    
    // noticefy currennt cell diffarent from selected cell 
    void onSelected() {
      if (selected != coordinate) {
        onChangeSelect?.call(coordinate);
      }
    }

    if (!enable) {
      return MatrixCell(
        isSelected: false,
        coordinate: coordinate,
        onSelected: onSelected,
      );
    }

    if (selected != null && selected!.row == row && selected!.column == column) {
      return MatrixCell(
        isSelected: true,
        coordinate: coordinate,
        onSelected: onSelected,
      );
    } else {
      return MatrixCell(
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

class MatrixCell extends StatelessWidget {
  final Coordinate? coordinate;
  final bool isSelected; 
  final VoidCallback? onSelected;

  const MatrixCell({ Key? key, this.coordinate, this.isSelected = false, this.onSelected }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: HitTestDetector(
        onTouch: isSelected ? null : onSelected,
        child: _cell(isSelected),
      ),
    );
  }

  Widget _cell(bool isSelected) {
    if (isSelected) {
      return const _SelectedCell();
    } else {
      return const _DeselectedCell();
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////
// Unselected Cell
/////////////////////////////////////////////////////////////////////////////////

class _DeselectedCell extends StatelessWidget {
  const _DeselectedCell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        width:  13,
        height: 13,
        decoration: BoxDecoration(
          border: Border.all(
            color: MyFont.hiddenColor
          ),
          color: MyFont.backgroundColor,
          borderRadius: BorderRadius.circular(3.0)
        ),
      )
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////
// Selected Cell Class
/////////////////////////////////////////////////////////////////////////////////

class _SelectedCell extends StatelessWidget {
  const _SelectedCell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        width:  13,
        height: 13,
        decoration: BoxDecoration(
          border: Border.all(
            color: MyFont.hiddenColor
          ),
          color: MyFont.primaryColor,
          borderRadius: BorderRadius.circular(3.0)
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