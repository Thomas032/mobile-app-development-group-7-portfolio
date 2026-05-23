import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class LiveBarcodeCameraView extends StatefulWidget {
  const LiveBarcodeCameraView({super.key, required this.callbacks});

  final BarcodeScannerCallbacks callbacks;

  @override
  State<LiveBarcodeCameraView> createState() => _LiveBarcodeCameraViewState();
}

class _LiveBarcodeCameraViewState extends State<LiveBarcodeCameraView> {
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
