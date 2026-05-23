import 'package:cal_tab/models/stats_snapshot.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/services/stats_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final weeklyStatsProvider = Provider.family<StatsSnapshot, UserProfile>((
  ref,
  profile,
) {
  final logState = ref.watch(dailyLogControllerProvider);
  return computeWeeklyStats(
    logState: logState,
    profile: profile,
    anchorDate: DateTime.now(),
  );
});
