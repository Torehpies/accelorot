import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'operators_date_filter_provider.g.dart';

@riverpod
class OperatorsDateFilter extends _$OperatorsDateFilter {
  @override
  DateFilterRange build() {
    return const DateFilterRange(type: DateFilterType.none);
  }

  void setFilter(DateFilterRange filter) => state = filter;
  void clearFilter() =>
      state = const DateFilterRange(type: DateFilterType.none);
}
