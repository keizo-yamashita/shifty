import 'package:flutter/material.dart';
import 'package:shift/src/functions/font.dart';
import 'package:shift/src/functions/shift_table.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class InputDeadlineDuration extends StatefulWidget {
  final ShiftTable _shiftTable;  
  const InputDeadlineDuration({Key? key, required ShiftTable shiftTable}) : _shiftTable = shiftTable, super(key: key);
   
  @override
  InputDeadlineDurationState createState() => InputDeadlineDurationState();
}

class InputDeadlineDurationState extends State<InputDeadlineDuration> {

  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ja_JP', null).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;
    var screenSize = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: screenSize.height / 10 + appBarHeight),
            Text("「シフト期間」「シフト希望入力期間を入力しましょう", style: MyFont.defaultStyleGrey15),
            SizedBox(height: screenSize.height/30),
        
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("シフト期間", style: MyFont.headlineStyleGreen15),
                ElevatedButton(
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MyFont.primaryColor)),
                  onPressed: (){
                    final x = pickDateRange(context, widget._shiftTable.shiftDateRange[0]);
                    x.then((value) => widget._shiftTable.shiftDateRange[0] = value);
                    setState(() {}); 
                  },
                  child: Text("${DateFormat('yyyy/MM/dd', 'ja_JP').format(widget._shiftTable.shiftDateRange[0].start)} - ${DateFormat('yyyy/MM/dd', 'ja_JP').format(widget._shiftTable.shiftDateRange[0].end)}", style: MyFont.headlineStyleWhite15),
                )
              ],
            ),
        
            SizedBox(height: screenSize.height/20),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("シフト希望入力期間", style: MyFont.headlineStyleGreen15),
                ElevatedButton(
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(MyFont.primaryColor)),
                  onPressed: (){
                    final x = pickDateRange(context, widget._shiftTable.shiftDateRange[1]);
                    x.then((value) => widget._shiftTable.shiftDateRange[1] = value);
                    setState(() {}); 
                  },
                  child: Text("${DateFormat('yyyy/MM/dd', 'ja_JP').format(widget._shiftTable.shiftDateRange[1].start)} - ${DateFormat('yyyy/MM/dd', 'ja_JP').format(widget._shiftTable.shiftDateRange[1].end)}", style: MyFont.headlineStyleWhite15),
                )
              ],
            ),
            SizedBox(height: screenSize.height / 20 + appBarHeight),
          ],
        ),
      ),
    );
  }

   Future<DateTimeRange> pickDateRange(BuildContext context, DateTimeRange initialDateRange) async {

    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange : initialDateRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: MyFont.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (newDateRange != null) {
      setState(() {});
      return Future<DateTimeRange>.value(newDateRange);
    } else {
      setState(() {});
      return Future<DateTimeRange>.value(initialDateRange);
    }
  }  
}
