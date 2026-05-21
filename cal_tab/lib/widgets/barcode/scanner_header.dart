import 'package:flutter/material.dart';

class ScannerHeader extends StatelessWidget {
  const ScannerHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const Key('barcode_scan_back_button'),
          tooltip: 'Back',
          onPressed: onBack,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            foregroundColor: Colors.white,
            minimumSize: const Size.square(44),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 12),
        Text(
          'Scan barcode',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
