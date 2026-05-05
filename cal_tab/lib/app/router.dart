import 'package:cal_tab/screens/app_root_screen.dart';
import 'package:cal_tab/screens/add_food_screen.dart';
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
      builder: (context, state) => const AddFoodScreen(),
    ),
  ],
);
