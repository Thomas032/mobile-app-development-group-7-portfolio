import 'dart:async';
import 'dart:typed_data';

import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/providers/barcode_scan_provider.dart';
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

typedef BarcodeScannerViewBuilder =
    Widget Function(BuildContext context, BarcodeScannerCallbacks callbacks);

class BarcodeScannerCallbacks {
  const BarcodeScannerCallbacks({
    required this.onBarcodeDetected,
    required this.onCameraReady,
    required this.onCameraDenied,
    required this.onCameraUnavailable,
  });

  final ValueChanged<String> onBarcodeDetected;
  final VoidCallback onCameraReady;
  final ValueChanged<String> onCameraDenied;
  final ValueChanged<String> onCameraUnavailable;
}

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
                _LiveBarcodeCameraView(callbacks: callbacks),
          ),
          const _ScannerOverlay(),
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _ScannerHeader(
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _ScanStatusPanel(
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

class _LiveBarcodeCameraView extends StatefulWidget {
  const _LiveBarcodeCameraView({required this.callbacks});

  final BarcodeScannerCallbacks callbacks;

  @override
  State<_LiveBarcodeCameraView> createState() => _LiveBarcodeCameraViewState();
}

class _LiveBarcodeCameraViewState extends State<_LiveBarcodeCameraView> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner(
    formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upca,
      BarcodeFormat.upce,
      BarcodeFormat.code128,
    ],
  );

  CameraController? _cameraController;
  bool _isBusy = false;
  bool _streamPaused = false;

  static const _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    unawaited(_initializeCamera());
  }

  @override
  void dispose() {
    final controller = _cameraController;
    _cameraController = null;
    unawaited(_barcodeScanner.close());
    if (controller != null) {
      unawaited(_disposeController(controller));
    }
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final platform = defaultTargetPlatform;
    if (kIsWeb ||
        (platform != TargetPlatform.android &&
            platform != TargetPlatform.iOS)) {
      widget.callbacks.onCameraUnavailable(
        'Barcode scanning is available on Android and iOS devices.',
      );
      return;
    }

    try {
      final cameras = await availableCameras();
      if (!mounted) {
        return;
      }
      if (cameras.isEmpty) {
        widget.callbacks.onCameraUnavailable('No camera was found.');
        return;
      }

      final camera = cameras.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: platform == TargetPlatform.android
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      _cameraController = controller;
      await controller.initialize();
      if (!mounted) {
        return;
      }

      widget.callbacks.onCameraReady();
      await controller.startImageStream(_processCameraImage);
      if (mounted) {
        setState(() {});
      }
    } on CameraException catch (error) {
      if (error.code == 'CameraAccessDenied' ||
          error.code == 'CameraAccessDeniedWithoutPrompt' ||
          error.code == 'CameraAccessRestricted') {
        widget.callbacks.onCameraDenied('Camera access is required to scan.');
        return;
      }
      widget.callbacks.onCameraUnavailable('Camera could not be opened.');
    } catch (_) {
      widget.callbacks.onCameraUnavailable('Camera could not be opened.');
    }
  }

  Future<void> _disposeController(CameraController controller) async {
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (_) {
      // The camera plugin may already have stopped the stream during teardown.
    }
    await controller.dispose();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy || _streamPaused) {
      return;
    }
    _isBusy = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        return;
      }

      final barcodes = await _barcodeScanner.processImage(inputImage);
      final rawValue = barcodes
          .map((barcode) => barcode.rawValue?.trim())
          .whereType<String>()
          .where((value) => value.isNotEmpty)
          .firstOrNull;

      if (rawValue == null) {
        return;
      }

      _streamPaused = true;
      final controller = _cameraController;
      if (controller != null && controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      widget.callbacks.onBarcodeDetected(rawValue);
    } catch (_) {
      // Individual frames can fail conversion or detection; keep scanning.
    } finally {
      _isBusy = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final controller = _cameraController;
    if (controller == null) {
      return null;
    }

    final rotation = _inputImageRotation(controller.description);
    if (rotation == null) {
      return null;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    final platform = defaultTargetPlatform;
    if (format == null ||
        (platform == TargetPlatform.android &&
            format != InputImageFormat.nv21) ||
        (platform == TargetPlatform.iOS &&
            format != InputImageFormat.bgra8888)) {
      return null;
    }

    final bytes = _concatenatePlaneBytes(image.planes);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlaneBytes(List<Plane> planes) {
    final bytes = WriteBuffer();
    for (final plane in planes) {
      bytes.putUint8List(plane.bytes);
    }
    return bytes.done().buffer.asUint8List();
  }

  InputImageRotation? _inputImageRotation(CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return InputImageRotationValue.fromRawValue(sensorOrientation);
    }

    final controller = _cameraController;
    final deviceOrientation = controller?.value.deviceOrientation;
    final rotationCompensation = _orientations[deviceOrientation];
    if (rotationCompensation == null) {
      return null;
    }

    final rotation = camera.lensDirection == CameraLensDirection.front
        ? (sensorOrientation + rotationCompensation) % 360
        : (sensorOrientation - rotationCompensation + 360) % 360;
    return InputImageRotationValue.fromRawValue(rotation);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.previewSize?.height ?? 1,
        height: controller.value.previewSize?.width ?? 1,
        child: CameraPreview(controller),
      ),
    );
  }
}

