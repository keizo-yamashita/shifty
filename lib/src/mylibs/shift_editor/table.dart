import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shift/src/mylibs/shift_editor/two_dimention_grid_view.dart';
import 'package:shift/src/mylibs/shift_editor/coordinate.dart';

class TableEditor extends StatefulWidget {
  final double                      tableWidth;
  final double                      tableHeight;
  final double                      cellWidth;
  final double                      cellHeight;
  final double                      titleWidth;
  final double                      titleHeight;
  final Coordinate?                 selected;       // selected point cordinate
  final Function(Coordinate?)?      onChangeSelect; // chage select callback
  final Function?                   onInputEnd;     // notifiy input end for create input buffer
  final bool                        enableEdit;     // true = edit enable
  final bool                        isDark;
  final List<Widget>                columnTitles;
  final List<Widget>                rowTitles;
  final ScrollController            controllerHorizontal_0;
  final ScrollController            controllerHorizontal_1;
  final ScrollController            controllerVertical_0;
  final ScrollController            controllerVertical_1;
  
  const TableEditor({
    Key? key,
    required this.tableWidth,
    required this.tableHeight,
    required this.cellWidth,
    required this.cellHeight,
    required this.titleWidth,
    required this.titleHeight,
    required this.selected,       // selected point cordinate
    required this.onChangeSelect, // chage select callback
    required this.onInputEnd,     // notifiy input end for create input buffer
    required this.enableEdit,     // true = edit enable
    required this.isDark,
    required this.columnTitles,
    required this.rowTitles,
    required this.controllerHorizontal_0,
    required this.controllerHorizontal_1,
    required this.controllerVertical_0,
    required this.controllerVertical_1
  }) : super(key: key);

  @override
  State<TableEditor> createState() => _TableEditorState(); 
}

class _TableEditorState extends State<TableEditor> {

  var scrollEnableMain  = true;
  var scrollEnableTitle = false;

  @override
  Widget build(BuildContext context){
    
    final contents = getContents(List<int>.generate(60, (j) => j), List<int>.generate(30, (j) => j));
    
    return SizedBox(
      width: widget.tableWidth,
      height: widget.tableHeight,
      child: Stack(
        children: [
          SizedBox(width: widget.titleWidth, height: widget.titleHeight),
          Column(
            children: [
              Row(
                children: [
                  // 左上の余白
                  Container(width: widget.titleWidth, height: widget.titleHeight),
                  // カラムタイトル (日付)
                  Container(
                    // decoration: BoxDecoration(
                    //   color: widget.isDark ? Colors.black : Colors.white,
                    //   boxShadow: const [
                    //     BoxShadow(
                    //       // color: Colors.grey, // 影の色
                    //       // spreadRadius: 0,      // 影の広がり度合い
                    //       // blurRadius: 5,        // 影のぼかし度合い
                    //     ),
                    //   ],
                    // ),
                    height: widget.titleHeight,
                    width: widget.tableWidth - widget.titleWidth,
                    child: SingleChildScrollView(
                      controller: widget.controllerHorizontal_1,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width:10),
                          for(int i =0; i < widget.columnTitles.length; i++)
                          widget.columnTitles[i],
                          const SizedBox(width:10),
                        ],
                      )
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  // ロウタイトル (時間区分)
                  Container(
                    // decoration: BoxDecoration(
                    //   color: widget.isDark ? Colors.black : Colors.white, // コンテナの背景色
                    //   boxShadow: const [
                    //     BoxShadow(
                    //       // color: Colors.grey,  // 影の色
                    //       // spreadRadius: 0,       // 影の広がり度合い
                    //       // blurRadius: 5,         // 影のぼかし度合い
                    //     ),
                    //   ],
                    // ),   
                    height: widget.tableHeight - widget.titleHeight,
                    width: widget.titleWidth,
                    child: SingleChildScrollView(
                        controller: widget.controllerVertical_1,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            for(int i = 0; i < widget.rowTitles.length; i++)
                            widget.rowTitles[i],
                            const SizedBox(height: 10),
                          ]
                        ),
                    ),
                  ),
                  // メインコンテンツ
                  SizedBox(
                    width: widget.tableWidth - widget.titleWidth,
                    height: widget.tableHeight - widget.titleHeight,
                    child: GestureDetector(
                      onPanDown: (detail) {
                        if(widget.enableEdit){
                          _judgeHit(context, detail.globalPosition);
                        }
                      },
                      onPanStart: (detail) {
                        if(widget.enableEdit){
                          _judgeHit(context, detail.globalPosition);
                        }
                      },
                      onPanUpdate: (detail) {
                        if(widget.enableEdit){
                          _judgeHit(context, detail.globalPosition);
                        }
                      },
                      onPanEnd: (details) {
                        if(widget.enableEdit){
                          widget.onInputEnd?.call();
                        }
                      },
                      onTapDown: (details){
                        _judgeHit(context, details.globalPosition);
                      },
                      onTap: (){
                        if(widget.enableEdit){
                          widget.onInputEnd?.call();
                        }
                      }, 
                      child: TwoDimensionalGridView(
                        firstColumnWidth: widget.cellWidth + 10,
                        otherColumnWidth: widget.cellWidth,
                        firstRowHeight:   widget.cellHeight + 10,
                        otherRowHeight:   widget.cellHeight,
                        diagonalDragBehavior: DiagonalDragBehavior.free,
                        horizontalDetails: ScrollableDetails.horizontal(controller: widget.controllerHorizontal_0),
                        verticalDetails: ScrollableDetails.vertical(controller: widget.controllerVertical_0),
                        delegate: TwoDimensionalChildBuilderDelegate(
                          maxXIndex: contents[0].length - 1,
                          maxYIndex: contents.length - 1,
                          builder: (BuildContext context, ChildVicinity vicinity) {
                            return contents[vicinity.yIndex][vicinity.xIndex];
                          }
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(height: widget.titleHeight, width: widget.titleWidth+2)
        ],
      ),
    );
  }

  List<List<Widget>> getContents(List<int> list_1, List<int> list_2) {

    List<List<Widget>> list = [];

    for(int i = 0; i < list_1.length; i++){
      list.add([]);
      for(int j = 0; j < list_2.length; j++){
        list[i].add(Padding(
          padding: EdgeInsets.only(top: (i == 0) ? 10 : 0, right: (j == list_2.length-1) ? 10 : 0, left: (j == 0) ? 10 : 0, bottom: (i == list_1.length-1) ? 10 : 0),
          child: _cell(i, j)
        ));
      }
    }

    return list;
  }

  Widget _cell(int row, int column) {

    return Container(
      width: widget.cellWidth,
      height: widget.cellHeight,
      decoration: BoxDecoration(
        border: Border(
          top:    row == 0 ? const BorderSide(width: 1, color: Colors.grey) : BorderSide.none,
          bottom: const BorderSide(width: 1, color: Colors.grey),
          left:   column == 0 ? const BorderSide(width: 1, color: Colors.grey) : BorderSide.none,
          right:  const BorderSide(width: 1, color: Colors.grey),
        ),
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