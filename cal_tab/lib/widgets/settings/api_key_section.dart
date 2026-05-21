import 'package:cal_tab/providers/ai_api_key_provider.dart';
import 'package:cal_tab/widgets/shared/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiKeySection extends ConsumerStatefulWidget {
  const ApiKeySection({super.key});

  @override
  ConsumerState<ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends ConsumerState<ApiKeySection> {
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

    return SectionCard(
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
