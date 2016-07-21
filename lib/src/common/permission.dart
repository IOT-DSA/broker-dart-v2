part of dsa.common;

abstract class IRemoteRequester {
  String get dsId;

  String get permissionGroup;
}

class Permission {
  /// now allowed to do anything
  static const int NONE = 0x80;

  /// list node
  static const int LIST = 0x90;

  /// read node
  static const int READ = 0xa0;

  /// write attribute and value
  static const int WRITE = 0xb0;

  /// config the node
  static const int CONFIG = 0xc0;

  /// never assigned to dslink/user, used only in permission setting
  /// i.e. if $writable is not define, then $writable = never
  static const int NEVER = 0xf0;


  static const Map<String, int> nameParser = const {
    'none': NONE,
    'list': LIST,
    'read': READ,
    'write': WRITE,
    'config': CONFIG,
    'never': NEVER
  };

  static int parse(Object obj, [int defaultVal = NEVER]) {
    if (obj is String && nameParser.containsKey(obj)) {
      return nameParser[obj];
    }
    return defaultVal;
  }

  static bool permissionValid(int val) {
    return (val >= NONE && val < NEVER);
  }
}
