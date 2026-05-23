import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/models/stats_snapshot.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';

StatsSnapshot computeWeeklyStats({
  required DailyLogState logState,
  required UserProfile profile,
  required DateTime anchorDate,
}) {
  final endDate = normalizeLogDate(anchorDate);
  final days = List.generate(7, (index) {
    final date = endDate.subtract(Duration(days: 6 - index));
    final entries = logState.entriesForDate(date);
    return StatsDay(
      date: date,
      entries: entries,
      summary: logState.summaryFor(date: date, profile: profile),
    );
  });

  return StatsSnapshot(
    profile: profile,
    days: days,
    streakDays: logState.streakDays(endDate),
  );
}
