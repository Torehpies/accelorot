import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/routes/router_notifier.dart';
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
      resendCooldown: _cooldownDuration,
    );

    Future.microtask(() {
      _startVerificationCheck();
      _startCooldown();
    });

    ref.onDispose(() {
      _cooldownTimer?.cancel();
      _verificationTimer?.cancel();
      _redirectTimer?.cancel();
    });

    return initialState;
  }

  // --- Core Verification Logic (from _startVerificationCheck) ---

  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final authRepo = ref.read(authRepositoryProvider);

      // Check if user exists (handles user logging out)
      if (authRepo.currentUser == null) {
        _verificationTimer?.cancel();
        // The View needs to handle navigation if state becomes null/invalid
        return;
      }

      final isVerified = await authRepo.checkAndReloadEmailVerified();

      if (isVerified) {
        // Verification success!
        _onVerificationSuccess();
        // Optional: Update Firestore field here if needed
        // await authRepo.updateEmailVerificationStatus(authRepo.currentUser!.uid, true);
      }
    });
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCooldown > 0) {
        // This is safe because state is initialized
        state = state.copyWith(resendCooldown: state.resendCooldown - 1);
      } else {
        timer.cancel();
        state = state.copyWith(resendCooldown: 0);
      }
    });
  }

  void _onVerificationSuccess() {
    // Stop the verification polling
    _verificationTimer?.cancel();

    // Set the state to verified
    state = state.copyWith(isVerified: true);

    // Start the dashboard redirect countdown timer
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (state.dashboardCountdown > 0) {
        state = state.copyWith(
          dashboardCountdown: state.dashboardCountdown - 1,
        );
      } else {
        // Redirect logic here
        timer.cancel();

        // Notify the AuthListenable to refresh its state (GoRouter logic)
        final authListenable = ref.read(authListenableProvider.notifier);
        await authListenable.refreshUser();
      }
    });
  }

  // --- Cooldown Logic (from _startCooldown) ---

  void _startCooldown() {
    // Cancel existing timer just in case
    _cooldownTimer?.cancel();

    // Set initial cooldown state
    state = state.copyWith(resendCooldown: _cooldownDuration);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCooldown > 0) {
        state = state.copyWith(resendCooldown: state.resendCooldown - 1);
      } else {
        timer.cancel();
        state = state.copyWith(resendCooldown: 0); // Cooldown finished
      }
    });
  }

  // --- Public Methods (for the View to call) ---

  // Public method to resend the email
  Future<void> resendVerificationEmail() async {
    if (state.resendCooldown > 0 || state.isResending) return;

    state = state.copyWith(isResending: true);
    try {
      await ref.read(authRepositoryProvider).sendVerificationEmail();
      // Only start cooldown and show snackbar upon successful send
      _startCooldownTimer();
      // The View will handle the snackbar based on success
    } catch (e) {
      // The View will handle the snackbar based on error
      rethrow;
    } finally {
      state = state.copyWith(isResending: false);
    }
  }

  // Public method for the "Back to Login" button
  Future<void> signOutAndNavigate() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (_) {
			await FirebaseAuth.instance.signOut();
		}
  }
}
