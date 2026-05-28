import 'dart:async';

import 'package:cal_tab/models/food_item.dart';
import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:cal_tab/providers/ai_api_key_provider.dart';
import 'package:cal_tab/providers/custom_meals_provider.dart';
import 'package:cal_tab/providers/food_search_provider.dart';
import 'package:cal_tab/providers/selected_log_date_provider.dart';
import 'package:cal_tab/services/gemini_ai_service.dart';
import 'package:cal_tab/services/snap2cal_service.dart';
import 'package:cal_tab/widgets/add_food/food_results_list.dart';
import 'package:cal_tab/widgets/add_food/loading_states.dart';
import 'package:cal_tab/widgets/add_food/results_summary.dart';
import 'package:cal_tab/widgets/add_food/search_command_bar.dart';
import 'package:cal_tab/widgets/add_food/search_error_state.dart';
import 'package:cal_tab/widgets/shared/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key, this.target, this.autoAction});

  final FoodLogTarget? target;
  final AddFoodAutoAction? autoAction;

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final _searchController = TextEditingController();
  final _snap2cal = Snap2CalService();
  Timer? _searchDebounce;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    final action = widget.autoAction;
    if (action != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final target =
            (widget.target ??
                    FoodLogTarget(date: ref.read(selectedLogDateProvider)))
                .normalized();
        switch (action) {
          case AddFoodAutoAction.snap2cal:
            _handleSnap2Cal(target);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(foodSearchControllerProvider);
    final customMeals = ref.watch(customMealsControllerProvider);
    final selectedDate = ref.watch(selectedLogDateProvider);
    final target = (widget.target ?? FoodLogTarget(date: selectedDate))
        .normalized();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 14, 10),
              child: SearchCommandBar(
                controller: _searchController,
                onChanged: _queueSearch,
                onSubmitted: (_) => _runSearch(force: true),
                onBarcode: () =>
                    context.pushNamed('scan-barcode', extra: target),
                onSnap2Cal: () => _handleSnap2Cal(target),
                onCreateCustomMeal: () => _handleCreateCustomMeal(target),
              ),
            ),
            SizedBox(
              height: 3,
              child: searchState.isLoading
                  ? const LinearProgressIndicator(minHeight: 3)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: searchState.when(
                skipLoadingOnRefresh: true,
                skipError: true,
                data: ResultsSummary.new,
                loading: () => const ResultsSummary.loading(),
                error: (_, _) => const ResultsSummary.error(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: searchState.when(
                skipLoadingOnRefresh: true,
                skipError: true,
                data: (state) => IgnorePointer(
                  ignoring: searchState.isLoading,
                  child: AnimatedOpacity(
                    opacity: searchState.isLoading ? 0.5 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: FoodResultsList(
                      state: state,
                      target: target,
                      customMeals: customMeals.asData?.value ?? const [],
                      onLoadMore: () async => ref
                          .read(foodSearchControllerProvider.notifier)
                          .loadMore(),
                    ),
                  ),
                ),
                loading: LoadingProductList.new,
                error: (error, stackTrace) =>
                    SearchErrorState(onRetry: () => _runSearch(force: true)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _queueSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) {
        return;
      }
      final query = value.trim();
      if (query.isNotEmpty && query.length < 2) {
        return;
      }
      _runSearch();
    });
  }

  Future<void> _runSearch({bool force = false}) async {
    final query = _searchController.text.trim();
    if (!force && query == _lastQuery) {
      return;
    }

    _lastQuery = query;
    await ref.read(foodSearchControllerProvider.notifier).search(query);
  }

  Future<void> _handleSnap2Cal(FoodLogTarget target) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final apiKey = ref.read(aiApiKeyControllerProvider).value;
    if (apiKey == null || apiKey.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Add a Gemini API key in Settings to use Snap2Cal.'),
        ),
      );
      return;
    }

    final file = await _pickPhoto(messenger);
    if (!mounted || file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    final navigator = Navigator.of(context);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            const ProgressDialog(message: 'Analyzing photo with Gemini…'),
      ),
    );

    try {
      final item = await _snap2cal.estimateFoodFromBytes(
        apiKey: apiKey,
        imageBytes: bytes,
      );
      if (!mounted) return;
      navigator.pop();

      router.pushNamed(
        'food-detail',
        extra: FoodDetailRouteArgs(foodItem: item, target: target),
      );
    } on AiServiceException catch (e) {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('Snap2Cal failed: $e')));
    }
  }

  Future<void> _handleCreateCustomMeal(FoodLogTarget target) async {
    final createdMeal = await context.pushNamed<FoodItem>('custom-meal');
    if (!mounted || createdMeal == null) {
      return;
    }

    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      await _runSearch(force: true);
    }

    if (!mounted) {
      return;
    }

    context.pushNamed(
      'food-detail',
      extra: FoodDetailRouteArgs(foodItem: createdMeal, target: target),
    );
  }

  Future<XFile?> _pickPhoto(ScaffoldMessengerState messenger) async {
    try {
      return await _snap2cal.capturePhoto();
    } catch (e) {
      if (!mounted) return null;
      messenger.showSnackBar(SnackBar(content: Text('Camera unavailable: $e')));
      return null;
    }
  }
}
