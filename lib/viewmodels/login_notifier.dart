import '../models/user_entity.dart';
import '../providers/service_providers.dart';
import '../utils/google_auth_result.dart';
import '../utils/login_flow_result.dart';
import '../utils/login_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_notifier.g.dart';

class LoginState {
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;

  const LoginState({
    this.isLoading = false,
    this.obscurePassword = true,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? obscurePassword,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  LoginState build() {
    return const LoginState();
  }

  void handleForgotPassword() {}

  Future<LoginFlowResult> loginUser({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final authService = ref.read(authServiceProvider);
    final userRepository = ref.read(userRepositoryProvider);

    try {
      final result = await authService.signInUser(
        email: email.trim(),
        password: password,
      );

      switch (result) {
        case LoginSuccess(uid: final uid):
          final userEntity = await userRepository.fetchUserStatus(uid);

          if (userEntity == null) {
            state = state.copyWith(errorMessage: 'User data not found');
            return LoginFlowError('User data not found');
          }

          return _mapEntityToFlowResult(userEntity);

        case LoginFailure(
          message: final message,
          needsVerification: final needsVerification,
        ):
          if (needsVerification) {
            return LoginFlowNeedsVerification(email);
          }
          state = state.copyWith(errorMessage: message);
          return LoginFlowError(message);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Unexpected error occurred');
      return LoginFlowError('Unexpected error occurred');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<LoginFlowResult> signInWithGoogleAndCheckStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final authService = ref.read(authServiceProvider);
    final userRepository = ref.read(userRepositoryProvider);

    try {
      final googleResult = await authService.signInWithGoogle();

      switch (googleResult) {
        case GoogleLoginSuccess(uid: final uid):
          final userEntity = await userRepository.fetchUserStatus(uid);

          if (userEntity == null) return LoginFlowError('User data not found');

          return _mapEntityToFlowResult(userEntity);

        case GoogleLoginFailure(message: final message):
          return LoginFlowError(message);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Unexpected Google sign-in');
      return LoginFlowError('Unexpected Google sign-in');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    return value == null || value.isEmpty ? 'Password is required' : null;
  }

  LoginFlowResult _mapEntityToFlowResult(UserEntity user) {
    if (user.isAdmin) {
      return LoginFlowSuccessAdmin();
    }

    if (user.isRestricted) {
      final reason = user.isArchived ? 'archived' : 'left';
      return LoginFlowRestricted(reason);
    }

    if (user.teamId != null) {
      return LoginFlowSuccess();
    }

    if (user.pendingTeamId != null) {
      return LoginFlowPendingApproval();
    }

    return LoginFlowError(
      'Unable to determine user status. Please contact support.',
    );
  }
}
