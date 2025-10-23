// login_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/sess_service.dart'; // Adjust path if needed

class LoginController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Callbacks
  void Function(bool)? onLoadingChanged;
  void Function(bool)? onPasswordVisibilityChanged;
  void Function(Map<String, dynamic>)? onLoginSuccess;
  void Function(String)? onLoginError;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;

  void setIsLoading(bool value) {
    _isLoading = value;
    onLoadingChanged?.call(value);
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    onPasswordVisibilityChanged?.call(_obscurePassword);
  }

  void setCallbacks({
    required void Function(bool) onLoadingChanged,
    required void Function(bool) onPasswordVisibilityChanged,
    required void Function(Map<String, dynamic>) onLoginSuccess,
    required void Function(String) onLoginError,
  }) {
    this.onLoadingChanged = onLoadingChanged;
    this.onPasswordVisibilityChanged = onPasswordVisibilityChanged;
    this.onLoginSuccess = onLoginSuccess;
    this.onLoginError = onLoginError;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> handleForgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      onLoginError?.call('Please enter your email to reset password.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      onLoginError?.call('Password reset email sent. Check your inbox.');
    } on FirebaseException catch (e) {
      String msg = e.message ?? 'Failed to send password reset email.';
      if (e.code == 'user-not-found') {
        msg = 'No account found with this email.';
      }
      onLoginError?.call(msg);
    } catch (e) {
      onLoginError?.call('An unexpected error occurred. Please try again.');
    }
  }

  // 🔑 CORE LOGIN METHOD — SAFE FOR WEB
  Future<void> loginUser() async {
    if (formKey.currentState?.validate() != true) return;

    setIsLoading(true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = userCredential.user!;
      
      // If email not verified, trigger verification flow
      if (!user.emailVerified) {
        onLoginSuccess?.call({'needsVerification': true});
        return;
      }

      // Fetch additional user data (e.g., from Firestore or your backend)
      final SessionService session = SessionService();
      final userData = await session.getCurrentUserData(); // Adjust if needed

      if (userData == null) {
        onLoginError?.call('User data not found. Please contact support.');
        return;
      }

      onLoginSuccess?.call({
        'needsVerification': false,
        'userData': userData,
      });

    } on FirebaseException catch (e) {
      // ✅ SAFE: Only use e.message (String), never raw e
      String errorMessage = e.message ?? 'Login failed. Please try again.';

      // Map common Firebase Auth error codes to friendly messages
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Try again later.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Sign-in method is temporarily disabled.';
          break;
        default:
          // Keep generic message for unknown errors
          break;
      }

      onLoginError?.call(errorMessage);

    } catch (e) {
      // Handle non-Firebase errors (e.g., network, session service failure)
      onLoginError?.call('An unexpected error occurred. Please try again.');
    } finally {
      setIsLoading(false);
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}