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
    DateTime? customDate,
  }) = _DateFilterRange;

  const DateFilterRange._();

  /// Computed start and end dates based on filter type
  DateTime? get startDate {
    final now = DateTime.now();
    switch (type) {
      case DateFilterType.today:
        return DateTime(now.year, now.month, now.day);
      case DateFilterType.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTime(yesterday.year, yesterday.month, yesterday.day);
      case DateFilterType.last7Days:
        return now.subtract(const Duration(days: 7));
      case DateFilterType.last30Days:
        return now.subtract(const Duration(days: 30));
      case DateFilterType.custom:
        return customDate;
      case DateFilterType.none:
        return null;
    }
  }

  DateTime? get endDate {
    final now = DateTime.now();
    switch (type) {
      case DateFilterType.today:
      case DateFilterType.yesterday:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case DateFilterType.last7Days:
      case DateFilterType.last30Days:
        return now;
      case DateFilterType.custom:
        return customDate;
      case DateFilterType.none:
        return null;
    }
  }

  bool get isActive => type != DateFilterType.none;
}