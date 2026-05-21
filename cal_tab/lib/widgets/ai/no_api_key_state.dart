import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';

class NoApiKeyState extends StatelessWidget {
  const NoApiKeyState({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(
          'AI Assistant',
          style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 24),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.key, color: colors.primary, size: 32),
              const SizedBox(height: 16),
              Text(
                'Bring your own Gemini key',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The assistant uses your profile and today\'s intake. Add an '
                'API key in Settings to start chatting and unlock Snap2Cal.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
