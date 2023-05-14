import 'package:flutter/material.dart';
import 'package:shift/src/font.dart';
import 'package:shift/src/screens/shift_table.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

DateTime now = DateTime.now();
var scrollController = ScrollController();

class InputDeadlineDuration extends StatefulWidget {
  final ShiftTable shiftTable;

  const InputDeadlineDuration({Key? key, required this.shiftTable}) : super(key: key);
   
  @override
  InputDeadlineDurationState createState() => InputDeadlineDurationState();
}

class InputDeadlineDurationState extends State<InputDeadlineDuration> {

  DateTime _inputStartDate = DateTime.now();
  DateTime _inputEndDate = DateTime.now();
  DateTime _workStartDate = DateTime.now();
  DateTime _workEndDate = DateTime.now();

  bool _isInputStartDateSelected = false;
  bool _isInputEndDateSelected = false;
  bool _isWorkStartDateSelected = false;
  bool _isWorkEndDateSelected = false;

  Future<void> _selectDate(BuildContext context, String dateType) async {

    DateTime firstDate;
    DateTime startDate = DateTime.now();
    DateTime lastDate  = DateTime(startDate.year + 1);

    switch (dateType) {
      case 'input_start':
        startDate = DateTime.now();
        firstDate = _inputStartDate;
        break;
      case 'input_end':
        startDate = _inputStartDate;
        firstDate = _inputEndDate;
        break;
      case 'work_start':
        startDate = _workStartDate;
        firstDate = _workStartDate;
        break;
      case 'work_end':
        startDate = _workEndDate;
        firstDate = _workEndDate;
        break;
      default:
        startDate = DateTime.now();
        firstDate = _workStartDate;
        break;
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: startDate,
      lastDate: lastDate,
      locale: const Locale('ja', ''),
    );

    if (pickedDate != null) {
      setState(() {
        if (dateType == 'input_start') {
          _inputStartDate = pickedDate;
          _isInputStartDateSelected = true;
        } else if (dateType == 'input_end') {
          _inputEndDate = pickedDate;
          _isInputEndDateSelected = true;
        } else if (dateType == 'work_start') {
          _workStartDate = pickedDate;
          _isWorkStartDateSelected = true;
        } else if (dateType == 'work_end') {
          _workEndDate = pickedDate;
          _isWorkEndDateSelected = true;
        }
        if(_inputStartDate.compareTo(_inputEndDate) == 1){
          _inputEndDate = _inputStartDate;
          _isInputEndDateSelected = false;
        }
        if(_inputEndDate.compareTo(_workStartDate) == 1){
          _workStartDate = _inputEndDate;
          _isWorkStartDateSelected = false;
        }
        if(_workStartDate.compareTo(_workEndDate) == 1){
          _workEndDate = _workStartDate;
          _isWorkEndDateSelected = false;
        }
        widget.shiftTable.inputStartDate = _inputStartDate;
        widget.shiftTable.inputEndDate   = _inputEndDate;
        widget.shiftTable.workStartDate  = _workStartDate;
        widget.shiftTable.workEndDate    = _workEndDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ja_JP', null).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return _buildSuggestions();
  }

  final myController = TextEditingController();

  Widget _buildSuggestions() {
    var screenSize   = MediaQuery.of(context).size;

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
        const Text("「シフト表の期間」と「シフト希望の入力締切」を指定してください", style: MyFont.commentStyle),
        SizedBox(height: screenSize.height/30),

        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: screenSize.width * 0.1,
                maxWidth: screenSize.width  * 0.8,
              ), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDatePickerButton(
                    context,
                    '入力開始日',
                    _isInputStartDateSelected ? _inputStartDate : null,
                    () => _selectDate(context, 'input_start'),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDatePickerButton(
                    context,
                    '入力締切日',
                    _isInputEndDateSelected ? _inputEndDate : null,
                    () => _selectDate(context, 'input_end'),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDatePickerButton(
                    context,
                    '勤務開始日',
                    _isWorkStartDateSelected ? _workStartDate : null,
                    () => _selectDate(context, 'work_start'),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDatePickerButton(
                    context,
                    '勤務終了日',
                    _isWorkEndDateSelected ? _workEndDate : null,
                    () => _selectDate(context, 'work_end'),
                  ),
                ]
              ),
            ),
          ),
        ),
      ],
    );
  }
}
  
Widget _buildDatePickerButton(BuildContext context, String label, DateTime? dateTime, VoidCallback onPressed){
  return ElevatedButton(
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: MyFont.headlineStyle2White),
        Text(dateTime == null ? '未選択' : DateFormat('yyyy/MM/dd', 'ja_JP').format(dateTime), style: MyFont.headlineStyle2White),
      ],
    ),
  );
}