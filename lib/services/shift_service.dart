import 'package:shift/repositories/shift_repository.dart';
import 'package:shift/models/shift/shift_frame.dart';

class ShiftService {

  final ShiftRepository _shiftRepository = ShiftRepository();

  Future<void> pushShiftFrame(ShiftFrame shiftFrame) async {
    await _shiftRepository.addShiftFrame(shiftFrame);
  }

  Future<ShiftFrame> pullShiftFrame(String docId) async {
    return await _shiftRepository.getShiftFrame(docId);
  }
}