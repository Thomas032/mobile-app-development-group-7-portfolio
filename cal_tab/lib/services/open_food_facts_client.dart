import 'dart:convert';
import 'dart:io';

import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_search_page.dart';
import 'package:http/http.dart' as http;

class FoodSearchException implements Exception {
  const FoodSearchException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OpenFoodFactsClient {
  OpenFoodFactsClient({required http.Client httpClient, Uri? baseUri})
    : baseUri = baseUri ?? Uri.https('world.openfoodfacts.org'),
      _httpClient = httpClient;

  final http.Client _httpClient;
  final Uri baseUri;

  static const String userAgent =
      'CalTab/1.0 (student-project; contact: unavailable)';

  Future<FoodSearchPage> searchProducts({
    String query = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final trimmedQuery = query.trim();
    final queryParameters = {
      'action': 'process',
      'json': '1',
      'page': '$page',
      'page_size': '$pageSize',
      'fields': 'code,product_name,brands,nutriments,image_front_url,image_url',
      if (trimmedQuery.isEmpty) 'sort_by': 'unique_scans_n',
      if (trimmedQuery.isNotEmpty) ...{
        'search_terms': trimmedQuery,
        'search_simple': '1',
      },
    };

    final uri = baseUri.replace(
      path: '/cgi/search.pl',
      queryParameters: queryParameters,
    );

    final response = await _httpClient.get(
      uri,
      headers: const {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.userAgentHeader: userAgent,
      },
    );

    if (response.statusCode != 200) {
      throw FoodSearchException(
        'Open Food Facts search failed with status ${response.statusCode}.',
      );
    }

    final decoded = _decodeObject(
      response.body,
      fallbackMessage: 'Open Food Facts search returned invalid data.',
    );
    final products = decoded['products'] as List<dynamic>? ?? const [];
    final totalCount = (decoded['count'] as num?)?.toInt() ?? products.length;
    final responsePage = (decoded['page'] as num?)?.toInt() ?? page;
    final responsePageSize =
        (decoded['page_size'] as num?)?.toInt() ?? pageSize;

    final items = products
        .whereType<Map<String, dynamic>>()
        .map(_foodItemFromOpenFoodFacts)
        .whereType<FoodItem>()
        .toList(growable: false);

    return FoodSearchPage(
      items: items,
      page: responsePage,
      pageSize: responsePageSize,
      totalCount: totalCount,
    );
  }

  Future<FoodItem?> getProductByBarcode(String barcode) async {
    return _lookupProductByBarcode(barcode: barcode, pathSuffix: '');
  }

  Future<FoodItem?> fetchByBarcode(String barcode) async {
    return _lookupProductByBarcode(barcode: barcode, pathSuffix: '.json');
  }

  Future<FoodItem?> _lookupProductByBarcode({
    required String barcode,
    required String pathSuffix,
  }) async {
    final trimmedBarcode = barcode.trim();
    if (trimmedBarcode.isEmpty) {
      return null;
    }

    final uri = baseUri.replace(
      path: '/api/v2/product/$trimmedBarcode$pathSuffix',
      queryParameters: const {
        'fields':
            'code,product_name,brands,nutriments,image_front_url,image_url',
      },
    );

    final response = await _httpClient.get(
      uri,
      headers: const {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.userAgentHeader: userAgent,
      },
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw FoodSearchException(
        'Open Food Facts barcode lookup failed with status ${response.statusCode}.',
      );
    }

    final decoded = _decodeObject(
      response.body,
      fallbackMessage: 'Open Food Facts barcode lookup returned invalid data.',
    );
    if (_isNotFoundResponse(decoded)) {
      return null;
    }

    final product = decoded['product'];
    if (product is! Map<String, dynamic>) {
      return null;
    }

    return _foodItemFromOpenFoodFacts(product);
  }
}

Map<String, dynamic> _decodeObject(
  String body, {
  required String fallbackMessage,
}) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } on FormatException {
    throw FoodSearchException(fallbackMessage);
  }
  throw FoodSearchException(fallbackMessage);
}

bool _isNotFoundResponse(Map<String, dynamic> json) {
  final status = json['status'];
  if (status is num && status.toInt() == 0) {
    return true;
  }
  if (status is String && status == '0') {
    return true;
  }
  return json['product'] == null;
}

FoodItem? _foodItemFromOpenFoodFacts(Map<String, dynamic> json) {
  final id = (json['code'] as String?)?.trim();
  final name = (json['product_name'] as String?)?.trim();
  final nutriments = json['nutriments'] as Map<String, dynamic>? ?? const {};

  if (id == null || id.isEmpty || name == null || name.isEmpty) {
    return null;
  }

  final calories =
      _nutriment(nutriments, 'energy-kcal_100g') ??
      _nutriment(nutriments, 'energy-kcal') ??
      0;

  return FoodItem(
    id: id,
    name: name,
    calories: calories.round(),
    proteinGrams: _nutriment(nutriments, 'proteins_100g') ?? 0,
    carbsGrams: _nutriment(nutriments, 'carbohydrates_100g') ?? 0,
    fatGrams: _nutriment(nutriments, 'fat_100g') ?? 0,
    fiberGrams: _nutriment(nutriments, 'fiber_100g') ?? 0,
    imageUrl:
        json['image_front_url'] as String? ?? json['image_url'] as String?,
  );
}

double? _nutriment(Map<String, dynamic> nutriments, String key) {
  final value = nutriments[key];
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}
