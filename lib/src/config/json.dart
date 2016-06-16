part of dsa.broker;

class JsonFileConfigurationProvider extends BaseConfigurationProvider {
  final File file;

  Map<String, dynamic> _json = <String, dynamic>{};

  JsonFileConfigurationProvider(this.file);

  factory JsonFileConfigurationProvider.forPath(String path) {
    return new JsonFileConfigurationProvider(new File(path));
  }

  @override
  Future init(ConfigurationProvision provision) async {
    writeDefaults() async {
      var out = <String, dynamic>{};

      for (ConfigurationEntryProvision entry in provision.entries) {
        out[entry.key] = entry.defaultValue;
      }

      var encoded = const JsonEncoder.withIndent("  ").convert(out) + "\n";

      if (!(await file.parent.exists())) {
        await file.parent.create(recursive: true);
      }

      await file.writeAsString(encoded);
    }

    if (!(await file.exists())) {
      await writeDefaults();
    }

    try {
      var json = const JsonDecoder().convert(await file.readAsString());

      if (json is! Map) {
        throw "JSON is not a map.";
      }

      _json = json;
    } catch (e) {
      await file.copy(pathlib.basename(file.path) + ".corrupt");
      await writeDefaults();
    }
  }

  Future _save() async {
    var encoded = const JsonEncoder.withIndent("  ").convert(_json) + "\n";
    await file.writeAsString(encoded);
  }

  @override
  Future<dynamic> get(String key) async => _json[key];

  @override
  Future<bool> has(String key) async {
    return _json.containsKey(key);
  }

  @override
  Future set(String key, value) async {
    _json[key] = value;
    await _save();
  }
}
