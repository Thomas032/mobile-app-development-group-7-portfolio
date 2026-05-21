import 'package:cal_tab/repositories/ai_api_key_repository.dart';
import 'package:cal_tab/repositories/app_settings_repository.dart';
import 'package:cal_tab/repositories/food_search_repository.dart';
import 'package:cal_tab/repositories/meal_log_repository.dart';
import 'package:cal_tab/repositories/user_profile_repository.dart';
import 'package:cal_tab/services/local_key_value_store.dart';
import 'package:cal_tab/services/open_food_facts_client.dart';
import 'package:cal_tab/services/secure_key_value_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

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

final secureKeyValueStoreProvider = Provider<SecureKeyValueStore>((ref) {
  return FlutterSecureKeyValueStore();
});

final aiApiKeyRepositoryProvider = Provider<AiApiKeyRepository>((ref) {
  return SecureAiApiKeyRepository(
    store: ref.watch(secureKeyValueStoreProvider),
  );
});

final foodSearchRepositoryProvider = FutureProvider<FoodSearchRepository>((
  ref,
) async {
  final client = OpenFoodFactsClient(httpClient: ref.watch(httpClientProvider));
  return OpenFoodFactsFoodSearchRepository(client: client);
});
