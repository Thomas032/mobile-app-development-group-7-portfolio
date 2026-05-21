import 'package:cal_tab/models/food_log_route_args.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedLogDateController extends Notifier<DateTime> {
  @override
  DateTime build() => normalizeLogDate(DateTime.now());

  void select(DateTime date) {
    state = normalizeLogDate(date);
  }
}

final selectedLogDateProvider =
    NotifierProvider<SelectedLogDateController, DateTime>(
      SelectedLogDateController.new,
    );
