import 'package:cal_tab/models/activity_level.dart';
import 'package:cal_tab/models/app_settings.dart';
import 'package:cal_tab/models/gender.dart';
import 'package:cal_tab/models/goal_type.dart';
import 'package:cal_tab/models/macro_targets.dart';
import 'package:cal_tab/models/profile_setup_input.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/ai_api_key_provider.dart';
import 'package:cal_tab/providers/app_settings_provider.dart';
import 'package:cal_tab/providers/backup_provider.dart';
import 'package:cal_tab/providers/daily_log_provider.dart';
import 'package:cal_tab/providers/profile_setup_provider.dart';
import 'package:cal_tab/services/backup_service.dart';
import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(profileSetupControllerProvider).profile;
    final settings = ref.watch(appSettingsControllerProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'Settings',
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          _AppearanceSection(themeMode: settings.themeMode),
          const SizedBox(height: 16),
          const _ApiKeySection(),
          if (profile != null) ...[
            const SizedBox(height: 16),
            _TargetsSection(profile: profile),
            const SizedBox(height: 16),
            _ProfileSection(profile: profile),
          ],
          const SizedBox(height: 16),
          const _DataSection(),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection({required this.themeMode});

  final AppThemeMode themeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
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

class _ApiKeySection extends ConsumerStatefulWidget {
  const _ApiKeySection();

  @override
  ConsumerState<_ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends ConsumerState<_ApiKeySection> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _hydrated = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyAsync = ref.watch(aiApiKeyControllerProvider);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!_hydrated && apiKeyAsync.hasValue) {
      _controller.text = apiKeyAsync.value ?? '';
      _hydrated = true;
    }

    return _SectionCard(
      title: 'AI assistant',
      icon: Icons.key_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('gemini_api_key_field'),
            controller: _controller,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'Gemini API key',
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show' : 'Hide',
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stored securely on this device. Used for the AI assistant and Snap2Cal.',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const Key('save_api_key_button'),
                  onPressed: apiKeyAsync.isLoading ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save key'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                key: const Key('clear_api_key_button'),
                onPressed: apiKeyAsync.isLoading ? null : _clear,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(aiApiKeyControllerProvider.notifier).save(_controller.text);
    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('API key saved.')));
  }

  Future<void> _clear() async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(aiApiKeyControllerProvider.notifier).clear();
    if (!mounted) return;
    _controller.clear();
    messenger.showSnackBar(const SnackBar(content: Text('API key cleared.')));
  }
}

class _TargetsSection extends ConsumerStatefulWidget {
  const _TargetsSection({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_TargetsSection> createState() => _TargetsSectionState();
}

class _TargetsSectionState extends ConsumerState<_TargetsSection> {
  final _formKey = GlobalKey<FormState>();
  late final _calorieController = TextEditingController(
    text: '${widget.profile.calorieGoal}',
  );
  late final _proteinController = TextEditingController(
    text: _format(widget.profile.macroTargets.proteinGrams),
  );
  late final _carbsController = TextEditingController(
    text: _format(widget.profile.macroTargets.carbsGrams),
  );
  late final _fatController = TextEditingController(
    text: _format(widget.profile.macroTargets.fatGrams),
  );
  late final _fiberController = TextEditingController(
    text: _format(widget.profile.macroTargets.fiberGrams),
  );

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Daily targets',
      icon: Icons.flag_outlined,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NumberField(
              fieldKey: const Key('calorie_goal_field'),
              controller: _calorieController,
              label: 'Calorie goal',
              suffix: 'kcal',
            ),
            const SizedBox(height: 12),
            _NumberField(
              fieldKey: const Key('protein_target_field'),
              controller: _proteinController,
              label: 'Protein',
              suffix: 'g',
            ),
            const SizedBox(height: 12),
            _NumberField(
              fieldKey: const Key('carbs_target_field'),
              controller: _carbsController,
              label: 'Carbs',
              suffix: 'g',
            ),
            const SizedBox(height: 12),
            _NumberField(
              fieldKey: const Key('fat_target_field'),
              controller: _fatController,
              label: 'Fat',
              suffix: 'g',
            ),
            const SizedBox(height: 12),
            _NumberField(
              fieldKey: const Key('fiber_target_field'),
              controller: _fiberController,
              label: 'Fiber',
              suffix: 'g',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('save_targets_button'),
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save targets'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(profileSetupControllerProvider.notifier)
        .updateTargets(
          calorieGoal: int.parse(_calorieController.text),
          macroTargets: MacroTargets(
            proteinGrams: double.parse(_proteinController.text),
            carbsGrams: double.parse(_carbsController.text),
            fatGrams: double.parse(_fatController.text),
            fiberGrams: double.parse(_fiberController.text),
          ),
        );
    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('Targets updated.')));
  }

  static String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }
}

