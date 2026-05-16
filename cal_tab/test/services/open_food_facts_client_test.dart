import 'dart:convert';

import 'package:cal_tab/services/open_food_facts_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('OpenFoodFactsClient.fetchByBarcode', () {
    test('returns mapped FoodItem when product is found', () async {
      late Uri capturedUri;
      final client = OpenFoodFactsClient(
        httpClient: MockClient((request) async {
          capturedUri = request.url;
          return http.Response(
            jsonEncode({
              'status': 1,
              'product': {
                'code': '737628064502',
                'product_name': 'Test Bar',
                'nutriments': {
                  'energy-kcal_100g': 250,
                  'proteins_100g': 12,
                  'carbohydrates_100g': 30,
                  'fat_100g': 8,
                  'fiber_100g': 4,
                },
                'image_front_url': 'https://example.com/img.jpg',
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final result = await client.fetchByBarcode('737628064502');

      expect(capturedUri.path, '/api/v2/product/737628064502.json');
      expect(result, isNotNull);
      expect(result!.id, '737628064502');
      expect(result.name, 'Test Bar');
      expect(result.calories, 250);
      expect(result.proteinGrams, 12);
      expect(result.imageUrl, 'https://example.com/img.jpg');
    });

    test('returns null when status is 0', () async {
      final client = OpenFoodFactsClient(
        httpClient: MockClient((_) async {
          return http.Response(jsonEncode({'status': 0}), 200);
        }),
      );

      final result = await client.fetchByBarcode('0000');

      expect(result, isNull);
    });

    test('returns null on 404', () async {
      final client = OpenFoodFactsClient(
        httpClient: MockClient((_) async {
          return http.Response('not found', 404);
        }),
      );

      expect(await client.fetchByBarcode('123'), isNull);
    });

    test('throws on other non-200', () async {
      final client = OpenFoodFactsClient(
        httpClient: MockClient((_) async {
          return http.Response('server error', 500);
        }),
      );

      expect(
        () => client.fetchByBarcode('123'),
        throwsA(isA<FoodSearchException>()),
      );
    });

    test('returns null when barcode is empty', () async {
      final client = OpenFoodFactsClient(
        httpClient: MockClient((_) async {
          fail('http should not be called for empty barcode');
        }),
      );

      expect(await client.fetchByBarcode('  '), isNull);
    });
  });
}
