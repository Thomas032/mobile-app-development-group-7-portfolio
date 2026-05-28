import 'package:cal_tab/models/body_progress_entry.dart';
import 'package:cal_tab/repositories/body_progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/in_memory_key_value_store.dart';

void main() {
  group('LocalBodyProgressRepository', () {
    test(
      'returns an empty list when no progress entries have been saved',
      () async {
        final repository = LocalBodyProgressRepository(
          store: InMemoryKeyValueStore(),
        );

        expect(await repository.loadEntries(), isEmpty);
      },
    );

    test('saves and loads body progress entries', () async {
      final repository = LocalBodyProgressRepository(
        store: InMemoryKeyValueStore(),
      );

      await repository.saveEntries([_entry]);
      final entries = await repository.loadEntries();

      expect(entries, hasLength(1));
      expect(entries.single.id, _entry.id);
      expect(entries.single.weightKg, _entry.weightKg);
      expect(entries.single.waistCm, _entry.waistCm);
      expect(entries.single.note, _entry.note);
    });

    test('clears saved progress entries', () async {
      final repository = LocalBodyProgressRepository(
        store: InMemoryKeyValueStore(),
      );

      await repository.saveEntries([_entry]);
      await repository.clearEntries();

      expect(await repository.loadEntries(), isEmpty);
    });
  });
}

final _entry = BodyProgressEntry(
  id: 'body-1',
  date: DateTime.utc(2026, 5, 20),
  weightKg: 71.2,
  waistCm: 82.5,
  note: 'Felt strong this week',
);
