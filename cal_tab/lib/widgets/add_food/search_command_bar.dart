import 'package:flutter/material.dart';

class SearchCommandBar extends StatelessWidget {
  const SearchCommandBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onBarcode,
    required this.onSnap2Cal,
    required this.onCreateCustomMeal,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onBarcode;
  final VoidCallback onSnap2Cal;
  final VoidCallback onCreateCustomMeal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('food_search_field'),
                        controller: controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          hintText: 'Search everything',
                          contentPadding: EdgeInsets.fromLTRB(16, 14, 8, 14),
                        ),
                        minLines: 1,
                        textInputAction: TextInputAction.search,
                        onChanged: onChanged,
                        onSubmitted: onSubmitted,
                      ),
                    ),
                    _CommandIconButton(
                      tooltip: 'Barcode scanner',
                      icon: Icons.qr_code_scanner,
                      onPressed: onBarcode,
                    ),
                    _CommandIconButton(
                      tooltip: 'Snap2Cal',
                      icon: Icons.photo_camera_outlined,
                      onPressed: onSnap2Cal,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          key: const Key('create_custom_meal_button'),
          onPressed: onCreateCustomMeal,
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Create custom meal'),
        ),
      ],
    );
  }
}

class _CommandIconButton extends StatelessWidget {
  const _CommandIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        minimumSize: const Size.square(40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon),
    );
  }
}
