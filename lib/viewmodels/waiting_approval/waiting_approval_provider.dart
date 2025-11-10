import 'dart:async';

import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/repositories/team_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'waiting_approval_provider.g.dart';

class WaitingApprovalState {
  final bool isWaiting;
  final int redirectCountdown;
  final int waitingTimer;

  const WaitingApprovalState({
    this.isWaiting = true,
    this.redirectCountdown = 3,
    this.waitingTimer = 5,
  });

  WaitingApprovalState copyWith({
    bool? isWaiting,
    int? redirectCountdown,
    int? waitingTimer,
  }) {
    return WaitingApprovalState(
      isWaiting: isWaiting ?? this.isWaiting,
      redirectCountdown: redirectCountdown ?? this.redirectCountdown,
      waitingTimer: waitingTimer ?? this.waitingTimer,
    );
  }
}

@riverpod
class WaitingApproval extends _$WaitingApproval {
  Timer? _redirectTimer;
  Timer? _waitingTimer;

  @override
  WaitingApprovalState build() {
    final initialState = const WaitingApprovalState();

    _startAcceptedCheck();

    ref.onDispose(() {
      _redirectTimer?.cancel();
      _waitingTimer?.cancel();
    });

    return initialState;
  }

  void _startAcceptedCheck() {
    _waitingTimer?.cancel();
    _waitingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final authRepo = ref.read(authRepositoryProvider);
      final teamRepo = ref.read(teamRepositoryProvider);

      if (authRepo.currentUser == null) {
        _waitingTimer?.cancel();
        return;
      }

      final isInTeam = await teamRepo.getTeamId(authRepo.currentUser!.uid);

      if (isInTeam != null) {
        _onAccepted();
      }
    });
  }

  Future<void> _onAccepted() async {
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (state.redirectCountdown > 0) {
        state = state.copyWith(redirectCountdown: state.redirectCountdown - 1);
      } else {
        timer.cancel();
        //final authListenable = ref.read(authListenableProvider.notifier);
        //await authListenable.refreshIsInTeam();
      }
    });
  }
}
