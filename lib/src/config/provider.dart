part of dsa.broker;

abstract class ConfigurationProvider {
  Future provision(ConfigurationProvision config);

  Future<bool> getBoolean(String key);
  Future<int> getInteger(String key);
  Future<double> getDouble(String key);
  Future<String> getString(String key);
  Future<Map<String, dynamic>> getMap(String key);
  Future<List<String>> getStringList(String key);

  Future setBoolean(String key, bool value);
  Future setInteger(String key, int value);
  Future setDouble(String key, double value);
  Future setString(String key, String value);
  Future setMap(String key, Map<String, dynamic> value);
  Future setStringList(String key, List<String> value);

  Future close();
}

abstract class BaseConfigurationProvider extends ConfigurationProvider {
  ConfigurationProvision _cfg;

  @override
  Future provision(ConfigurationProvision config) async {
    _cfg = config;

    await init(config);
  }

  @override
  Future<bool> getBoolean(String key) async => await _getAndCheck(key);

  @override
  Future<double> getDouble(String key) async => await _getAndCheck(key);

  @override
  Future<int> getInteger(String key) async => await _getAndCheck(key);

  @override
  Future<Map<String, dynamic>> getMap(String key) async =>
      await _getAndCheck(key);

  @override
  Future<String> getString(String key) async => await _getAndCheck(key);

  @override
  Future<List<String>> getStringList(String key) async =>
      await _getAndCheck(key);

  @override
  Future setBoolean(String key, bool value) async =>
      await _setAndCheck(key, value);

  @override
  Future setDouble(String key, double value) async =>
      await _setAndCheck(key, value);

  @override
  Future setInteger(String key, int value) async =>
      await _setAndCheck(key, value);

  @override
  Future setMap(String key, Map<String, dynamic> value) async =>
      await _setAndCheck(key, value);

  @override
  Future setString(String key, String value) async =>
      await _setAndCheck(key, value);

  @override
  Future setStringList(String key, List<String> value) async =>
      await _setAndCheck(key, value);

  Future<dynamic> _getAndCheck(String key) async {
    var entry = _cfg.getEntry(key);
    dynamic value;

    if (await has(key)) {
      value = await get(key);
    } else if (entry.defaultValue != null) {
      value = entry.defaultValue;
    }

    if (value == null) {
      if (!entry.isOptional) {
        throw new ConfigurationException(
            "Missing required configuration entry.",
            key: key);
      }
    } else {
      _cfg.checkConfigEntry(key, value);
    }

    return value;
  }

  Future _setAndCheck(String key, dynamic value) async {
    var entry = _cfg.getEntry(key);

    if (value == null) {
      if (!entry.isOptional) {
        throw new ConfigurationException(
            "Unable to set a required configuration entry to null.",
            key: key);
      }
    } else {
      _cfg.checkConfigEntry(key, value);
    }

    await set(key, value);

    return value;
  }

  Future init(ConfigurationProvision provision);
  Future<dynamic> get(String key);
  Future<bool> has(String key);
  Future set(String key, dynamic value);
}
