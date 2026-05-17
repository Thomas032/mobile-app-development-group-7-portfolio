import 'package:cal_tab/repositories/ai_api_key_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/in_memory_secure_key_value_store.dart';

void main() {
  group('SecureAiApiKeyRepository', () {
    test('returns null when nothing is stored', () async {
      final repository = SecureAiApiKeyRepository(
        store: InMemorySecureKeyValueStore(),
      );

      expect(await repository.read(), isNull);
    });

    test('saves and reads a key', () async {
      final repository = SecureAiApiKeyRepository(
        store: InMemorySecureKeyValueStore(),
      );

      await repository.save('gemini-key');

      expect(await repository.read(), 'gemini-key');
    });

    test('clears a stored key', () async {
      final repository = SecureAiApiKeyRepository(
        store: InMemorySecureKeyValueStore(),
      );

      await repository.save('gemini-key');
      await repository.clear();

      expect(await repository.read(), isNull);
    });
  });
}
