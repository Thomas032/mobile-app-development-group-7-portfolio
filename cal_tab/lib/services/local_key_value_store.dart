import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalKeyValueStore {
  Future<String?> readString(String key);

  Future<void> writeString(String key, String value);

  Future<void> remove(String key);
}

class SharedPreferencesKeyValueStore implements LocalKeyValueStore {
  const SharedPreferencesKeyValueStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<String?> readString(String key) async {
    return _preferences.getString(key);
  }

  @override
  Future<void> writeString(String key, String value) async {
    final didWrite = await _preferences.setString(key, value);
    if (!didWrite) {
      throw StateError('Failed to write local value for "$key".');
    }
  }

  @override
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }
}
