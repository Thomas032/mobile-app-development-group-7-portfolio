import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/screens/app_root_screen.dart';
import 'package:cal_tab/screens/add_food_screen.dart';
import 'package:cal_tab/screens/barcode_scan_screen.dart';
import 'package:cal_tab/screens/food_detail_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const AppRootScreen(),
    ),
    GoRoute(
      path: '/add-food',
      name: 'add-food',
      builder: (context, state) {
        final extra = state.extra;
        return AddFoodScreen(
          target: extra is FoodLogTarget ? extra.normalized() : null,
        );
      },
    ),
    GoRoute(
      path: '/scan-barcode',
      name: 'scan-barcode',
      builder: (context, state) {
        final extra = state.extra;
        return BarcodeScanScreen(
          target: extra is FoodLogTarget ? extra.normalized() : null,
        );
      },
    ),
    GoRoute(
      path: '/food-detail',
      name: 'food-detail',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is FoodDetailRouteArgs) {
          return FoodDetailScreen(
            foodItem: extra.foodItem,
            target: extra.target.normalized(),
          );
        }

        return FoodDetailScreen(foodItem: extra is FoodItem ? extra : null);
      },
    ),
  ],
);
