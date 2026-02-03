import 'dart:async';
import 'package:flutter_application_1/data/providers/app_auth_state.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/ui/email_verify/email_verify_state.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'email_verify_notifier.g.dart';

@riverpod
class EmailVerifyNotifier extends _$EmailVerifyNotifier {
  StreamSubscription<bool>? _verificationSubscription;

  @override
  EmailVerifyState build() {
    _startVerificationPolling();

    ref.onDispose(() {
      _verificationSubscription?.cancel();
    });

    return const EmailVerifyState();
  }

  void _startVerificationPolling() {
    _verificationSubscription?.cancel();

    _verificationSubscription = Stream.periodic(const Duration(seconds: 3))
        .asyncMap((_) async {
          final auth = ref.read(firebaseAuthProvider);
          final user = auth.currentUser;
          if (user == null) return false;

          await user.reload();
          return user.emailVerified;
        })
        .listen((isVerified) {
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
    if (state.isResending || state.resendCooldown > 0) return;

    state = state.copyWith(isResending: true, message: null);

    final result = await ref
        .read(authRepositoryProvider)
        .resendVerificationEmail();
    result.when(
      success: (_) {
        state = state.copyWith(
          isResending: false,
          resendCooldown: 60,
          message: UiMessage.success("Verification email sent successfully!"),
        );
        _startCooldown();
      },
      failure: (error) {
        state = state.copyWith(
          isResending: false,
          message: UiMessage.error(error.userFriendlyMessage),
        );
      },
    );

    state = state.copyWith(isResending: false);
  }

  // if (e.code == 'too-many-requests') {
  //   showSnackbar(
  //     context,
  //     'Max send limit reached. Please wait a bit before sending another message.',
  //     isError: true,
  Future<void> signOutAndNavigate() async {
    await ref.read(authServiceProvider).signOut();
  }

  void _startCooldown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCooldown <= 0) {
        timer.cancel();
      } else {
        state = state.copyWith(resendCooldown: state.resendCooldown - 1);
      }
    });
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}
