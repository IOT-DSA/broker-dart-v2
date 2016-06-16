part of dsa.broker;

class JsonDirectoryStorageProvider extends StorageProvider {
  final Directory directory;

  JsonDirectoryStorageProvider(this.directory);

  factory JsonDirectoryStorageProvider.forPath(String path) {
    var dir = new Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return new JsonDirectoryStorageProvider(dir);
  }

  @override
  Future<dynamic> retrieve(String key) async {
    var encoded = Uri.encodeComponent(key);
    var file = new File(pathlib.join(directory.path, encoded));
    if (await file.exists()) {
      return const JsonDecoder().convert(await file.readAsString());
    }
    return null;
  }

  @override
  Future store(String key, value) async {
    var encoded = Uri.encodeComponent(key);
    var file = new File(pathlib.join(directory.path, encoded));
    await file.writeAsString(const JsonEncoder().convert(value));
  }

  @override
  Future delete(String key) async {
    var encoded = Uri.encodeComponent(key);
    var file = new File(pathlib.join(directory.path, encoded));

    if (await file.exists()) {
      await file.delete();
    }
  }
}
