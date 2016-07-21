part of dsa.common;

/// raw bytes are needed because we need the value to be stored in cached in a
/// smarter way, don't keep the whole buffer in memory for a small 4 bytes int value
class RawBytes {
  Uint8List bytes;

  // when retained, bytes will be cloned to make sure it doesn't keep
  // a reference to a long binary that's not fully needed
  bool retained = false;

  RawBytes(this.bytes);

  void retain() {
    if (!retained) {
      retained = true;
      bytes = new Uint8List.fromList(bytes);
    }
  }

  static String readString(TypedData bytes, int offset, int length) {
    return UTF8.decode(
        bytes.buffer.asUint8List(offset + bytes.offsetInBytes, length),
        allowMalformed: true);
  }

  static Uint8List getNoneZeroBytes(TypedData bytes, int offset) {
    Uint8List list = bytes.buffer.asUint8List(offset + bytes.offsetInBytes);
    int len = list.lengthInBytes;
    for (int i = 0; i < len; ++i) {
      if (list[i] == 0) {
        return bytes.buffer.asUint8List(offset + bytes.offsetInBytes, i);
      }
    }
    return list;
  }
}
