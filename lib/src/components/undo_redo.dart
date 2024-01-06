class UndoRedo<T> {
  List<T> buffer = [];
  int bufferIndex = 0;
  int bufferSize = 50;

  UndoRedo(int bufSize) {
    bufferSize = bufSize;
  }

  void insertBuffer(T table) {
    if (buffer.length - 2 >= bufferIndex) {
      buffer.removeRange(bufferIndex + 1, buffer.length);
    }
    buffer.add(table);
    if (buffer.length > bufferSize) {
      buffer.removeAt(0);
    }
    bufferIndex = buffer.length - 1;
  }

  T undo() {
    bufferIndex = (bufferIndex - 1).clamp(0, buffer.length - 1);
    return buffer[bufferIndex];
  }

  T redo() {
    bufferIndex = (bufferIndex + 1).clamp(0, buffer.length - 1);
    return buffer[bufferIndex];
  }

  bool enableUndo() {
    return bufferIndex != 0;
  }

  bool enableRedo() {
    return bufferIndex != (buffer.length - 1);
  }
}
