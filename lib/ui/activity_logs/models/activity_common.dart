import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_common.freezed.dart';

/// Loading status used by Activity Logs
enum LoadingStatus {
  initial,
  loading,
  success,
  error,
}

/// Supported date filter types
enum DateFilterType {
  none,
  today,
  yesterday,
  last7Days,
  last30Days,
  custom,
}

/// Common date filter model
@freezed
abstract class DateFilterRange with _$DateFilterRange {
  const factory DateFilterRange({
    required DateFilterType type,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? customDate,
  }) = _DateFilterRange;

  const DateFilterRange._();

  /// True when a valid date range is selected
  bool get isActive =>
      type != DateFilterType.none &&
      startDate != null &&
      endDate != null;
}
