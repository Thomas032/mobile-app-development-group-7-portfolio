enum AppThemeMode {
  system,
  light,
  dark;

  String toJson() => name;

  static AppThemeMode fromJson(String value) {
    return AppThemeMode.values.byName(value);
  }
}

class AppSettings {
  const AppSettings({this.themeMode = AppThemeMode.system, this.aiApiKey});

  final AppThemeMode themeMode;
  final String? aiApiKey;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? aiApiKey,
    bool clearAiApiKey = false,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      aiApiKey: clearAiApiKey ? null : aiApiKey ?? this.aiApiKey,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.fromJson(
        json['themeMode'] as String? ?? AppThemeMode.system.name,
      ),
      aiApiKey: json['aiApiKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'themeMode': themeMode.toJson(), 'aiApiKey': aiApiKey};
  }
}
