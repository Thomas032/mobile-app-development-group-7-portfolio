import 'dart:convert';

import 'package:cal_tab/models/app_settings.dart';
import 'package:cal_tab/services/local_key_value_store.dart';

abstract class AppSettingsRepository {
  Future<AppSettings> loadSettings();

  Future<void> saveSettings(AppSettings settings);

  Future<void> clearSettings();
}

class LocalAppSettingsRepository implements AppSettingsRepository {
  const LocalAppSettingsRepository({
    required LocalKeyValueStore store,
    this.storageKey = 'app_settings_v1',
  }) : _store = store;

  final LocalKeyValueStore _store;
  final String storageKey;

  @override
  Future<AppSettings> loadSettings() async {
    final encodedSettings = await _store.readString(storageKey);
    if (encodedSettings == null) {
      return const AppSettings();
    }

    final decoded = jsonDecode(encodedSettings) as Map<String, dynamic>;
    return AppSettings.fromJson(decoded);
  }

  @override
  Future<void> saveSettings(AppSettings settings) {
    return _store.writeString(storageKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<void> clearSettings() {
    return _store.remove(storageKey);
  }
}
