part of dsa.broker;

class JsonDirectoryStorageProvider extends StorageProvider {
  final Directory directory;

  JsonDirectoryStorageProvider(this.directory);

  factory JsonDirectoryStorageProvider.forPath(String path) {
    var dir = new Directory(path);
    return new JsonDirectoryStorageProvider(dir);
  }

  @override
  Future init() async {
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
  }

  @override
  Future<dynamic> retrieve(String key) async {
    var encoded = Uri.encodeComponent(key);
    var file = new File(pathlib.join(directory.path, "${encoded}.json"));
    if (await file.exists()) {
      return const JsonDecoder().convert(await file.readAsString());
    }
    return null;
  }

  @override
  Future store(String key, value) async {
    var encoded = Uri.encodeComponent(key);
    var file = new File(pathlib.join(directory.path, "${encoded}.json"));
    await file.writeAsString(const JsonEncoder().convert(value));
  }

  @override
  Future delete(String key) async {
    var encoded = Uri.encodeComponent(key);
    var file = new File(pathlib.join(directory.path, "${encoded}.json"));

    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future stop() async {
  }
}
