import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BarcodeScanStatus {
  initializingCamera,
  scanning,
  resolvingProduct,
  productFound,
  productNotFound,
  cameraDenied,
  cameraUnavailable,
  error,
}

class BarcodeScanState {
  const BarcodeScanState({
    required this.status,
    this.barcode,
    this.foodItem,
    this.message,
  });

  const BarcodeScanState.initializingCamera()
    : this(status: BarcodeScanStatus.initializingCamera);

  const BarcodeScanState.scanning() : this(status: BarcodeScanStatus.scanning);

  final BarcodeScanStatus status;
  final String? barcode;
  final FoodItem? foodItem;
  final String? message;

  bool get isResolving => status == BarcodeScanStatus.resolvingProduct;
  bool get hasFoundProduct => status == BarcodeScanStatus.productFound;
}

class BarcodeScanController extends Notifier<BarcodeScanState> {
  @override
  BarcodeScanState build() {
    return const BarcodeScanState.scanning();
  }

  void setInitializingCamera() {
    if (state.status == BarcodeScanStatus.productFound || state.isResolving) {
      return;
    }
    state = const BarcodeScanState.initializingCamera();
  }

  void setScanning() {
    if (state.status == BarcodeScanStatus.productFound || state.isResolving) {
      return;
    }
    state = const BarcodeScanState.scanning();
  }

  void setCameraDenied([String? message]) {
    state = BarcodeScanState(
      status: BarcodeScanStatus.cameraDenied,
      message: message,
    );
  }

  void setCameraUnavailable([String? message]) {
    state = BarcodeScanState(
      status: BarcodeScanStatus.cameraUnavailable,
      message: message,
    );
  }

  void reset() {
    state = const BarcodeScanState.scanning();
  }

  Future<void> resolveBarcode(String barcode) async {
    final trimmedBarcode = barcode.trim();
    if (trimmedBarcode.isEmpty) {
      return;
    }

    final current = state;
    if (current.status == BarcodeScanStatus.resolvingProduct ||
        current.status == BarcodeScanStatus.productFound) {
      return;
    }

    state = BarcodeScanState(
      status: BarcodeScanStatus.resolvingProduct,
      barcode: trimmedBarcode,
    );

    try {
      final repository = await ref.read(foodSearchRepositoryProvider.future);
      final foodItem = await repository.findFoodByBarcode(trimmedBarcode);
      if (foodItem == null) {
        state = BarcodeScanState(
          status: BarcodeScanStatus.productNotFound,
          barcode: trimmedBarcode,
        );
        return;
      }

      state = BarcodeScanState(
        status: BarcodeScanStatus.productFound,
        barcode: trimmedBarcode,
        foodItem: foodItem,
      );
    } catch (_) {
      state = BarcodeScanState(
        status: BarcodeScanStatus.error,
        barcode: trimmedBarcode,
        message: 'Could not load product. Check your connection and try again.',
      );
    }
  }
}

final barcodeScanControllerProvider =
    NotifierProvider<BarcodeScanController, BarcodeScanState>(
      BarcodeScanController.new,
    );
