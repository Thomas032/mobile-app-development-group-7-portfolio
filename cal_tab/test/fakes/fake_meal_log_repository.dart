import 'package:cal_tab/models/meal_entry.dart';
import 'package:cal_tab/repositories/meal_log_repository.dart';

class FakeMealLogRepository implements MealLogRepository {
  FakeMealLogRepository({List<MealEntry> initialEntries = const []})
    : _entries = [...initialEntries];

  List<MealEntry> _entries;

  List<MealEntry> get entries => List.unmodifiable(_entries);

  @override
  Future<List<MealEntry>> loadEntries() async {
    return [..._entries];
  }

  @override
  Future<void> saveEntries(List<MealEntry> entries) async {
    _entries = [...entries];
  }

  @override
  Future<void> addEntry(MealEntry entry) async {
    _entries = [..._entries, entry];
  }

  @override
  Future<void> removeEntry(String entryId) async {
    _entries = [
      for (final entry in _entries)
        if (entry.id != entryId) entry,
    ];
  }

  @override
  Future<void> clearEntries() async {
    _entries = const [];
  }
}
