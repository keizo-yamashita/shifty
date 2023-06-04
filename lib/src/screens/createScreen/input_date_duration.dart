import 'package:flutter/material.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
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

  // DateRangePickerController? controller = DateRangePickerController();

  final now = DateTime.now();

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
                color: MyFont.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("STEP 3", style: MyFont.headlineStyleWhite20),
            ),
            Text("期間を設定", style: MyFont.headlineStyleGreen20),
          ],                  
        ),
        SizedBox(height: screenSize.height/30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text("「シフト期間」と「シフト希望入力期間」を決めましょう", style: MyFont.defaultStyleGrey15),
        ),
        SizedBox(height: screenSize.height/30),

        Column(
          children: [
            Text("シフト期間", style: MyFont.headlineStyleGreen15),
            ElevatedButton(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MyFont.primaryColor)),
              onPressed: (){
                final x = pickDateRange(context, widget.shiftTable.shiftDateRange);
                setState(() {
                  x.then((value) => widget.shiftTable.shiftDateRange = value);
                  print( widget.shiftTable.shiftDateRange.start.day.toString());
                });
              },
              child: Text("${DateFormat('yyyy/MM/dd', 'ja_JP').format(widget.shiftTable.shiftDateRange.start)} - ${DateFormat('yyyy/MM/dd', 'ja_JP').format(widget.shiftTable.shiftDateRange.end)}", style: MyFont.headlineStyleWhite15),
            )
          ],
        ),

        SizedBox(height: screenSize.height/30),

        Column(
          children: [
            Text("シフト希望入力期間", style: MyFont.headlineStyleGreen15),
            ElevatedButton(
            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MyFont.primaryColor)),
            onPressed: (){
              final x = pickDateRange(context, widget.shiftTable.inputDateRange);
              x.then((value) => widget.shiftTable.inputDateRange = value);
              setState(() {});
            },
            child: Text("${DateFormat('yyyy/MM/dd', 'ja_JP').format(widget.shiftTable.inputDateRange.start)} - ${DateFormat('yyyy/MM/dd', 'ja_JP').format(widget.shiftTable.inputDateRange.end)}", style: MyFont.headlineStyleWhite15),
        )
          ],
        ),
      ],
    );
  }

   Future<DateTimeRange> pickDateRange(BuildContext context, DateTimeRange initialDateRange) async {

    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange : initialDateRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (newDateRange != null) {
      return Future<DateTimeRange>.value(newDateRange);
    } else {
      return Future<DateTimeRange>.value(initialDateRange);
    }
  }  
}
