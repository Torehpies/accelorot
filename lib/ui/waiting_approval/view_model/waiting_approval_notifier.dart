import 'dart:async';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/pending_member_providers.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'waiting_approval_notifier.g.dart';

@riverpod
class WaitingApprovalNotifier extends _$WaitingApprovalNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> cancelRequest() async {
    state = AsyncLoading();
    final memberRepo = ref.read(pendingMemberRepositoryProvider);
    final appUser = ref.read(appUserProvider).value;
    final teamId = appUser?.requestTeamId ?? '';
    final id = appUser?.uid ?? '';
    final result = await memberRepo.declineInvitation(teamId: teamId, id: id);
    result.when(
      success: (success) {
        state = AsyncData(success);
      },
      failure: (err) {
        state = AsyncError(err, StackTrace.current);
      },
    );
  }

  Future<void> signOut() async {
    state = AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signOut();
    state = result.when(
      success: (_) => AsyncData(null),
      failure: (err) => AsyncError(err, StackTrace.current),
    );
  }
}
