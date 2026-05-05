import 'dart:convert';

import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/services/local_key_value_store.dart';

abstract class MealLogRepository {
  Future<List<MealEntry>> loadEntries();

  Future<void> saveEntries(List<MealEntry> entries);

  Future<void> addEntry(MealEntry entry);

  Future<void> removeEntry(String entryId);

  Future<void> clearEntries();
}

class LocalMealLogRepository implements MealLogRepository {
  const LocalMealLogRepository({
    required LocalKeyValueStore store,
    this.storageKey = 'meal_entries_v1',
  }) : _store = store;

  final LocalKeyValueStore _store;
  final String storageKey;

  @override
  Future<List<MealEntry>> loadEntries() async {
    final encodedEntries = await _store.readString(storageKey);
    if (encodedEntries == null) {
      return const [];
    }

    final decoded = jsonDecode(encodedEntries) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(MealEntry.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> saveEntries(List<MealEntry> entries) {
    final encodedEntries = entries.map((entry) => entry.toJson()).toList();
    return _store.writeString(storageKey, jsonEncode(encodedEntries));
  }

  @override
  Future<void> addEntry(MealEntry entry) async {
    final entries = await loadEntries();
    await saveEntries([...entries, entry]);
  }

  @override
  Future<void> removeEntry(String entryId) async {
    final entries = await loadEntries();
    await saveEntries([
      for (final entry in entries)
        if (entry.id != entryId) entry,
    ]);
  }

  @override
  Future<void> clearEntries() {
    return _store.remove(storageKey);
  }
}
