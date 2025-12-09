import 'dart:async';
import 'package:flutter_application_1/data/providers/app_auth_state.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/routes/router_notifier.dart';
import 'package:flutter_application_1/ui/email_verify/email_verify_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'email_verify_notifier.g.dart';

@riverpod
class EmailVerifyNotifier extends _$EmailVerifyNotifier {
  StreamSubscription<bool>? _verificationSubscription;

  @override
  EmailVerifyState build() {
    // Start polling email verification
    _startVerificationPolling();

    ref.onDispose(() {
      _verificationSubscription?.cancel();
    });

    return const EmailVerifyState();
  }

  void _startVerificationPolling() {
    _verificationSubscription?.cancel();

    // Poll every 3 seconds
    _verificationSubscription = Stream.periodic(const Duration(seconds: 3))
        .asyncMap((_) async {
      final auth = ref.read(firebaseAuthProvider);
      final user = auth.currentUser;
      if (user == null) return false;

      await user.reload(); // Force refresh
      return user.emailVerified;
    }).listen((isVerified) {
      if (isVerified) {
        _verificationSubscription?.cancel();
        state = state.copyWith(isVerified: true);

        // Invalidate providers to refresh auth state
        ref.invalidate(authStateChangesProvider);
        ref.invalidate(appUserProvider);
        ref.invalidate(authStateModelProvider);

        // Notify GoRouter to refresh redirect
        // ref.read(routerNotifierProvider).notifyListeners();
      }
    });
  }

  Future<void> resendVerificationEmail() async {
    if (state.isResending) return;

    state = state.copyWith(isResending: true);

    final result = await ref.read(authRepositoryProvider).resendVerificationEmail();
    result.when(
      success: (_) {
        // Optionally show a success message
      },
      failure: (error) {
        // Optionally show an error message
      },
    );

    state = state.copyWith(isResending: false);
  }

  Future<void> signOutAndNavigate() async {
    await ref.read(authServiceProvider).signOut();
  }
}
