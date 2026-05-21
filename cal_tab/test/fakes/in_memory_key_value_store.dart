import 'package:cal_tab/services/local_key_value_store.dart';

class InMemoryKeyValueStore implements LocalKeyValueStore {
  InMemoryKeyValueStore([Map<String, String>? initialValues])
    : _values = {...?initialValues};

  final Map<String, String> _values;

  Map<String, String> get values => Map.unmodifiable(_values);

  @override
  Future<String?> readString(String key) async {
    return _values[key];
  }

  @override
  Future<void> writeString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}
