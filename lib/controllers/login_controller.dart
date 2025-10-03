import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class LoginController {
  final AuthService _authService = AuthService();
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  // State variables
  bool obscurePassword = true;
  bool isLoading = false;
  
  // Callback functions
  Function(bool)? onLoadingChanged;
  Function(bool)? onPasswordVisibilityChanged;
  Function()? onLoginSuccess;
  Function(String)? onLoginError;

  // Initialize callbacks
  void setCallbacks({
    Function(bool)? onLoadingChanged,
    Function(bool)? onPasswordVisibilityChanged,
    Function()? onLoginSuccess,
    Function(String)? onLoginError,
  }) {
    this.onLoadingChanged = onLoadingChanged;
    this.onPasswordVisibilityChanged = onPasswordVisibilityChanged;
    this.onLoginSuccess = onLoginSuccess;
    this.onLoginError = onLoginError;
  }


  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    onPasswordVisibilityChanged?.call(obscurePassword);
  }


  void setLoading(bool loading) {
    isLoading = loading;
    onLoadingChanged?.call(loading);
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


  Future<void> loginUser() async {
    if (formKey.currentState!.validate()) {
      setLoading(true);
      
      try {
        final result = await _authService.signInUser(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        setLoading(false);

        if (result['success']) {
          onLoginSuccess?.call();
        } else {
          onLoginError?.call(result['message']);
        }
      } catch (e) {
        setLoading(false);
        onLoginError?.call('An unexpected error occurred');
      }
    }
  }

  // Dispose controllers
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }


  void handleForgotPassword() {
    //
    //
    //
    onLoginError?.call('Forgot password feature is not yet implemented');
  }
}