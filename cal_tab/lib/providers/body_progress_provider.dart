import 'package:cal_tab/models/body_progress_entry.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BodyProgressController extends AsyncNotifier<List<BodyProgressEntry>> {
  @override
  Future<List<BodyProgressEntry>> build() async {
    final repository = await ref.read(bodyProgressRepositoryProvider.future);
    final entries = await repository.loadEntries();
    return _sorted(entries);
  }

  Future<void> addEntry(BodyProgressEntry entry) async {
    final current = state.asData?.value ?? const <BodyProgressEntry>[];
    final next = _sorted([...current, entry]);
    state = AsyncData(next);

    final repository = await ref.read(bodyProgressRepositoryProvider.future);
    await repository.saveEntries(next);
  }

  Future<void> removeEntry(String entryId) async {
    final current = state.asData?.value ?? const <BodyProgressEntry>[];
    final next = [
      for (final entry in current)
        if (entry.id != entryId) entry,
    ];
    state = AsyncData(next);

    final repository = await ref.read(bodyProgressRepositoryProvider.future);
    await repository.saveEntries(next);
  }

  Future<void> replaceEntries(List<BodyProgressEntry> entries) async {
    final next = _sorted(entries);
    state = AsyncData(next);

    final repository = await ref.read(bodyProgressRepositoryProvider.future);
    await repository.saveEntries(next);
  }

  Future<void> clearSavedEntries() async {
    state = const AsyncData([]);
    final repository = await ref.read(bodyProgressRepositoryProvider.future);
    await repository.clearEntries();
  }

  List<BodyProgressEntry> _sorted(List<BodyProgressEntry> entries) {
    final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }
}

final bodyProgressControllerProvider =
    AsyncNotifierProvider<BodyProgressController, List<BodyProgressEntry>>(
      BodyProgressController.new,
    );
