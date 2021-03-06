part of dsa.broker;

abstract class StorageProvider {
  Future init();

  Future<dynamic> retrieve(String key);
  Future store(String key, dynamic value);
  Future delete(String key);

  Future stop();
}
