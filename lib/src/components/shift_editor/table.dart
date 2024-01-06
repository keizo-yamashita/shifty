import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shift/src/components/shift_editor/two_dimention_grid_view.dart';
import 'package:shift/src/components/shift_editor/coordinate.dart';
import 'package:shift/src/components/shift_editor/linkled_scroll.dart';

class TableEditor extends StatefulWidget {
  // key : テーブルを拡大縮小させたタイミングで更新する必要あり
  final GlobalKey editorKey;
  // タイトルセル, セル, テーブル のサイズ
  final double tableWidth;
  final double tableHeight;
  final double cellWidth;
  final double cellHeight;
  final double titleWidth;
  final double titleHeight;
  final double titleMargin;
  // 選択中のセルの座標
  final Coordinate? selected;
  // 選択中のセルが変わった時のコールバック
  final Function(Coordinate?)? onChangeSelect;
  // 手書き入力
  final bool enableEdit; // true = edit enable
  final Function? onInputEnd; // notifiy input end for create input buffer
  // ダークモード
  final bool isDark;
  // テーブルの構成要素 (縦横の要素数を一致させることに注意)
  final List<Widget> columnTitles;
  final List<Widget> rowTitles;
  final List<List<Widget?>> cells;

  const TableEditor({
    super.key,
    required this.editorKey,
    required this.tableWidth,
    required this.tableHeight,
    required this.cellWidth,
    required this.cellHeight,
    required this.titleWidth,
    required this.titleHeight,
    required this.titleMargin,
    required this.selected, // selected point cordinate
    required this.onChangeSelect, // chage select callback
    this.onInputEnd, // notifiy input end for create input buffer
    required this.enableEdit, // true = edit enable
    required this.isDark,
    required this.columnTitles,
    required this.rowTitles,
    required this.cells,
  });

  @override
  State<TableEditor> createState() => TableEditorState();
}

class TableEditorState extends State<TableEditor> {
  late LinkedScrollControllerGroup horizontalScrollGroup;
  late LinkedScrollControllerGroup verticalScrollGroup;
  late ScrollController controllerHorizontal_0;
  late ScrollController controllerHorizontal_1;
  late ScrollController controllerVertical_0;
  late ScrollController controllerVertical_1;

  var scrollEnableMain = true;
  var scrollEnableTitle = false;

  @override
  void initState() {
    horizontalScrollGroup = LinkedScrollControllerGroup();
    verticalScrollGroup = LinkedScrollControllerGroup();
    controllerHorizontal_0 = horizontalScrollGroup.addAndGet();
    controllerHorizontal_1 = horizontalScrollGroup.addAndGet();
    controllerVertical_0 = verticalScrollGroup.addAndGet();
    controllerVertical_1 = verticalScrollGroup.addAndGet();
    super.initState();
  }

