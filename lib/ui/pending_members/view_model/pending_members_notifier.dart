import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/pending_member_providers.dart';
import 'package:flutter_application_1/data/repositories/pending_member_repository/pending_member_repository.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/ui/pending_members/view_model/pending_members_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_members_notifier.g.dart';

@riverpod
class PendingMembersNotifier extends _$PendingMembersNotifier {
  late final PendingMemberRepository _repository;

  @override
  PendingMembersState build() {
    _repository = ref.read(pendingMemberRepositoryProvider);
		Future.microtask(() => fetchMembers());
    return const PendingMembersState();
  }

  Future<void> fetchMembers({bool forceRefresh = false}) async {
    state = state.copyWith(isLoadingMembers: true);
    final user = ref.read(appUserProvider).value;
		final teamId = user?.teamId ?? '';

    final result = await _repository.getPendingMembers(
      teamId: teamId,
      forceRefresh: forceRefresh,
    );

    result.when(
      success: (members) {
        state = state.copyWith(members: members, isLoadingMembers: false);
      },
      failure: (e) {
				state = state.copyWith(isLoadingMembers: false, errorMessage: e.toString());
			},
    );
  }

  Future<void> acceptInvitation(PendingMember member) async {
    state = state.copyWith(isSavingMembers: true);
    final admin = ref.read(appUserProvider).value;
		final teamId = admin?.teamId ?? '';

    final result = await _repository.acceptInvitation(
      teamId: teamId,
      member: member,
    );

    result.when(
      success: (_) {
        state = state.copyWith(
          isSavingMembers: false,
          successMessage: "Member accepted.",
        );
      },
      failure: (_) {
        state = state.copyWith(
          isSavingMembers: false,
          errorMessage: "Error accepting member.",
        );
      },
    );
    //showSnackbar(context, 'Accepted $member.user.firstName to the team');
    //showSnackbar(context, 'Error accepting member $e', isError: true);
  }

  Future<void> declineInvitation(PendingMember member) async {
    state = state.copyWith(isSavingMembers: true);
    final admin = ref.read(appUserProvider).value;
		final teamId = admin?.teamId ?? '';
		final id = admin?.uid ?? '';

    final result = await _repository.declineInvitation(
      teamId: teamId,
			id: id
    );

    result.when(
      success: (_) {
        state = state.copyWith(
          isSavingMembers: false,
          successMessage: "Declined request.",
        );
      },
      failure: (_) {
        state = state.copyWith(
          isSavingMembers: false,
          errorMessage: "Error declining request.",
        );
      },
    );
    //showSnackbar(context, "Declined $member.user.firstName's request");
    //showSnackbar( context, "Error declining member's request $e", isError: true,);
  }
}
