import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/routes/auth_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/screens/email_verify/email_verify_state.dart';

part 'email_verify_notifier.g.dart';

@riverpod
class EmailVerifyNotifier extends _$EmailVerifyNotifier {
  Timer? _cooldownTimer;
  Timer? _verificationTimer;
  Timer? _redirectTimer;

  static const int _cooldownDuration = 60; // 60 seconds

  @override
  EmailVerifyState build() {
    final initialState = const EmailVerifyState(
      resendCooldown: 0, // Start button clickable immediately
    );

    Future.microtask(() {
      _startVerificationCheck();
    });

    ref.onDispose(() {
      _cooldownTimer?.cancel();
      _verificationTimer?.cancel();
      _redirectTimer?.cancel();
    });

    return initialState;
  }

  // --- Core Verification Logic FIX ---

  void _startVerificationCheck() {
    _verificationTimer?.cancel();

    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.reload();

        final updatedUser = FirebaseAuth.instance.currentUser;

        if (updatedUser != null && updatedUser.emailVerified) {
          timer.cancel();
          state = state.copyWith(isVerified: true);

          ref.read(authStateProvider.notifier).handleAuthChange(updatedUser);

          _startRedirectCountdown();
          return;
        }
      }

      if (user == null) {
        timer.cancel();
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
      }
    });
  }

  //Future<void> _onVerificationSuccess() async {
  //  _verificationTimer?.cancel();
  //  state = state.copyWith(isVerified: true);
  //  final authRepo = ref.read(authRepositoryProvider);
  //  await authRepo.updateIsEmailVerified(authRepo.currentUser!.uid, true);

  //  _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
  //    if (state.dashboardCountdown > 0) {
  //      state = state.copyWith(
  //        dashboardCountdown: state.dashboardCountdown - 1,
  //      );
  //    } else {
  //      timer.cancel();
  //    }
  //  });
  //}

  // --- Cooldown Logic (Starts only on successful send) ---

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

  // --- Public Method ---

  Future<void> resendVerificationEmail() async {
    if (state.resendCooldown > 0 || state.isResending) return;

    state = state.copyWith(isResending: true);

    try {
      await ref.read(authRepositoryProvider).sendVerificationEmail();
      _startCooldown(); // Success: Start cooldown
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      rethrow;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isResending: false);
    }
  }

  Future<void> signOutAndNavigate() async {
    await ref.read(authRepositoryProvider).signOut();
    await FirebaseAuth.instance.signOut();
  }
}
