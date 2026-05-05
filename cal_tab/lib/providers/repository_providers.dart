import 'package:cal_tab/repositories/app_settings_repository.dart';
import 'package:cal_tab/repositories/meal_log_repository.dart';
import 'package:cal_tab/repositories/user_profile_repository.dart';
import 'package:cal_tab/services/local_key_value_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final localKeyValueStoreProvider = FutureProvider<LocalKeyValueStore>((
  ref,
) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return SharedPreferencesKeyValueStore(preferences);
});

final userProfileRepositoryProvider = FutureProvider<UserProfileRepository>((
  ref,
) async {
  final store = await ref.watch(localKeyValueStoreProvider.future);
  return LocalUserProfileRepository(store: store);
});

final mealLogRepositoryProvider = FutureProvider<MealLogRepository>((
  ref,
) async {
  final store = await ref.watch(localKeyValueStoreProvider.future);
  return LocalMealLogRepository(store: store);
});

final appSettingsRepositoryProvider = FutureProvider<AppSettingsRepository>((
  ref,
) async {
  final store = await ref.watch(localKeyValueStoreProvider.future);
  return LocalAppSettingsRepository(store: store);
});
