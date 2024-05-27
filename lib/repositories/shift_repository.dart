import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shift/models/shift/shift_frame.dart';

class ShiftRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addShiftFrame(ShiftFrame shiftFrame) async {
    await _firestore.collection('shift-leader').add(shiftFrame.toJson());
  }

  Future<ShiftFrame> getShiftFrame(String docId) async {
    DocumentSnapshot doc = await _firestore.collection('shift-leader').doc(docId).get();
    return ShiftFrame.fromJson(doc.data() as Map<String, dynamic>);
  }
}