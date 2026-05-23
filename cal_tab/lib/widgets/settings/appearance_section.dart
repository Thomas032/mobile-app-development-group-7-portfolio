import 'package:cal_tab/models/app_settings.dart';
import 'package:cal_tab/providers/app_settings_provider.dart';
import 'package:cal_tab/widgets/shared/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key, required this.themeMode});

  final AppThemeMode themeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      title: 'Appearance',
      icon: Icons.color_lens_outlined,
      child: SegmentedButton<AppThemeMode>(
        segments: const [
          ButtonSegment(
            value: AppThemeMode.system,
            label: Text('System'),
            icon: Icon(Icons.smartphone),
          ),
          ButtonSegment(
            value: AppThemeMode.light,
            label: Text('Light'),
            icon: Icon(Icons.light_mode),
          ),
          ButtonSegment(
            value: AppThemeMode.dark,
            label: Text('Dark'),
            icon: Icon(Icons.dark_mode),
          ),
        ],
        selected: {themeMode},
        onSelectionChanged: (selection) {
          ref
              .read(appSettingsControllerProvider.notifier)
              .updateThemeMode(selection.first);
        },
      ),
    );
  }
}
