import 'dart:convert';

import 'package:cal_tab/models/body_progress_entry.dart';
import 'package:cal_tab/services/local_key_value_store.dart';

abstract class BodyProgressRepository {
  Future<List<BodyProgressEntry>> loadEntries();

  Future<void> saveEntries(List<BodyProgressEntry> entries);

  Future<void> clearEntries();
}

class LocalBodyProgressRepository implements BodyProgressRepository {
  const LocalBodyProgressRepository({
    required LocalKeyValueStore store,
    this.storageKey = 'body_progress_entries_v1',
  }) : _store = store;

  final LocalKeyValueStore _store;
  final String storageKey;

  @override
  Future<List<BodyProgressEntry>> loadEntries() async {
    final encodedEntries = await _store.readString(storageKey);
    if (encodedEntries == null) {
      return const [];
    }

    final decoded = jsonDecode(encodedEntries) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(BodyProgressEntry.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> saveEntries(List<BodyProgressEntry> entries) {
    final encodedEntries = entries.map((entry) => entry.toJson()).toList();
    return _store.writeString(storageKey, jsonEncode(encodedEntries));
  }

  @override
  Future<void> clearEntries() {
    return _store.remove(storageKey);
  }
}
