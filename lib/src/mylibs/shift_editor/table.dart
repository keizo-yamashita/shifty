
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shift/src/mylibs/shift/shift_frame.dart';
import 'package:shift/src/mylibs/style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shift/src/mylibs/shift/shift_request.dart';
import 'package:shift/src/mylibs/shift_editor/table_title.dart';
import 'package:shift/src/mylibs/shift_editor/coordinate.dart';

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

  final double _titleHeight = 50;
  final double _titleWidth  = 80;
  final double _cellHeight  = 20;
  final double _cellWidth   = 20;

  final bool isDark = false;

  var _screenSize = const Size(0, 0);

  @override
  Widget build(BuildContext context) {

    _screenSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom);

    var timeDivs = List<TimeDivision>.generate(60, (index) => TimeDivision(name: "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}-${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}", startTime: DateTime.now(), endTime: DateTime.now().add(const Duration(hours: 10))));

    return SafeArea(
      child: Scaffold(
        body: TableEditor(
          tableWidth:  _screenSize.width,
          tableHeight: _screenSize.height,
          titleWidth:  _titleWidth,
          titleHeight: _titleHeight,
          cellWidth:   _cellWidth,
          cellHeight:  _cellHeight,
          selected: Coordinate(column: 0, row: 0),
          onChangeSelect:  (Coordinate? test){},
          onInputEnd:  (){},
          enableEdit: false,
          isDark: false,
          columnTitles: getColumnTitles(_titleHeight, _cellWidth, DateTime.now(), DateTime.now().add(const Duration(days: 30)), isDark),
          rowTitles: getRowTitles(_cellHeight, _titleWidth, timeDivs, isDark),
        )
      ),
    );
  }
}

class TableEditor extends StatefulWidget {
  final double                 tableWidth;
  final double                 tableHeight;
  final double                 cellWidth;
  final double                 cellHeight;
  final double                 titleWidth;
  final double                 titleHeight;
  final Coordinate?            selected;       // selected point cordinate
  final Function(Coordinate?)? onChangeSelect; // chage select callback
  final Function?              onInputEnd;     // notifiy input end for create input buffer
  final bool                   enableEdit;     // true = edit enable
  final bool                   isDark;
  final List<Widget>           columnTitles;
  final List<Widget>           rowTitles;
  
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
  }) : super(key: key);

  @override
  State<TableEditor> createState() => _TableEditorState(); 
}

class _TableEditorState extends State<TableEditor> {

  final controllerHorizontal_0 = ScrollController();
  final controllerHorizontal_1 = ScrollController();
  final controllerVertical_0   = ScrollController();
  final controllerVertical_1   = ScrollController();

  @override
  Widget build(BuildContext context){
    
    final contents = List<List<Widget>>.generate(60, (i) => List<Widget>.generate(30, (j) => _cell(i, j)));
    
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
                  Container(color: Colors.white, width: widget.titleWidth, height: widget.titleHeight),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white, // コンテナの背景色
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey, // 影の色
                          spreadRadius: 0,      // 影の広がり度合い
                          blurRadius: 5,        // 影のぼかし度合い
                        ),
                      ],
                    ),
                    height: widget.titleHeight,
                    width: widget.tableWidth - widget.titleWidth,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          controller: controllerHorizontal_1,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width:5),
                              for(int i =0; i < widget.columnTitles.length; i++)
                              widget.columnTitles[i],
                              const SizedBox(width:10),
                            ],
                          )
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          onPanUpdate: (DragUpdateDetails data) {
                            controllerHorizontal_0.jumpTo(controllerHorizontal_0.offset + (data.delta.dx * -1));
                            controllerHorizontal_1.jumpTo(controllerHorizontal_1.offset + (data.delta.dx * -1));
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white, // コンテナの背景色
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey, // 影の色
                          spreadRadius: 0, // 影の広がり度合い
                          blurRadius: 5, // 影のぼかし度合い
                          offset: Offset(0, 0), // 水平方向に5ピクセルずらす
                        ),
                      ],
                    ),   
                    height: widget.tableHeight - widget.titleHeight,
                    width: widget.titleWidth,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                            controller: controllerVertical_1,
                            child: Column(
                              children: [
                                const SizedBox(height: 5),
                                for(int i = 0; i < widget.rowTitles.length; i++)
                                widget.rowTitles[i],
                                const SizedBox(height: 10),
                              ]
                            ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          onPanUpdate: (DragUpdateDetails data) {
                            controllerVertical_0.jumpTo(controllerVertical_0.offset + (data.delta.dy * -1));
                            controllerVertical_1.jumpTo(controllerVertical_1.offset + (data.delta.dy * -1));
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: widget.tableWidth - widget.titleWidth,
                    height: widget.tableHeight - widget.titleHeight,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          controller: controllerVertical_0,
                          child: SingleChildScrollView(
                            controller: controllerHorizontal_0,
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                                const SizedBox(height: 5),
                                for(int i = 0; i < contents.length; i++)
                                Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    for(int j = 0; j < contents[i].length; j++)
                                    contents[i][j],
                                    const SizedBox(width: 10),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                          ),
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
                            }else{
                              controllerHorizontal_0.jumpTo(controllerHorizontal_0.offset + (detail.delta.dx * -2));
                              controllerHorizontal_1.jumpTo(controllerHorizontal_1.offset + (detail.delta.dx * -2));
                              controllerVertical_0.jumpTo(controllerVertical_0.offset + (detail.delta.dy * -2));
                              controllerVertical_1.jumpTo(controllerVertical_1.offset + (detail.delta.dy * -2));
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(height: widget.titleHeight, width: widget.titleWidth+2, color: Colors.white)
        ],
      ),
    );
  }

  Widget getContents(List<int> list_1, List<int> list_2) {
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
    return Container(width: widget.cellWidth, height: widget.cellHeight,
    decoration: BoxDecoration(
          border: Border(
            top:    row == 0 ? const BorderSide(width: 2, color: Colors.grey) : BorderSide.none,
            bottom: const BorderSide(width: 2, color: Colors.grey),
            left:   column == 0 ? const BorderSide(width: 2, color: Colors.grey) : BorderSide.none,
            right:  const BorderSide(width: 2, color: Colors.grey),
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