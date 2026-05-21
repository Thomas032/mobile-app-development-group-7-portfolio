import 'package:cal_tab/widgets/app_card.dart';
import 'package:flutter/material.dart';

class EmptyChatHint extends StatelessWidget {
  const EmptyChatHint({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, color: colors.primary, size: 32),
              const SizedBox(height: 16),
              Text(
                'Ask CalTab anything',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The assistant knows your profile and today\'s intake. Try:',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              const _SuggestedPrompt('How many calories do I have left today?'),
              const _SuggestedPrompt('What should I eat for dinner?'),
              const _SuggestedPrompt('Am I hitting my protein target?'),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuggestedPrompt extends StatelessWidget {
  const _SuggestedPrompt(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.chevron_right, size: 18, color: colors.onSurfaceVariant),
          Expanded(
            child: Text(text, style: TextStyle(color: colors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
