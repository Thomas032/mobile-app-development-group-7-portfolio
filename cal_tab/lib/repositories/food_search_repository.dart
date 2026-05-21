import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_search_page.dart';
import 'package:cal_tab/services/open_food_facts_client.dart';

abstract class FoodSearchRepository {
  Future<FoodSearchPage> searchFoods({
    String query = '',
    int page = 1,
    int pageSize = 20,
  });

  Future<FoodItem?> findFoodByBarcode(String barcode);
}

class OpenFoodFactsFoodSearchRepository implements FoodSearchRepository {
  const OpenFoodFactsFoodSearchRepository({required OpenFoodFactsClient client})
    : _client = client;

  final OpenFoodFactsClient _client;

  @override
  Future<FoodSearchPage> searchFoods({
    String query = '',
    int page = 1,
    int pageSize = 20,
  }) {
    return _client.searchProducts(query: query, page: page, pageSize: pageSize);
  }

  @override
  Future<FoodItem?> findFoodByBarcode(String barcode) {
    return _client.getProductByBarcode(barcode);
  }
}
