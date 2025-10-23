import 'dart:async';

import 'package:flutter_application_1/data/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'email_verification_view_model.g.dart';  

/// State to manage the resend cooldown timer and loading state for the UI
class VerificationState {
  final int cooldown;
  final bool isResending;

  VerificationState({this.cooldown = 0, this.isResending = false});

  VerificationState copyWith({int? cooldown, bool? isResending}) {
    return VerificationState(
      cooldown: cooldown ?? this.cooldown,
      isResending: isResending ?? this.isResending,
    );
  }
}

/// A Riverpod Notifier to manage the email resend logic and cooldown timer.
@Riverpod(keepAlive: false)
class EmailVerificationViewModel extends _$EmailVerificationViewModel {
  Timer? _cooldownTimer;
  static const int _initialCooldown = 60; // 60 seconds

  @override
  VerificationState build() {
    // Cancel the timer when the provider is disposed (e.g., screen popped)
    ref.onDispose(() {
      _cooldownTimer?.cancel();
    });
    return VerificationState(cooldown: 0, isResending: false);
  }

  /// Attempts to resend the email verification link.
  Future<Map<String, dynamic>> resendVerificationEmail() async {
    // Guard clause: Prevent resend if currently loading or on cooldown
    if (state.cooldown > 0 || state.isResending) {
      return {
        'success': false,
        'message': 'Please wait for the cooldown to finish.'
      };
    }

    state = state.copyWith(isResending: true);
    final authService = ref.read(authServiceProvider);

    try {
      await authService.sendEmailVerify();
      _startResendCooldown();
      return {
        'success': true,
        'message': 'Verification email resent successfully. Check your inbox.'
      };
    } on EmailAlreadyVerifiedException catch (_) {
      // Specific handling for already verified state
      return {
        'success': false,
        'message':
            'Email is already verified. Tap "I\'ve Verified My Email" to proceed.',
      };
    } catch (e) {
      // General error handling
      return {
        'success': false,
        'message': 'Failed to resend email: ${e.toString()}'
      };
    } finally {
      // Always reset the loading state
      state = state.copyWith(isResending: false);
    }
  }

  /// Starts the 60-second timer and updates the state every second.
  void _startResendCooldown() {
    _cooldownTimer?.cancel();
    state = state.copyWith(cooldown: _initialCooldown);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.cooldown <= 1) {
        timer.cancel();
        state = state.copyWith(cooldown: 0); // Cooldown ends
      } else {
        state = state.copyWith(cooldown: state.cooldown - 1);
      }
    });
  }
}

