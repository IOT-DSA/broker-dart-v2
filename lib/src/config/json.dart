part of dsa.broker;

class JsonFileConfigurationProvider extends BaseConfigurationProvider {
  final File file;

  TaskRunLoop _loop = new TaskRunLoop(const Duration(seconds: 2));

  Map<String, dynamic> _json = <String, dynamic>{};

  JsonFileConfigurationProvider(this.file);

  factory JsonFileConfigurationProvider.forPath(String path) {
    return new JsonFileConfigurationProvider(new File(path));
  }

  @override
  Future init(ConfigurationProvision provision) async {
    _loop.register("save", _save);

    await _loop.start();

    Future<Null> writeDefaults() async {
      _json = <String, dynamic>{};

      for (ConfigurationEntryProvision entry in provision.entries) {
        _putData(entry.key, entry.defaultValue);
      }

      var encoded = const JsonEncoder.withIndent("  ").convert(_json) + "\n";

      if (!(await file.parent.exists())) {
        await file.parent.create(recursive: true);
      }

      await file.writeAsString(encoded);
    }

    if (!(await file.exists())) {
      await writeDefaults();
    }

    try {
      var json = const JsonDecoder().convert(await file.readAsString())
          as Map<String, dynamic>;

      if (json is! Map) {
        throw "JSON is invalid.";
      }

      _json = json;
    } catch (e) {
      await file.copy(pathlib.basename(file.path) + ".corrupt");
      await writeDefaults();
    }

    for (ConfigurationEntryProvision entry in provision.entries) {
      if (!(await has(entry.key))) {
        _putData(entry.key, entry.defaultValue);
      }
    }

    await _save();
  }

  dynamic _resolveData(String path) {
    var parts = path.split(".");
    var m = _json;

    if (m.containsKey(path)) {
      return m[path];
    }

    for (String part in parts) {
      if (m == null) {
        return null;
      }

      if (m is Map) {
        m = m[part] as Map<String, dynamic>;
      } else {
        m = null;
      }
    }

    return m;
  }

  bool _resolveHasData(String path) {
    var parts = path.split(".");
    var m = _json;

    if (m.containsKey(path)) {
      return true;
    }

    var name = parts.removeLast();
    for (String part in parts) {
      if (m == null) {
        return false;
      }

      if (m is Map) {
        m = m[part] as Map<String, dynamic>;
      } else {
        m = null;
      }
    }

    if (m is Map && m.containsKey(name)) {
      return true;
    }

    return false;
  }

  void _putData(String path, dynamic value) {
    var parts = path.split(".");
    var keyName = parts.removeLast();
    var m = _json;

    if (m.containsKey(path)) {
      m[path] = value;
      return;
    }

    for (String part in parts) {
      if (m[part] == null) {
        m[part] = {};
      } else if (m[part] is! Map) {
        m[part] = {"_": m[part]};
      }

      m = m[part] as Map<String, dynamic>;
    }

    m[keyName] = value;
  }

  @override
  Future<dynamic> get(String key) async => _resolveData(key);

  @override
  Future<bool> has(String key) async {
    return _resolveHasData(key);
  }

  @override
  Future set(String key, dynamic value) async {
    _putData(key, value);
    await _loop.schedule("save");
  }

  @override
  Future close() async {
    await _loop.stop();
    await _save();
  }

  Future _save() async {
    var encoded = const JsonEncoder.withIndent("  ").convert(_json) + "\n";
    await file.writeAsString(encoded);
  }
}
