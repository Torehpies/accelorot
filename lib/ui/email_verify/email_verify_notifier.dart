import 'dart:async';
import 'package:flutter_application_1/data/providers/app_auth_state.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/ui/email_verify/email_verify_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'email_verify_notifier.g.dart';

@riverpod
class EmailVerifyNotifier extends _$EmailVerifyNotifier {
  Timer? _cooldownTimer;
  Timer? _verificationTimer;
  Timer? _redirectTimer;

  static const int _cooldownDuration = 60; // 60 seconds

  @override
  EmailVerifyState build() {
    _startVerificationPolling();

    ref.onDispose(() {
      _cooldownTimer?.cancel();
      _verificationTimer?.cancel();
      _redirectTimer?.cancel();
    });

    return const EmailVerifyState();
  }

  // --- Core Verification Logic FIX ---

  void _startVerificationPolling() {
    _verificationTimer?.cancel();

    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      final auth = ref.watch(firebaseAuthProvider);
      final user = auth.currentUser;
      user?.reload();
      final updatedUser = auth.currentUser;

      if (updatedUser!.emailVerified) {
        timer.cancel();
        state = state.copyWith(isVerified: true);
        _startRedirectCountdown();
      }
    });
  }

  void _startRedirectCountdown() {
    _redirectTimer?.cancel();
    state = state.copyWith(dashboardCountdown: 3);

    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (state.dashboardCountdown > 0) {
        state = state.copyWith(
          dashboardCountdown: state.dashboardCountdown - 1,
        );
      } else {
        timer.cancel();
				ref.invalidate(authStateModelProvider);
      }
    });
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    state = state.copyWith(resendCooldown: _cooldownDuration);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCooldown > 0) {
        state = state.copyWith(resendCooldown: state.resendCooldown - 1);
      } else {
        timer.cancel();
        state = state.copyWith(resendCooldown: 0);
      }
    });
  }

  Future<void> resendVerificationEmail() async {
    if (state.resendCooldown > 0 || state.isResending) return;

    state = state.copyWith(isResending: true);

    final result = await ref
        .read(authRepositoryProvider)
        .resendVerificationEmail();
    result.when(
      success: (_) => _startCooldown(),
      failure: (error) {
        //state = state.copyWith(errorMessage: error.userFriendlyMessage);
      },
    );
    state = state.copyWith(isResending: false);
  }

  Future<void> signOutAndNavigate() async {
    await ref.read(authServiceProvider).signOut();
  }
}
