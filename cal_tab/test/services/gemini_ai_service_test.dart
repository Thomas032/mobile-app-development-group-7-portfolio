import 'package:cal_tab/services/gemini_ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseSnapEstimate', () {
    test('parses a clean JSON response', () {
      const raw =
          '{"name":"Apple","calories_kcal_per_100g":52,"protein_g_per_100g":0.3,'
          '"carbs_g_per_100g":14,"fat_g_per_100g":0.2,"fiber_g_per_100g":2.4,'
          '"confidence":0.9}';

      final estimate = parseSnapEstimate(raw);

      expect(estimate.name, 'Apple');
      expect(estimate.caloriesPer100g, 52);
      expect(estimate.proteinPer100g, 0.3);
      expect(estimate.carbsPer100g, 14);
      expect(estimate.fatPer100g, 0.2);
      expect(estimate.fiberPer100g, 2.4);
      expect(estimate.confidence, 0.9);
    });

    test('strips markdown code fences', () {
      const raw =
          '```json\n{"name":"Bread","calories_kcal_per_100g":265,'
          '"protein_g_per_100g":9,"carbs_g_per_100g":49,"fat_g_per_100g":3,'
          '"fiber_g_per_100g":2.7}\n```';

      final estimate = parseSnapEstimate(raw);

      expect(estimate.name, 'Bread');
      expect(estimate.caloriesPer100g, 265);
    });

    test('throws on no_food response', () {
      expect(
        () => parseSnapEstimate('{"error":"no_food"}'),
        throwsA(isA<AiServiceException>()),
      );
    });

    test('throws on malformed JSON', () {
      expect(
        () => parseSnapEstimate('not json'),
        throwsA(isA<AiServiceException>()),
      );
    });

    test('throws when required fields are missing', () {
      expect(
        () => parseSnapEstimate('{"name":"X"}'),
        throwsA(isA<AiServiceException>()),
      );
    });

    test('defaults macros to 0 when missing', () {
      const raw = '{"name":"Banana","calories_kcal_per_100g":89}';

      final estimate = parseSnapEstimate(raw);

      expect(estimate.proteinPer100g, 0);
      expect(estimate.carbsPer100g, 0);
      expect(estimate.fatPer100g, 0);
      expect(estimate.fiberPer100g, 0);
      expect(estimate.confidence, isNull);
    });
  });
}
