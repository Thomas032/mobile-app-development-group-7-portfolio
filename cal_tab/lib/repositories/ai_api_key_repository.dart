import 'package:cal_tab/services/secure_key_value_store.dart';

abstract class AiApiKeyRepository {
  Future<String?> read();

  Future<void> save(String apiKey);

  Future<void> clear();
}

class SecureAiApiKeyRepository implements AiApiKeyRepository {
  const SecureAiApiKeyRepository({
    required SecureKeyValueStore store,
    this.storageKey = 'gemini_api_key_v1',
  }) : _store = store;

  final SecureKeyValueStore _store;
  final String storageKey;

  @override
  Future<String?> read() => _store.read(storageKey);

  @override
  Future<void> save(String apiKey) => _store.write(storageKey, apiKey);

  @override
  Future<void> clear() => _store.delete(storageKey);
}
