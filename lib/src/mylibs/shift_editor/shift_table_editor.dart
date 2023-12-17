////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';
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
  final double                 titleMargin;
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
    required this.titleMargin,
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

    int rowLength    = shiftTable.shiftFrame.shiftDateRange[0].end.difference(shiftTable.shiftFrame.shiftDateRange[0].start).inDays + 1;
    int columnLength = shiftTable.shiftFrame.timeDivs.length;

    return AspectRatio(
      aspectRatio: sheetWidth/sheetHeight,
      // child: TableEditor(
      //   key: UniqueKey(),
      //   tableWidth:  sheetWidth,
      //   tableHeight: sheetHeight,
      //   titleWidth:  titleWidth,
      //   titleHeight: titleHeight,
      //   cellWidth:   cellWidth,
      //   cellHeight:  cellHeight,
      //   titleMargin: titleMargin,
      //   controllerHorizontal_0: controllerHorizontal_0,
      //   controllerHorizontal_1: controllerHorizontal_1,
      //   controllerVertical_0: controllerVertical_0,
      //   controllerVertical_1: controllerVertical_1,
      //   selected: selected,
      //   onChangeSelect:  onChangeSelect,
      //   onInputEnd:  onInputEnd,
      //   shiftTable: shiftTable,
      //   enableEdit: enableEdit,
      //   isDark: isDark,
      //   columnTitles: getColumnTitles(titleHeight, cellWidth, shiftTable.shiftFrame.shiftDateRange[0].start, shiftTable.shiftFrame.shiftDateRange[0].end, isDark),
      //   rowTitles: getRowTitles(cellHeight, titleWidth, shiftTable.shiftFrame.timeDivs, isDark),
        // cells: List<List<Widget>>.generate(
        //   columnLength, 
        //   (i){
        //     return List.generate(
        //       rowLength,
        //       (j){
        //         return Padding(
        //           padding: EdgeInsets.only(top: (i == 0) ? titleMargin : 0, right: (j == rowLength) ? titleMargin : 0, left: (j == 0) ? titleMargin : 0, bottom: (i == columnLength) ? titleMargin : 0),
        //           child: _cell(i, j, shiftTable.shiftFrame.assignTable[i][j] != 0)
        //         );
        //       }
        //     );
        //   },
        // ),
      // )
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

    return HitDetector(
      onTouch: onSelected,
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
          ? Center(child: SizedBox(width: cellWidth, height: cellHeight, child: cellValue))
          : SizedBox(width: cellWidth, height: cellHeight, child: CustomPaint(painter: DiagonalLinePainter(Colors.grey)))
      ),
    );
  }
}
