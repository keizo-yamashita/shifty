////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:shift/models/shift/shift_frame.dart';
import 'package:shift/models/shift_request.dart';
import 'package:shift/models/shift_table.dart';

////////////////////////////////////////////////////////////////////////////////////////////
/// シフト関係のクラスの Provider
////////////////////////////////////////////////////////////////////////////////////////////

class ShiftFrameProvider extends ChangeNotifier {
  ShiftFrame _shiftFrame = ShiftFrame.withDefaults();

  ShiftFrame get shiftFrame => _shiftFrame;

  set shiftFrame(ShiftFrame frame) {
    _shiftFrame = frame;
    notifyListeners();
  }
}

class ShiftRequestProvider extends ChangeNotifier {
  ShiftRequest _shiftRequest = ShiftRequest(ShiftFrame.withDefaults());

  ShiftRequest get shiftRequest => _shiftRequest;

  set shiftRequest(ShiftRequest request) {
    _shiftRequest = request;
    notifyListeners();
  }
}

class ShiftTableProvider extends ChangeNotifier {
  ShiftTable _shiftTable = ShiftTable(
    ShiftFrame.withDefaults(),
    [ShiftRequest(ShiftFrame.withDefaults())],
  );

  ShiftTable get shiftTable => _shiftTable;

  set shiftTable(ShiftTable table) {
    _shiftTable = table;
    notifyListeners();
  }
}
