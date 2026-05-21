import 'package:cal_tab/app/router.dart';
import 'package:cal_tab/app/theme.dart';
import 'package:cal_tab/models/app_settings.dart';
import 'package:cal_tab/providers/app_settings_provider.dart';
import 'package:cal_tab/widgets/app_startup_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalTabApp extends ConsumerWidget {
  const CalTabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsControllerProvider);

    return MaterialApp.router(
      title: 'CalTab',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode.toFlutterThemeMode(),
      routerConfig: appRouter,
      builder: (context, child) {
        return AppStartupGate(child: child ?? const SizedBox.shrink());
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

extension on AppThemeMode {
  ThemeMode toFlutterThemeMode() {
    return switch (this) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
  }
}
