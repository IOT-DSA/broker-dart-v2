part of dsa.broker;

enum ConfigurationEntryType {
  boolean,
  integer,
  double,
  string,
  stringList,
  map
}

class ConfigurationProvision {
  final List<ConfigurationEntryProvision> entries;

  ConfigurationProvision(this.entries);

  void checkConfigEntry(String key, dynamic value) {
    var entry = getEntry(key);

    if (!_checkValue(entry.type, value)) {
      var typeName = entry.type.toString().split('.')[1];
      throw new ConfigurationException(
        "Bad configuration entry type. Should be of type ${typeName}.",
        key: key,
        value: value
      );
    }

    _checkNumericBounds(entry, value);
    _checkAllowedValues(entry, value);
  }

  bool _checkValue(ConfigurationEntryType type, dynamic value) {
    if (type == ConfigurationEntryType.string) {
      return value is String;
    } else if (type == ConfigurationEntryType.boolean) {
      return value is bool;
    } else if (type == ConfigurationEntryType.double) {
      return value is double;
    } else if (type == ConfigurationEntryType.integer) {
      return value is int;
    } else if (type == ConfigurationEntryType.map) {
      return value is Map;
    } else if (type == ConfigurationEntryType.stringList) {
      return value is List && value.every((x) => x is String);
    } else {
      return false;
    }
  }

  void _checkNumericBounds(ConfigurationEntryProvision entry, dynamic value) {
    if (value is num && entry.max is num) {
      if (value > entry.max) {
        throw new ConfigurationException(
          "Invalid value, maximum value is ${entry.max}.",
          key: entry.key,
          value: value
        );
      }
    }

    if (value is num && entry.min is num) {
      if (value < entry.min) {
        throw new ConfigurationException(
          "Invalid value, minimum value is ${entry.min}.",
          key: entry.key,
          value: value
        );
      }
    }
  }

  void _checkAllowedValues(ConfigurationEntryProvision entry, dynamic value) {
    if (entry.allowedValues is List) {
      if (value is List) {
        value.forEach((x) => _checkAllowedValues(entry, value));
      } else {
        if (!entry.allowedValues.contains(value)) {
          throw new ConfigurationException(
            "Invalid value, provided value is not allowed.",
            key: entry.key,
            value: value
          );
        }
      }
    }
  }

  ConfigurationEntryProvision getEntry(String key) {
    return entries.firstWhere((entry) => entry.key == key, orElse: () {
      throw new ConfigurationException(
        "No configuration entry found.",
        key: key
      );
    });
  }

  ConfigurationEntryProvision getEntryIfExists(String key) {
    try {
      return getEntry(key);
    } on ConfigurationException {
      return null;
    }
  }

  bool hasEntry(String key) => getEntryIfExists(key) != null;
}

class ConfigurationEntryProvision {
  final String key;
  final ConfigurationEntryType type;
  final bool isOptional;
  final defaultValue;
  final dynamic max;
  final dynamic min;
  final List<dynamic> allowedValues;

  ConfigurationEntryProvision(this.key, this.type, {
    this.defaultValue,
    this.isOptional: false,
    this.max,
    this.min,
    this.allowedValues
  });
}
