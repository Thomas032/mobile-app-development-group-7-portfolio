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
  const AppSettings({this.themeMode = AppThemeMode.system});

  final AppThemeMode themeMode;

  AppSettings copyWith({AppThemeMode? themeMode}) {
    return AppSettings(themeMode: themeMode ?? this.themeMode);
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: AppThemeMode.fromJson(
        json['themeMode'] as String? ?? AppThemeMode.system.name,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'themeMode': themeMode.toJson()};
  }
}
