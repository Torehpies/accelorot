import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_members_state.freezed.dart';

@freezed
abstract class PendingMembersState with _$PendingMembersState {
	const factory PendingMembersState({
		@Default([]) List<PendingMember> members,
    @Default(false) bool isLoadingMembers,
    @Default(false) bool isSavingMembers,
    String? errorMessage,
    String? successMessage,
//		String? nextCursor,
//		@Default(false) bool isLoadingMore,
//		@Default(false) bool hasMoreData,
	}) = _PendingMembersState;
}
