// google_account_provider.dart
import 'package:flutter/material.dart';
import 'package:shift/src/functions/shift_table.dart';

class CreateShiftTableProvider extends ChangeNotifier {
  ShiftTable _shiftTable = ShiftTable();

  ShiftTable get shiftTable => _shiftTable;

  set shiftTable(ShiftTable table) {
    _shiftTable = table;
    notifyListeners();
  }
}

class InputShiftRequestProvider extends ChangeNotifier {
  ShiftTable _shiftTable = ShiftTable();

  ShiftTable get shiftTable => _shiftTable;

  set shiftTable(ShiftTable table) {
    _shiftTable = table;
    notifyListeners();
  }
}