class _ScannerHeader extends StatelessWidget {
  const _ScannerHeader({required this.onBack});

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

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final frame = _scanFrameFor(size);

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _ScannerShadePainter(frame: frame)),
            Positioned(
              top: frame.bottom + 18,
              left: 24,
              right: 24,
              child: const _ScannerInstruction(),
            ),
          ],
        );
      },
    );
  }
}

class _ScannerShadePainter extends CustomPainter {
  const _ScannerShadePainter({required this.frame});

  final RRect frame;

  @override
  void paint(Canvas canvas, Size size) {
    final shade = Paint()..color = Colors.black.withValues(alpha: 0.36);
    final overlay = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(frame)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlay, shade);

    final outline = Paint()
      ..color = Colors.white.withValues(alpha: 0.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(frame, outline);

    final cornerPaint = Paint()
      ..color = const Color(0xFF53E16F)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.5;
    const cornerLength = 34.0;
    final rect = frame.outerRect;
    const inset = 1.5;
    for (final corner in [
      rect.topLeft.translate(inset, inset),
      rect.topRight.translate(-inset, inset),
      rect.bottomRight.translate(-inset, -inset),
      rect.bottomLeft.translate(inset, -inset),
    ]) {
      final horizontalDirection = corner.dx < rect.center.dx ? 1.0 : -1.0;
      final verticalDirection = corner.dy < rect.center.dy ? 1.0 : -1.0;
      canvas.drawLine(
        corner,
        corner.translate(cornerLength * horizontalDirection, 0),
        cornerPaint,
      );
      canvas.drawLine(
        corner,
        corner.translate(0, cornerLength * verticalDirection),
        cornerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScannerShadePainter oldDelegate) {
    return oldDelegate.frame != frame;
  }
}

RRect _scanFrameFor(Size size) {
  final frameWidth = (size.width - 48).clamp(280.0, 380.0).toDouble();
  final frameHeight = frameWidth * 0.52;
  final centerY = size.height * 0.43;
  return RRect.fromRectAndRadius(
    Rect.fromCenter(
      center: Offset(size.width / 2, centerY),
      width: frameWidth,
      height: frameHeight,
    ),
    const Radius.circular(22),
  );
}

class _ScannerInstruction extends StatelessWidget {
  const _ScannerInstruction();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            'Point camera at barcode',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanStatusPanel extends StatelessWidget {
  const _ScanStatusPanel({
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
                SizedBox.square(
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
