// lib/ui/activity_logs/models/activity_common.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_common.freezed.dart';

/// Loading status enum
enum LoadingStatus {
  initial,
  loading,
  success,
  error,
}

/// Date filter type enum
enum DateFilterType {
  none,
  today,
  yesterday,
  last7Days,
  last30Days,
  custom,
}

/// Date filter configuration
@freezed
abstract class DateFilterRange with _$DateFilterRange {
  const factory DateFilterRange({
    required DateFilterType type,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? customDate,
  }) = _DateFilterRange;

  const DateFilterRange._();

  bool get isActive => type != DateFilterType.none && startDate != null && endDate != null;
}