class _ProfileSection extends ConsumerStatefulWidget {
  const _ProfileSection({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<_ProfileSection> {
  final _formKey = GlobalKey<FormState>();
  late final _ageController = TextEditingController(
    text: '${widget.profile.age}',
  );
  late final _heightController = TextEditingController(
    text: widget.profile.heightCm.toStringAsFixed(0),
  );
  late final _weightController = TextEditingController(
    text: widget.profile.weightKg.toStringAsFixed(1),
  );
  late Gender _gender = widget.profile.gender;
  late ActivityLevel _activityLevel = widget.profile.activityLevel;
  late GoalType _goalType = widget.profile.goalType;

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Profile (recalculates targets)',
      icon: Icons.person_outline,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NumberField(
              fieldKey: const Key('settings_age_field'),
              controller: _ageController,
              label: 'Age',
              suffix: 'years',
            ),
            const SizedBox(height: 12),
            _NumberField(
              fieldKey: const Key('settings_height_field'),
              controller: _heightController,
              label: 'Height',
              suffix: 'cm',
            ),
            const SizedBox(height: 12),
            _NumberField(
              fieldKey: const Key('settings_weight_field'),
              controller: _weightController,
              label: 'Weight',
              suffix: 'kg',
            ),
            const SizedBox(height: 12),
            _EnumDropdown<Gender>(
              key: const Key('settings_gender_field'),
              label: 'Gender',
              value: _gender,
              values: Gender.values,
              labelFor: _genderLabel,
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 12),
            _EnumDropdown<ActivityLevel>(
              key: const Key('settings_activity_field'),
              label: 'Activity',
              value: _activityLevel,
              values: ActivityLevel.values,
              labelFor: _activityLabel,
              onChanged: (v) => setState(() => _activityLevel = v),
            ),
            const SizedBox(height: 12),
            _EnumDropdown<GoalType>(
              key: const Key('settings_goal_field'),
              label: 'Goal',
              value: _goalType,
              values: GoalType.values,
              labelFor: _goalLabel,
              onChanged: (v) => setState(() => _goalType = v),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('save_profile_button'),
              onPressed: _save,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Recalculate targets'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(profileSetupControllerProvider.notifier)
        .updateProfileInputs(
          ProfileSetupInput(
            age: int.parse(_ageController.text),
            heightCm: double.parse(_heightController.text),
            weightKg: double.parse(_weightController.text),
            gender: _gender,
            activityLevel: _activityLevel,
            goalType: _goalType,
          ),
        );
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Profile updated. Targets recalculated.')),
    );
  }
}

class _DataSection extends ConsumerWidget {
  const _DataSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupControllerProvider);

    return _SectionCard(
      title: 'Data',
      icon: Icons.storage_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            key: const Key('reset_profile_button'),
            onPressed: () => ref
                .read(profileSetupControllerProvider.notifier)
                .clearSavedProfile(),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset onboarding'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('clear_food_logs_button'),
            onPressed: () => ref
                .read(dailyLogControllerProvider.notifier)
                .clearSavedEntries(),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear food logs'),
          ),
          const SizedBox(height: 16),
          // Backup/Export section
          FilledButton.icon(
            key: const Key('export_backup_button'),
            onPressed: backupState == BackupState.loading
                ? null
                : () => _showExportDialog(context, ref),
            icon: backupState == BackupState.loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            label: const Text('Export backup'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('import_backup_button'),
            onPressed: backupState == BackupState.loading
                ? null
                : () => _showImportDialog(context, ref),
            icon: const Icon(Icons.upload_outlined),
            label: const Text('Import backup'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _ExportBackupDialog(parentRef: ref),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _ImportBackupDialog(parentRef: ref),
    );
  }
}

class _ExportBackupDialog extends ConsumerWidget {
  const _ExportBackupDialog({required this.parentRef});

  final WidgetRef parentRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Export Backup'),
      content: const Text(
        'This will download your backup file. You can later import it to restore all your data.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final backupJson = await parentRef
                .read(backupControllerProvider.notifier)
                .exportData();
            if (backupJson == null) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to export backup')),
              );
              return;
            }

            if (!context.mounted) return;
            await _downloadBackupFile(context, backupJson);
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}

/// Download backup file
Future<void> _downloadBackupFile(
  BuildContext context,
  String backupJson,
) async {
  try {
    final fileName = BackupService.getBackupFileName();

    // For all platforms, copy to clipboard and show where to save
    // On web: User can manually download from browser, or copy and paste into file
    // On mobile: User copies and can paste into any text file manager
    await Clipboard.setData(ClipboardData(text: backupJson));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Backup copied to clipboard!'),
                  Text(
                    'Save as: $fileName',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VIEW',
          onPressed: () {
            // Could show the JSON in a dialog here
          },
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}

class _ImportBackupDialog extends StatefulWidget {
  const _ImportBackupDialog({required this.parentRef});

  final WidgetRef parentRef;

  @override
  State<_ImportBackupDialog> createState() => _ImportBackupDialogState();
}

class _ImportBackupDialogState extends State<_ImportBackupDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Backup'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Paste your backup JSON data here:'),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 5,
                maxLines: 10,
                expands: false,
                decoration: const InputDecoration(
                  labelText: 'Paste backup JSON',
                  hintText: 'Paste the backup file content...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final backupJson = _controller.text.trim();
            if (backupJson.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please paste backup data')),
              );
              return;
            }

            final success = await widget.parentRef
                .read(backupControllerProvider.notifier)
                .importData(backupJson);

            if (!mounted) return;
            Navigator.of(context).pop();

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup imported successfully!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to import backup')),
              );
            }
          },
          child: const Text('Import'),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.suffix,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        final parsed = num.tryParse(value ?? '');
        if (parsed == null || parsed <= 0) {
          return 'Enter a valid $label';
        }
        return null;
      },
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  const _EnumDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem<T>(value: item, child: Text(labelFor(item))),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

String _genderLabel(Gender gender) {
  return switch (gender) {
    Gender.male => 'Male',
    Gender.female => 'Female',
    Gender.nonSpecified => 'Prefer not to say',
  };
}

String _activityLabel(ActivityLevel activityLevel) {
  return switch (activityLevel) {
    ActivityLevel.sedentary => 'Sedentary',
    ActivityLevel.lightlyActive => 'Lightly active',
    ActivityLevel.moderatelyActive => 'Moderately active',
    ActivityLevel.veryActive => 'Very active',
  };
}

String _goalLabel(GoalType goalType) {
  return switch (goalType) {
    GoalType.cut => 'Cut',
    GoalType.maintain => 'Maintain',
    GoalType.bulk => 'Bulk',
  };
}
