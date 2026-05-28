import 'package:cal_tab/models/body_progress_entry.dart';
import 'package:cal_tab/repositories/body_progress_repository.dart';

class FakeBodyProgressRepository implements BodyProgressRepository {
  FakeBodyProgressRepository({
    List<BodyProgressEntry> initialEntries = const [],
  }) : _entries = [...initialEntries];

  List<BodyProgressEntry> _entries;

  List<BodyProgressEntry> get entries => List.unmodifiable(_entries);

  @override
  Future<List<BodyProgressEntry>> loadEntries() async {
    return [..._entries];
  }

  @override
  Future<void> saveEntries(List<BodyProgressEntry> entries) async {
    _entries = [...entries];
  }

  @override
  Future<void> clearEntries() async {
    _entries = const [];
  }
}
