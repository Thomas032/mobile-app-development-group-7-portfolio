import 'package:cal_tab/repositories/food_search_repository.dart';
import 'package:cal_tab/services/open_food_facts_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('OpenFoodFactsFoodSearchRepository', () {
    test('maps Open Food Facts products to FoodItem objects', () async {
      final client = OpenFoodFactsClient(
        httpClient: MockClient((request) async {
          expect(request.headers['user-agent'], OpenFoodFactsClient.userAgent);
          expect(request.url.path, '/cgi/search.pl');
          expect(request.url.queryParameters['search_terms'], 'banana');

          return http.Response(_searchResponse, 200);
        }),
      );
      final repository = OpenFoodFactsFoodSearchRepository(client: client);

      final page = await repository.searchFoods(query: 'banana');

      expect(page.items, hasLength(1));
      expect(page.items.single.id, '123');
      expect(page.items.single.name, 'Banana yogurt');
      expect(page.items.single.calories, 105);
      expect(page.items.single.proteinGrams, 4.2);
      expect(page.items.single.imageUrl, 'https://example.com/banana.jpg');
    });

    test('throws when Open Food Facts returns a non-success status', () async {
      final client = OpenFoodFactsClient(
        httpClient: MockClient((request) async {
          return http.Response('Service unavailable', 503);
        }),
      );
      final repository = OpenFoodFactsFoodSearchRepository(client: client);

      expect(
        () => repository.searchFoods(query: 'banana'),
        throwsA(isA<FoodSearchException>()),
      );
    });
  });
}

const _searchResponse = '''
{
  "products": [
    {
      "code": "123",
      "product_name": "Banana yogurt",
      "image_front_url": "https://example.com/banana.jpg",
      "nutriments": {
        "energy-kcal_100g": 105,
        "proteins_100g": 4.2,
        "carbohydrates_100g": 18.5,
        "fat_100g": 1.1,
        "fiber_100g": 0.7
      }
    },
    {
      "code": "missing-name",
      "nutriments": {}
    }
  ]
}
''';
