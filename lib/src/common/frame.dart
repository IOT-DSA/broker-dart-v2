part of dsa.common;

class Frame {
  static const int METHOD_SUBSCRIBE = 0x00;
  static const int METHOD_LIST = 0x10;
  static const int METHOD_INVOKE = 0x20;
  static const int METHOD_SET_REMOVE = 0x30;
  static const int METHOD_GET = 0x40;
  static const int METHOD_RESERVED = 0x50;
  static const int METHOD_CLOSE = 0x60;
  static const int METHOD_ETC = 0x70;

  /// set is part of set_remove, with last bit to be 1
  static const int METHOD_SET = 0x31;

  static const List<String> _methodNames = const [
    'subscribe', 'list', 'invoke', 'remove', 'get', '', 'close', 'etc'];
  static const Map<String, int> _methodMap = const {
    'subscribe':0x00,
    'list':0x10,
    'invoke':0x20,
    'remove':0x30,
    'set':0x31,
    'get':0x40,
    'close':0x60
  };

  static String getMethodName(int type) {
    if (type & METHOD_SET == METHOD_SET) {
      return 'set';
    }
    return _methodNames[(type & 0x70) >> 4];
  }

  static int getMethodType(String method) {
    return _methodMap[method];
  }

  static Frame parse(ByteData bytes, int offset) {
    if (bytes.lengthInBytes > offset + 7) { // at least 8 bytes for a frame
      int totalLength = bytes.getUint32(offset, Endianness.LITTLE_ENDIAN);
      int type = totalLength >> 24;
      totalLength &= 0xFFFFF;

      if (bytes.offsetInBytes + totalLength > bytes.lengthInBytes) {
        return null;
      }

      if (type & 0x80 == 0) {
        return new RequestFrame(bytes, offset, type, totalLength);
      } else {
        return new ResponseFrame(bytes, offset, type, totalLength);
      }
    }
    return null;
  }

  int type;
  int totalLength;
  int rid;
  int updateId;
  int clusterId;
  int partialId;

  RawBytes payload;

  Frame(this.type, this.totalLength);

  /// frame method from 0x00 to 0x70
  int get method => type & 0x70;

  /// qos value for subscribe request frame
  int get subscribeQos => type & 0x03;

  bool get clustered => (type & 0x08) != 0;

  bool get partial => (type & 0x04) != 0;
}

class RequestFrame extends Frame {
  int permission;
  String group;

  String path;

  RequestFrame(ByteData bytes, int offset, int type, int totalLength)
      :super(type, totalLength) {
    int endPos = offset + totalLength;
    offset += 4; // type and length is already parsed

    updateId = bytes.getUint32(offset, Endianness.LITTLE_ENDIAN);
    offset += 4;

    if (clustered) {
      clusterId = bytes.getUint32(offset, Endianness.LITTLE_ENDIAN);
      offset += 4;
    } else {
      clusterId = 0;
    }

    if (partial) {
      partialId = bytes.getUint32(offset, Endianness.LITTLE_ENDIAN);
      offset += 4;
    } else {
      partialId = 0;
    }

    int pathLen = bytes.getUint16(offset, Endianness.LITTLE_ENDIAN);
    offset += 2;
    if (pathLen == 0xFFFF) {
      Uint8List list = RawBytes.getNoneZeroBytes(bytes, offset);
      path = UTF8.decode(list, allowMalformed: true);
      offset += list.length + 1;
    } else {
      path = RawBytes.readString(bytes, offset, pathLen);
      offset += pathLen;
    }

    permission = bytes.getUint16(offset, Endianness.LITTLE_ENDIAN);
    offset += 2;

    if (permission < Permission.NONE) {
      group = RawBytes.readString(bytes, offset, permission);
      offset += permission;
      permission = Permission.NONE;
    } else if (permission == 0xFFFF) {
      Uint8List list = RawBytes.getNoneZeroBytes(bytes, offset);
      group = UTF8.decode(list, allowMalformed: true);
      offset += list.length + 1;
      permission = Permission.NONE;
    }
    if (offset < endPos) {
      payload = new RawBytes(bytes.buffer.asUint8List(
          offset + bytes.offsetInBytes, endPos - offset));
    }
  }
}

class ResponseFrame extends Frame {
  int status;

  ResponseFrame(ByteData bytes, int offset, int type, int totalLength)
      :super(type, totalLength) {
    int endPos = offset + totalLength;
    offset += 4; // type and length is already parsed

    updateId = bytes.getUint32(offset, Endianness.LITTLE_ENDIAN);
    offset += 4;

    if (clustered) {
      clusterId = bytes.getUint32(offset, Endianness.LITTLE_ENDIAN);
      offset += 4;
    } else {
      clusterId = 0;
    }

    if (partial) {
      partialId = bytes.getUint32(offset, Endianness.LITTLE_ENDIAN);
      offset += 4;
    } else {
      partialId = 0;
    }

    status = bytes.getUint8(offset);
    offset += 1;

    if (offset < endPos) {
      payload = new RawBytes(bytes.buffer.asUint8List(
          offset + bytes.offsetInBytes, endPos - offset));
    }
  }
}
