part of dsa.broker;

abstract class StorageProvider {
  Future<dynamic> retrieve(String key);
  Future store(String key, dynamic value);
  Future delete(String key);
}
