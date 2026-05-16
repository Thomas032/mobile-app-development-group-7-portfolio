import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_search_page.dart';
import 'package:cal_tab/repositories/food_search_repository.dart';

class FakeFoodSearchRepository implements FoodSearchRepository {
  FakeFoodSearchRepository({
    this.results = const [],
    this.barcodeResults = const {},
    this.error,
    this.barcodeError,
    this.totalCount,
  });

  final List<FoodItem> results;
  final Map<String, FoodItem?> barcodeResults;
  final Object? error;
  final Object? barcodeError;
  final int? totalCount;

  String? lastQuery;
  int? lastPage;
  int? lastPageSize;
  String? lastBarcode;
  int barcodeLookupCount = 0;

  @override
  Future<FoodSearchPage> searchFoods({
    String query = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    lastQuery = query;
    lastPage = page;
    lastPageSize = pageSize;
    final error = this.error;
    if (error != null) {
      throw error;
    }
    return FoodSearchPage(
      items: results,
      page: page,
      pageSize: pageSize,
      totalCount: totalCount ?? results.length,
    );
  }

  @override
  Future<FoodItem?> findFoodByBarcode(String barcode) async {
    lastBarcode = barcode;
    barcodeLookupCount += 1;
    final error = barcodeError;
    if (error != null) {
      throw error;
    }
    return barcodeResults[barcode];
  }
}
