part of dsa.broker;

class ConfigurationException {
  final String message;
  final String key;
  final dynamic value;

  ConfigurationException(this.message, {this.key, this.value});

  @override
  String toString() {
    var out = "$message";

    if (key != null || value != null) {
      out += " (";
      if (key != null) {
        out += "Key: $key";
      }

      if (value != null) {
        out += "${key == null ? '' : ', '}Value: $value";
      }

      out += ")";
    }

    return out;
  }
}
