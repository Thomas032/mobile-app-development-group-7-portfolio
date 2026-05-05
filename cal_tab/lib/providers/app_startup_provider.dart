import 'package:cal_tab/providers/app_settings_provider.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStartupProvider = FutureProvider<void>((ref) async {
  await Future.wait([
    ref.read(appSettingsControllerProvider.notifier).loadSavedSettings(),
    ref.read(profileSetupControllerProvider.notifier).loadSavedProfile(),
    ref.read(dailyLogControllerProvider.notifier).loadSavedEntries(),
  ]);
});
