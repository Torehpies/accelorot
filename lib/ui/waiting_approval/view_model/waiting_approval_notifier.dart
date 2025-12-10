import 'dart:async';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/pending_member_providers.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'waiting_approval_notifier.g.dart';

// @riverpod
// class WaitingApproval extends _$WaitingApproval {
//   Timer? _redirectTimer;
//
//   @override
//   WaitingApprovalState build() {
//     final initialState = const WaitingApprovalState();
//
//     _startAcceptedCheck();
//
//     ref.onDispose(() {
//       _redirectTimer?.cancel();
//       _waitingTimer?.cancel();
//     });
//
//     return initialState;
//   }
//
//
// }

@riverpod
class WaitingApprovalNotifier extends _$WaitingApprovalNotifier {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> cancelRequest() async {
    state = AsyncLoading();
    final memberRepo = ref.read(pendingMemberRepositoryProvider);
    final appUser = ref.read(appUserProvider);
    final result = await memberRepo.declineInvitation(
      teamId: appUser.value!.teamId,
      id: appUser.value!.uid,
    );
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
    result.when(
      success: (_) => AsyncData(null),
      failure: (err) => AsyncError(err, StackTrace.current),
    );
  }
}
