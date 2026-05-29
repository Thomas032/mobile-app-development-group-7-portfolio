import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/providers/barcode_scan_provider.dart';
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:cal_tab/widgets/barcode/live_camera_view.dart';
export 'package:cal_tab/widgets/barcode/live_camera_view.dart'
    show BarcodeScannerCallbacks, BarcodeScannerViewBuilder;
import 'package:cal_tab/widgets/barcode/scan_status_panel.dart';
import 'package:cal_tab/widgets/barcode/scanner_header.dart';
import 'package:cal_tab/widgets/barcode/scanner_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BarcodeScanScreen extends ConsumerStatefulWidget {
  const BarcodeScanScreen({super.key, this.target, this.scannerBuilder});

  final FoodLogTarget? target;
  final BarcodeScannerViewBuilder? scannerBuilder;

  @override
  ConsumerState<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen> {
  int _scanSession = 0;
  bool _navigatedToFood = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(barcodeScanControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedLogDateProvider);
    final target = (widget.target ?? FoodLogTarget(date: selectedDate))
        .normalized();
    final scanState = ref.watch(barcodeScanControllerProvider);

    ref.listen(barcodeScanControllerProvider, (previous, next) {
      if (_navigatedToFood ||
          next.status != BarcodeScanStatus.productFound ||
          next.foodItem == null) {
        return;
      }

      _navigatedToFood = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        context.pushReplacementNamed(
          'food-detail',
          extra: FoodDetailRouteArgs(foodItem: next.foodItem, target: target),
        );
      });
    });

    final callbacks = BarcodeScannerCallbacks(
      onBarcodeDetected: (barcode) => ref
          .read(barcodeScanControllerProvider.notifier)
          .resolveBarcode(barcode),
      onCameraReady: () =>
          ref.read(barcodeScanControllerProvider.notifier).setScanning(),
      onCameraDenied: (message) => ref
          .read(barcodeScanControllerProvider.notifier)
          .setCameraDenied(message),
      onCameraUnavailable: (message) => ref
          .read(barcodeScanControllerProvider.notifier)
          .setCameraUnavailable(message),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          KeyedSubtree(
            key: ValueKey(_scanSession),
            child:
                widget.scannerBuilder?.call(context, callbacks) ??
                LiveBarcodeCameraView(callbacks: callbacks),
          ),
          const ScannerOverlay(),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ScannerHeader(
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ScanStatusPanel(
                state: scanState,
                onRetry: () {
                  _navigatedToFood = false;
                  ref.read(barcodeScanControllerProvider.notifier).reset();
                  setState(() => _scanSession += 1);
                },
                onSearchInstead: () {
                  if (context.canPop()) {
                    context.pop();
                    return;
                  }
                  context.goNamed('add-food', extra: target);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
