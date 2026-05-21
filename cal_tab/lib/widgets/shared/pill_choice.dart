import 'package:flutter/material.dart';

class PillChoice extends StatelessWidget {
  const PillChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? colors.onPrimaryContainer : colors.onSurface,
      ),
      selectedColor: colors.primaryContainer,
      side: BorderSide(
        color: selected ? colors.primary : colors.outlineVariant,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