  @override
  void dispose() {
    controllerHorizontal_0.dispose();
    controllerHorizontal_1.dispose();
    controllerVertical_0.dispose();
    controllerVertical_1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int rowLength = widget.rowTitles.length;
    int columnLength = widget.columnTitles.length;

    var cells = List<List<Widget>>.generate(
      rowLength,
      (i) {
        return List.generate(
          columnLength,
          (j) {
            return Padding(
              padding: EdgeInsets.only(
                top: (i == 0) ? widget.titleMargin : 0,
                right: (j == rowLength) ? widget.titleMargin : 0,
                left: (j == 0) ? widget.titleMargin : 0,
                bottom: (i == columnLength) ? widget.titleMargin : 0,
              ),
              child: cellWithHitDetector(i, j, true),
            );
          },
        );
      },
    );

    return SizedBox(
      width: widget.tableWidth,
      height: widget.tableHeight,
      child: Stack(
        children: [
          SizedBox(
            width: widget.titleWidth,
            height: widget.titleHeight,
          ),
          Column(
            children: [
              Row(
                children: [
                  // 左上の余白
                  SizedBox(
                    width: widget.titleWidth,
                    height: widget.titleHeight,
                  ),
                  // カラムタイトル (日付)
                  SizedBox(
                    height: widget.titleHeight,
                    width: widget.tableWidth - widget.titleWidth,
                    child: SingleChildScrollView(
                      controller: controllerHorizontal_1,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(width: widget.titleMargin),
                          for (int i = 0; i < widget.columnTitles.length; i++)
                            widget.columnTitles[i],
                          SizedBox(width: widget.titleMargin),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  // ロウタイトル (時間区分)
                  SizedBox(
                    height: widget.tableHeight - widget.titleHeight,
                    width: widget.titleWidth,
                    child: SingleChildScrollView(
                      controller: controllerVertical_1,
                      child: Column(
                        children: [
                          SizedBox(height: widget.titleMargin),
                          for (int i = 0; i < widget.rowTitles.length; i++)
                            widget.rowTitles[i],
                          SizedBox(height: widget.titleMargin),
                        ],
                      ),
                    ),
                  ),
                  // メインコンテンツ
                  SizedBox(
                    width: widget.tableWidth - widget.titleWidth,
                    height: widget.tableHeight - widget.titleHeight,
                    child: GestureDetector(
                      onPanDown: (detail) {
                        if (widget.enableEdit) {
                          _judgeHit(context, detail.globalPosition);
                        }
                      },
                      onPanStart: (detail) {
                        if (widget.enableEdit) {
                          _judgeHit(context, detail.globalPosition);
                        }
                      },
                      onPanUpdate: (detail) {
                        if (widget.enableEdit) {
                          _judgeHit(context, detail.globalPosition);
                        }
                      },
                      onPanEnd: (details) {
                        if (widget.enableEdit) {
                          widget.onInputEnd?.call();
                        }
                      },
                      onTapDown: (details) {
                        _judgeHit(context, details.globalPosition);
                      },
                      onTap: () {
                        if (widget.enableEdit) {
                          widget.onInputEnd?.call();
                        }
                      },
                      child: TwoDimensionalGridView(
                        key: widget.editorKey,
                        firstColumnWidth: widget.cellWidth + widget.titleMargin,
                        otherColumnWidth: widget.cellWidth,
                        firstRowHeight: widget.cellHeight + widget.titleMargin,
                        otherRowHeight: widget.cellHeight,
                        diagonalDragBehavior: DiagonalDragBehavior.free,
                        horizontalDetails: ScrollableDetails.horizontal(
                          controller: controllerHorizontal_0,
                          physics: !widget.enableEdit
                              ? null
                              : const NeverScrollableScrollPhysics(),
                        ),
                        verticalDetails: ScrollableDetails.vertical(
                          controller: controllerVertical_0,
                          physics: !widget.enableEdit
                              ? null
                              : const NeverScrollableScrollPhysics(),
                        ),
                        delegate: TwoDimensionalChildBuilderDelegate(
                          maxXIndex: cells[0].length - 1,
                          maxYIndex: cells.length - 1,
                          builder: (BuildContext _, ChildVicinity vicinity) {
                            return cells[vicinity.yIndex][vicinity.xIndex];
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: widget.titleHeight, width: widget.titleWidth + 2)
        ],
      ),
    );
  }

  // judge this cell is onTaped
  void _judgeHit(BuildContext context, Offset globalPosition) {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final result = BoxHitTestResult();

    var local = box.globalToLocal(globalPosition);

    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is HitTestDetectorRenderBox) {
          target.onHit!.call();
        }
      }
    }
  }

  ///////////////////////////////////////////////////////////////////////
  /// テーブルの要素を作るための関数
  //////////////////////////////////////////////////////////////////////

  // Matrix Cell Class Instance
  Widget cellWithHitDetector(int row, int column, bool editable) {
    final coordinate = Coordinate(column: column, row: row);

    void onSelected() {
      if (editable) {
        widget.onChangeSelect?.call(coordinate);
      }
    }

    widget.cells[row][column];

    return HitDetector(onTouch: onSelected, child: widget.cells[row][column]);
  }
}

/////////////////////////////////////////////////////////////////////////////////
// HitTest Detector Class
/////////////////////////////////////////////////////////////////////////////////

class HitDetector extends SingleChildRenderObjectWidget {
  final VoidCallback? onTouch;

  const HitDetector({
    Key? key,
    Widget? child,
    this.onTouch,
  }) : super(key: key, child: child);

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
