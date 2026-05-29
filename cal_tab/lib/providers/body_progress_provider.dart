import 'package:cal_tab/models/body_progress_entry.dart';
import 'package:cal_tab/models/profile_setup_input.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BodyProgressController extends AsyncNotifier<List<BodyProgressEntry>> {
  @override
  Future<List<BodyProgressEntry>> build() async {
    final repository = await ref.read(bodyProgressRepositoryProvider.future);
    final entries = await repository.loadEntries();
    return _sorted(entries);
  }

  Future<int?> addEntry(BodyProgressEntry entry) async {
    final current = await future;
    final next = _sorted([...current, entry]);
    state = AsyncData(next);

    final repository = await ref.read(bodyProgressRepositoryProvider.future);
    await repository.saveEntries(next);

    return _syncLatestWeightToProfile(next);
  }

  Future<int?> removeEntry(String entryId) async {
    final current = await future;
    final next = [
      for (final entry in current)
        if (entry.id != entryId) entry,
    ];
    state = AsyncData(next);

    final repository = await ref.read(bodyProgressRepositoryProvider.future);
    await repository.saveEntries(next);

    return _syncLatestWeightToProfile(next);
  }

  Future<void> replaceEntries(List<BodyProgressEntry> entries) async {
    final next = _sorted(entries);
    state = AsyncData(next);

    final repository = await ref.read(bodyProgressRepositoryProvider.future);
    await repository.saveEntries(next);

    await _syncLatestWeightToProfile(next);
  }

  Future<void> clearSavedEntries() async {
    state = const AsyncData([]);
    final repository = await ref.read(bodyProgressRepositoryProvider.future);
    await repository.clearEntries();
  }

  Future<int?> _syncLatestWeightToProfile(
    List<BodyProgressEntry> entries,
  ) async {
    if (entries.isEmpty) return null;
    final profile = ref.read(profileSetupControllerProvider).profile;
    if (profile == null) return null;

    final latestWeight = entries.first.weightKg;
    if ((latestWeight - profile.weightKg).abs() < 0.05) {
      return null;
    }

    await ref
        .read(profileSetupControllerProvider.notifier)
        .updateProfileInputs(
          ProfileSetupInput(
            age: profile.age,
            heightCm: profile.heightCm,
            weightKg: latestWeight,
            gender: profile.gender,
            activityLevel: profile.activityLevel,
            goalType: profile.goalType,
          ),
        );

    return ref.read(profileSetupControllerProvider).profile?.calorieGoal;
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
