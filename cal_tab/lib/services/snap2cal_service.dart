import 'dart:typed_data';

import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/services/gemini_ai_service.dart';
import 'package:image_picker/image_picker.dart';

class Snap2CalService {
  Snap2CalService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<XFile?> capturePhoto() {
    return _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      imageQuality: 80,
    );
  }

  Future<FoodItem> estimateFoodFromBytes({
    required String apiKey,
    required Uint8List imageBytes,
  }) async {
    final service = GeminiAiService(apiKey: apiKey);
    final estimate = await service.estimateFoodFromImage(imageBytes);

    return FoodItem(
      id: 'snap2cal-${DateTime.now().millisecondsSinceEpoch}',
      name: estimate.name,
      calories: estimate.caloriesPer100g,
      proteinGrams: estimate.proteinPer100g,
      carbsGrams: estimate.carbsPer100g,
      fatGrams: estimate.fatPer100g,
      fiberGrams: estimate.fiberPer100g,
    );
  }
}
