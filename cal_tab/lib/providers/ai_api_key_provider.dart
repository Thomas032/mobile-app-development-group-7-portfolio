import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiApiKeyController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final repo = ref.watch(aiApiKeyRepositoryProvider);
    return repo.read();
  }

  Future<void> save(String apiKey) async {
    final trimmed = apiKey.trim();
    if (trimmed.isEmpty) {
      await clear();
      return;
    }
    state = const AsyncValue.loading();
    final repo = ref.read(aiApiKeyRepositoryProvider);
    await repo.save(trimmed);
    state = AsyncValue.data(trimmed);
  }

  Future<void> clear() async {
    state = const AsyncValue.loading();
    final repo = ref.read(aiApiKeyRepositoryProvider);
    await repo.clear();
    state = const AsyncValue.data(null);
  }
}

final aiApiKeyControllerProvider =
    AsyncNotifierProvider<AiApiKeyController, String?>(AiApiKeyController.new);
