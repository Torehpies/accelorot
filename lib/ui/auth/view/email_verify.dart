import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/snackbar_utils.dart';
import 'package:flutter_application_1/data/services/auth_service.dart';
import 'package:flutter_application_1/ui/auth/view_model/email_verification_view_model.dart';

/// Refactored to use Riverpod for state and logic management.
/// Keeps local Timer for Firebase polling which is tied to the widget's lifecycle.
class EmailVerifyScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerifyScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends ConsumerState<EmailVerifyScreen> {
  Timer? _verificationTimer;

  // Convenience getter to access the service via Riverpod ref
  AuthService get _authService => ref.read(authServiceProvider);

  @override
  void initState() {
    super.initState();
    // Start verification check immediately
    _startVerificationCheck();
  }

  @override
  void dispose() {
    // Clean up timer when the widget is removed from the tree
    _verificationTimer?.cancel();
    super.dispose();
  }

  /// Polling mechanism to check Firebase Auth status every 5 seconds.
  void _startVerificationCheck() {
    _verificationTimer?.cancel(); // Ensure only one timer is active
    
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // Use the dedicated check and navigate function
      await _checkAndNavigateOnVerification();
    });
  }

  /// Checks verification status, updates Firestore, and navigates on success.
  Future<void> _checkAndNavigateOnVerification() async {
    // Reloads Firebase User and checks status
    final isVerified = await _authService.isEmailVerified();
    
    if (isVerified) {
      _verificationTimer?.cancel(); // Stop polling

      if (!mounted) return;

      // 1. Update Firestore with verification status
      final user = _authService.getCurrentUser();
      if (user != null) {
        // Use the updated AuthService method
        await _authService.updateEmailVerificationStatus(user.uid, true);
      }

      // 2. Navigate to Main Navigation
      if (!mounted) return;
      showSnackbar('Email verified successfully!');
			context.go('/');
      //Navigator.of(context).pushReplacement(
      //  MaterialPageRoute(builder: (context) => const MainNavigation()),
      //);
    } else {
      // Only show a temporary snackbar if manually checking (from the button)
      // The periodic timer should fail silently if unverified.
      // This is the implementation for the manual check button click.
      
      // Since the button also calls this, we only show feedback if it's the 
      // result of a manual tap that failed. We can't differentiate here, so 
      // we'll rely on the VM/Service throwing an error for a cleaner flow. 
      // The original code was only for the manual check button. Let's keep the 
      // periodic check silent and let the button handle the feedback.
      // This function is now used by both the timer and the button, 
      // so we should slightly modify the timer's use to be silent.
      // For now, we revert the behavior for the button.
    }
  }

  /// Wrapper around the View Model's resend logic.
  Future<void> _resendVerifyEmail() async {
    final viewModel = ref.read(emailVerificationViewModelProvider.notifier);
    
    // Call the VM method, which handles its own loading state and cooldown
    final result = await viewModel.resendVerificationEmail();

    if (!mounted) return; 
    
    // Display the result message from the View Model
    showSnackbar(result['message'] as String, isError: !(result['success'] as bool));
  }

  /// Navigates back to the Login screen and signs out the user.
  void _navigateToLogin() {
    _verificationTimer?.cancel();
    _authService.signOut();
		context.go('/login');
//    Navigator.of(context).pushReplacement(
//      MaterialPageRoute(builder: (context) => const LoginScreen()),
//    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the ViewModel state for UI updates
    final verificationState = ref.watch(emailVerificationViewModelProvider);
    final isResending = verificationState.isResending;
    final cooldown = verificationState.cooldown;
    final canResend = cooldown == 0 && !isResending;
    
    // We keep the original _checkAndNavigateOnVerification function to be used for the manual check
    // button, but we rename it to be clearer on its dual role.
    Future<void> onManualCheck() async {
      await _checkAndNavigateOnVerification();
      if (!mounted) return;
      
      // If still here (not navigated away), show feedback that it's still unverified.
      // Note: This relies on `_authService.isEmailVerified()` reloading the user, which it does.
      final isStillVerified = await _authService.isEmailVerified();
       if (!isStillVerified) {
          if (!mounted) return;
          showSnackbar(
              'Email not yet verified. Please check your inbox.',
              isError: true,
            );
       }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email verification icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withValues(alpha: 0.3), 
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              const Text(
                'We\'ve sent a verification email to:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Manual check button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Use the manual check function
                  onPressed: onManualCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'I\'ve Verified My Email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Resend email button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Use Riverpod state for enabling/disabling the button
                  onPressed: canResend ? _resendVerifyEmail : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          // Use Riverpod state for button text
                          cooldown > 0
                              ? 'Resend in ${cooldown}s'
                              : 'Resend Verification Email',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Back to login button
              TextButton(
                onPressed: _navigateToLogin,
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

