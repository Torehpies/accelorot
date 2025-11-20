import 'package:flutter_application_1/data/providers/pending_members_providers.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/ui/pending_members/view_model/pending_members_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_members_notifier.g.dart';

@riverpod
class PendingMembers extends _$PendingMembers {
  final int _pageSize = 20;

  @override
  AsyncValue<PendingMembersState> build() {
    _fetchPage(
      teamId: 'current-team-id',
      limit: _pageSize,
      startCursor: null,
      isInitialLoad: true,
    );
    return const AsyncValue.loading();
  }

  Future<void> _fetchPage({
    required String teamId,
    required int limit,
    required String? startCursor,
    required bool isInitialLoad,
  }) async {
    final repository = ref.read(pendingMemberRepositoryProvider);

    if (isInitialLoad) {
      state = const AsyncValue.loading();
    } else if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(isLoadingMore: true));
    }
    final result = await repository.getPendingMembers(
      teamId: teamId,
      limit: limit,
      startCursor: startCursor,
    );

    result.when(
      success: (paginationResult) {
        final currentMembers = isInitialLoad ? [] : state.value!.members;

        final newState = PendingMembersState(
          members: [...currentMembers, ...paginationResult.items],
          nextCursor: paginationResult.nextCursor,
          isLoadingMore: false,
          hasMoreData: paginationResult.nextCursor != null,
        );

        state = AsyncValue.data(newState);
      },
      failure: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.hasError || !state.hasValue) return;

    final currentState = state.value!;

    if (!currentState.hasMoreData || currentState.isLoadingMore) return;

    await _fetchPage(
      teamId: 'current-team-id',
      limit: _pageSize,
      startCursor: currentState.nextCursor,
      isInitialLoad: false,
    );
  }
}
