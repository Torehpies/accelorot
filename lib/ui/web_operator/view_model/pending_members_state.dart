import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_members_state.freezed.dart';

@freezed
abstract class PendingMembersState with _$PendingMembersState {
  const factory PendingMembersState({
    // Cumulative members for infinite scrolling
    @Default(<PendingMember>[]) List<PendingMember> items,
    @Default(<PendingMember>[]) List<PendingMember> members,
    @Default({}) Map<int, List<PendingMember>> pagesByIndex,
    @Default(0) int currentPage,
    @Default(10) int pageSize,
    @Default(false) bool isLoading,
    @Default(false) bool hasNextPage,
    DateTime? lastFetchedAt,
    @Default(false) bool isError,
    Exception? error,
    @Default(DateFilterRange(type: DateFilterType.none))
    DateFilterRange dateFilter,
  }) = _PendingMembersState;
}
