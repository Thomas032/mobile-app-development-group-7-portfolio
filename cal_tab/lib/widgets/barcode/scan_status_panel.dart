import 'package:cal_tab/providers/barcode_scan_provider.dart';
import 'package:flutter/material.dart';

class ScanStatusPanel extends StatelessWidget {
  const ScanStatusPanel({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onSearchInstead,
  });

  final BarcodeScanState state;
  final VoidCallback onRetry;
  final VoidCallback onSearchInstead;

  @override
  Widget build(BuildContext context) {
    final status = state.status;
    if (status == BarcodeScanStatus.scanning ||
        status == BarcodeScanStatus.initializingCamera ||
        status == BarcodeScanStatus.productFound) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Container(
          key: const Key('barcode_scan_status_panel'),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: switch (status) {
            BarcodeScanStatus.resolvingProduct => Row(
              children: [
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Finding product...',
                    key: const Key('barcode_scan_status_text'),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
            BarcodeScanStatus.productNotFound => _ScanPanelContent(
              title: 'Product not found',
              subtitle: state.barcode,
              primaryKey: const Key('barcode_scan_retry_button'),
              primaryLabel: 'Try again',
              primaryIcon: Icons.refresh,
              onPrimary: onRetry,
              secondaryKey: const Key('barcode_scan_search_button'),
              secondaryLabel: 'Search instead',
              secondaryIcon: Icons.search,
              onSecondary: onSearchInstead,
            ),
            BarcodeScanStatus.error => _ScanPanelContent(
              title: 'Could not load product',
              subtitle: state.message,
              primaryKey: const Key('barcode_scan_retry_button'),
              primaryLabel: 'Try again',
              primaryIcon: Icons.refresh,
              onPrimary: onRetry,
              secondaryKey: const Key('barcode_scan_search_button'),
              secondaryLabel: 'Search instead',
              secondaryIcon: Icons.search,
              onSecondary: onSearchInstead,
            ),
            BarcodeScanStatus.cameraDenied => _ScanPanelContent(
              title: 'Camera access needed',
              subtitle: state.message,
              primaryKey: const Key('barcode_scan_back_to_search_button'),
              primaryLabel: 'Back to search',
              primaryIcon: Icons.search,
              onPrimary: onSearchInstead,
            ),
            BarcodeScanStatus.cameraUnavailable => _ScanPanelContent(
              title: 'Camera unavailable',
              subtitle: state.message,
              primaryKey: const Key('barcode_scan_back_to_search_button'),
              primaryLabel: 'Back to search',
              primaryIcon: Icons.search,
              onPrimary: onSearchInstead,
            ),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

class _ScanPanelContent extends StatelessWidget {
  const _ScanPanelContent({
    required this.title,
    this.subtitle,
    required this.primaryKey,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    this.secondaryKey,
    this.secondaryLabel,
    this.secondaryIcon,
    this.onSecondary,
  });

  final String title;
  final String? subtitle;
  final Key primaryKey;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final Key? secondaryKey;
  final String? secondaryLabel;
  final IconData? secondaryIcon;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasSecondary = secondaryKey != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          key: const Key('barcode_scan_status_text'),
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (!hasSecondary)
          FilledButton.icon(
            key: primaryKey,
            onPressed: onPrimary,
            icon: Icon(primaryIcon),
            label: Text(primaryLabel),
          )
        else
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: primaryKey,
                  onPressed: onPrimary,
                  icon: Icon(primaryIcon),
                  label: Text(primaryLabel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  key: secondaryKey,
                  onPressed: onSecondary,
                  icon: Icon(secondaryIcon),
                  label: Text(secondaryLabel!),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
