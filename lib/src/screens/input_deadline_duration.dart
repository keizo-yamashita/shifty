import 'package:flutter/material.dart';
import 'package:shift/src/font.dart';
import 'package:shift/src/screens/shift_table.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

var scrollController = ScrollController();

class InputDeadlineDuration extends StatefulWidget {
  final ShiftTable shiftTable;  
  const InputDeadlineDuration({Key? key, required this.shiftTable}) : super(key: key);
   
  @override
  InputDeadlineDurationState createState() => InputDeadlineDurationState();
}

class InputDeadlineDurationState extends State<InputDeadlineDuration> {

  DateRangePickerController? controller = DateRangePickerController();

  final now = DateTime.now();
  var _inputRange = [DateTime.now(), DateTime(DateTime.now().year, DateTime.now().month + 1, 0)];
  var _shiftRange = [DateTime(DateTime.now().year, DateTime.now().month + 1, 1), DateTime(DateTime.now().year, DateTime.now().month + 2, 0)];

  void _onSelectionChanged_1(DateRangePickerSelectionChangedArgs args) {
    setState(() { 
      if (args.value is PickerDateRange) {
        _shiftRange = [args.value.startDate, args.value.endDate];
        widget.shiftTable.workStartDate = args.value.startDate;
        widget.shiftTable.workEndDate = args.value.endDate;
     }
    });
  }

  void _onSelectionChanged_2(DateRangePickerSelectionChangedArgs args) {
    setState(() { 
      if (args.value is PickerDateRange) {
        _inputRange = [args.value.startDate, args.value.endDate];
        widget.shiftTable.inputStartDate = args.value.startDate;
        widget.shiftTable.inputEndDate = args.value.endDate;
     }
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ja_JP', null).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("STEP 3", style: MyFont.headlineStyleWhite),
            ),
            const Text("期間を設定", style: MyFont.headlineStyleGreen),
          ],                  
        ),
        SizedBox(height: screenSize.height/30),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Text("「シフト期間」と「シフト希望入力期間」を決めましょう", style: MyFont.commentStyle),
        ),
        SizedBox(height: screenSize.height/30),

        Column(
          children: [
            const Text("シフト期間", style: MyFont.headlineStyle2Green),
            Text("${DateFormat('yyyy/MM/dd', 'ja_JP').format(_shiftRange[0])} - ${DateFormat('yyyy/MM/dd', 'ja_JP').format(_shiftRange[1])}", style: MyFont.headlineStyle2Green),
          ],
        ),

        SizedBox(
          width: screenSize.width * 0.7,
          child: SfDateRangePicker(
            enablePastDates: false,
            onSelectionChanged: _onSelectionChanged_1,
            selectionMode: DateRangePickerSelectionMode.extendableRange,
            initialSelectedRange: PickerDateRange(_shiftRange[0], _shiftRange[1]),
          ),
        ),

        SizedBox(height: screenSize.height/30),

        Column(
          children: [
            const Text("シフト希望入力期間", style: MyFont.headlineStyle2Green),
            Text("${DateFormat('yyyy/MM/dd', 'ja_JP').format(_inputRange[0])} - ${DateFormat('yyyy/MM/dd', 'ja_JP').format(_inputRange[1])}", style: MyFont.headlineStyle2Green),
          ],
        ),

        SizedBox(
          width: screenSize.width * 0.7,
          child: SfDateRangePicker(
            enablePastDates: false,
            onSelectionChanged: _onSelectionChanged_2,
            selectionMode: DateRangePickerSelectionMode.extendableRange,
            initialSelectedRange: PickerDateRange(_inputRange[0], _inputRange[1]),
          ),
        ),
      ],
    );
  }
}
