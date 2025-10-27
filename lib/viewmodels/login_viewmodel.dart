import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_entity.dart';
import 'package:flutter_application_1/repositories/user_repository.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/google_auth_result.dart';
import 'package:flutter_application_1/utils/login_flow_result.dart';
import 'package:flutter_application_1/utils/login_result.dart';

class LoginViewModel extends ChangeNotifier {
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _authService = AuthService();

  late final UserRepository _userRepository;
  LoginViewModel() {
    _userRepository = UserRepository(FirebaseFirestore.instance);
  }

  String? get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleForgotPassword() {
    // TODO
    _errorMessage = 'Forgot password is not yet implemented';
    notifyListeners();
  }

  Future<LoginFlowResult> loginUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signInUser(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      switch (result) {
        case LoginSuccess(uid: final uid):
          final userEntity = await _userRepository.fetchUserStatus(uid);

          if (userEntity == null) {
            _errorMessage = 'User data not found';
            return LoginFlowError(_errorMessage!);
          }

          return _mapEntityToFlowResult(userEntity);

        case LoginFailure(
          message: final message,
          needsVerification: final needsVerification,
        ):
          if (needsVerification) {
            return LoginFlowNeedsVerification(emailController.text.trim());
          }
          _errorMessage = message;
          return LoginFlowError(message);
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occured.';
      return LoginFlowError(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LoginFlowResult> signInWithGoogleAndCheckStatus() async {
    _errorMessage = null; // Clear previous errors

    try {
      final googleResult = await _authService.signInWithGoogle();

      switch (googleResult) {
        case GoogleLoginSuccess(uid: final uid):
          final userEntity = await _userRepository.fetchUserStatus(uid);

          if (userEntity == null) {
            _errorMessage = 'User data not found for Google user.';
            return LoginFlowError(_errorMessage!);
          }

          return _mapEntityToFlowResult(userEntity);

        case GoogleLoginFailure(message: final message):
          _errorMessage = message;
          return LoginFlowError(message);
      }
    } catch (e) {
      _errorMessage =
          'A critical Google sign-in error occurred: ${e.toString()}';
      return LoginFlowError(_errorMessage!);
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
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

    return LoginFlowNeedsReferral();
  }
}
