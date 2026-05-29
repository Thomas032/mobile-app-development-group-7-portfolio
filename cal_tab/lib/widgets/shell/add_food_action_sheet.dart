import 'package:flutter/material.dart';

enum AddFoodAction { snap2cal, barcode, search, weight }

class AddFoodActionSheet extends StatelessWidget {
  const AddFoodActionSheet({super.key});

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
                'Log entry',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What would you like to add?',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              const _AddActionRow(
                action: AddFoodAction.snap2cal,
                icon: Icons.auto_awesome,
                title: 'Snap2Cal',
                subtitle: 'Take a photo and let AI estimate it.',
              ),
              const _AddActionRow(
                action: AddFoodAction.barcode,
                icon: Icons.qr_code_scanner_rounded,
                title: 'Barcode scan',
                subtitle: 'Scan a product barcode.',
              ),
              const _AddActionRow(
                action: AddFoodAction.search,
                icon: Icons.search_rounded,
                title: 'Manual search',
                subtitle: 'Search the Open Food Facts database.',
              ),
              Divider(
                height: 24,
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
              const _AddActionRow(
                action: AddFoodAction.weight,
                icon: Icons.monitor_weight_outlined,
                title: 'Log weight',
                subtitle: 'Track your body progress.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddActionRow extends StatelessWidget {
  const _AddActionRow({
    required this.action,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final AddFoodAction action;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          key: Key('add_food_action_${action.name}'),
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context).pop(action),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.32),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: colors.primary, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
