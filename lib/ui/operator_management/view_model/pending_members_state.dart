// lib/ui/operator_management/view_model/pending_members_state.dart

import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_members_state.freezed.dart';

@freezed
abstract class PendingMembersState with _$PendingMembersState {
  const factory PendingMembersState({
    // Full dataset fetched once from Firestore
    @Default(<PendingMember>[]) List<PendingMember> allMembers,
    // Result of search + sort applied to allMembers
    @Default(<PendingMember>[]) List<PendingMember> filteredMembers,
    // Web: current page index (0-based, pure UI offset — no Firestore calls)
    @Default(0) int currentPage,
    @Default(10) int itemsPerPage,
    // Mobile: how many items to show in the infinite scroll list
    @Default(15) int displayLimit,
    @Default(false) bool isLoading,
    @Default(false) bool isError,
    Exception? error,
    @Default(DateFilterRange(type: DateFilterType.none))
    DateFilterRange dateFilter,
    @Default('') String searchQuery,
    String? sortColumn,
    @Default(true) bool sortAscending,
  }) = _PendingMembersState;

  const PendingMembersState._();

  // ===== WEB COMPUTED =====

  /// The slice of filteredMembers shown on the current web page
  List<PendingMember> get paginatedMembers {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage;
    if (start >= filteredMembers.length) return [];
    return filteredMembers.sublist(
      start,
      end > filteredMembers.length ? filteredMembers.length : end,
    );
  }

  /// Total number of web pages based on filtered result count
  int get totalPages {
    if (filteredMembers.isEmpty) return 1;
    return (filteredMembers.length / itemsPerPage).ceil();
  }

  // ===== MOBILE COMPUTED =====

  /// The slice of filteredMembers shown in the mobile infinite scroll list
  List<PendingMember> get displayedMembers {
    if (filteredMembers.length <= displayLimit) return filteredMembers;
    return filteredMembers.sublist(0, displayLimit);
  }

  /// Whether there are more items beyond the current displayLimit
  bool get hasMoreToLoad => filteredMembers.length > displayLimit;

  /// How many items remain hidden beyond the current displayLimit
  int get remainingCount => filteredMembers.length - displayLimit;

  // ===== SHARED =====

  bool get hasActiveFilters {
    return dateFilter.isActive || searchQuery.isNotEmpty;
  }
}