////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';

import 'package:shift/src/components/shift/shift_frame.dart';
import 'package:shift/src/components/shift/shift_request.dart';
import 'package:shift/src/components/shift/shift_table.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト関係のクラスの Provider
////////////////////////////////////////////////////////////////////////////////////////////

class ShiftFrameProvider extends ChangeNotifier {
  ShiftFrame _shiftFrame = ShiftFrame();

  ShiftFrame get shiftFrame => _shiftFrame;

  set shiftFrame(ShiftFrame frame) {
    _shiftFrame = frame;
    notifyListeners();
  }
}

class ShiftRequestProvider extends ChangeNotifier {
  ShiftRequest _shiftRequest = ShiftRequest(ShiftFrame());

  ShiftRequest get shiftRequest => _shiftRequest;

  set shiftRequest(ShiftRequest request) {
    _shiftRequest = request;
    notifyListeners();
  }
}

class ShiftTableProvider extends ChangeNotifier {
  ShiftTable _shiftTable = ShiftTable(
    ShiftFrame(),
    [ShiftRequest(ShiftFrame())],
  );

  ShiftTable get shiftTable => _shiftTable;

  set shiftTable(ShiftTable table) {
    _shiftTable = table;
    notifyListeners();
  }
}
