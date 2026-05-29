import 'package:cal_tab/models/body_progress_entry.dart';
import 'package:cal_tab/models/user_profile.dart';
import 'package:cal_tab/providers/body_progress_provider.dart';
import 'package:cal_tab/utils/date_formatting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class WeightEntryModal extends ConsumerStatefulWidget {
  const WeightEntryModal({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<WeightEntryModal> createState() => _WeightEntryModalState();
}

class _WeightEntryModalState extends ConsumerState<WeightEntryModal> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weightController.text = widget.profile.weightKg.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 32,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const SizedBox(width: 44, height: 5),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Log weight',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your body progress with regular check-ins.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        key: const Key('weight_entry_date_button'),
                        onPressed: _pickDate,
                        icon: const Icon(Icons.event_outlined),
                        label: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Date: ${formatLongDate(_selectedDate)}'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('weight_entry_weight_field'),
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                          suffixText: 'kg',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validatePositiveNumber,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('weight_entry_waist_field'),
                        controller: _waistController,
                        decoration: const InputDecoration(
                          labelText: 'Waist (optional)',
                          suffixText: 'cm',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validateOptionalNumber,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('weight_entry_note_field'),
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                        ),
                        maxLines: 2,
                        minLines: 1,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        key: const Key('save_weight_entry_button'),
                        onPressed: _isSaving ? null : _saveEntry,
                        child: Text(_isSaving ? 'Saving…' : 'Save weight'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _selectedDate = picked);
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final weight = double.parse(_weightController.text.trim());
      final waistText = _waistController.text.trim();
      final noteText = _noteController.text.trim();

      // Check if an entry for this date already exists
      final existingEntries =
          ref.read(bodyProgressControllerProvider).asData?.value ?? [];
      final existingForDate = existingEntries.firstWhereOrNull(
        (entry) =>
            entry.date.year == _selectedDate.year &&
            entry.date.month == _selectedDate.month &&
            entry.date.day == _selectedDate.day,
      );

      // If duplicate found, show confirmation dialog
      if (existingForDate != null && mounted) {
        setState(() => _isSaving = false);

        final shouldReplace =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Replace entry?'),
                content: Text(
                  'You already have a weight entry for ${formatLongDate(_selectedDate)}.\n'
                  'Do you want to replace it?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Replace'),
                  ),
                ],
              ),
            ) ??
            false;

        if (!shouldReplace) {
          return;
        }

        // Delete the old entry before adding the new one
        setState(() => _isSaving = true);
        await ref
            .read(bodyProgressControllerProvider.notifier)
            .removeEntry(existingForDate.id);
      }

      // Add the new entry
      await ref
          .read(bodyProgressControllerProvider.notifier)
          .addEntry(
            BodyProgressEntry(
              id: 'body-progress-${DateTime.now().microsecondsSinceEpoch}',
              date: _selectedDate,
              weightKg: weight,
              waistCm: waistText.isEmpty ? null : double.parse(waistText),
              note: noteText.isEmpty ? null : noteText,
            ),
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingForDate != null
                ? 'Weight entry replaced successfully.'
                : 'Weight entry saved successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
    }
  }

  String? _validatePositiveNumber(String? value) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Enter a value above 0';
    }
    return null;
  }

  String? _validateOptionalNumber(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return 'Enter a value above 0';
    }
    return null;
  }
}
