import 'package:cal_tab/models/food_item.dart';

class FoodSearchPage {
  const FoodSearchPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<FoodItem> items;
  final int page;
  final int pageSize;
  final int totalCount;

  bool get hasMore => page * pageSize < totalCount;
}
