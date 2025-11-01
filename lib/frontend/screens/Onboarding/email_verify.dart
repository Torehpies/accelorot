import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/routes/router_notifier.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../utils/snackbar_utils.dart';
import 'package:go_router/go_router.dart';

class EmailVerifyScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerifyScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends ConsumerState<EmailVerifyScreen> {
  final AuthService _authService = AuthService();
  bool _isResendingEmail = false;
  bool _canResendEmail = true;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  Timer? _verificationTimer;
  bool _isVerified = false;
  int _dashboardCountdown = 3;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _onVerificationSuccess() {
    _verificationTimer?.cancel();

    if (!mounted) return;

    showSnackbar(
      context,
      '🎉 Email successfully verified! Redirecting to Dashboard.',
    );

    setState(() {
      _isVerified = true;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_dashboardCountdown > 0) {
        setState(() {
          _dashboardCountdown--;
        });
      } else {
        timer.cancel();

        final authListenable = ref.read(authListenableProvider.notifier);
        await authListenable.refreshUser();
      }
    });
  }

  void _startCooldown() {
    const int cooldownDuration = 60; // 60 seconds
    setState(() {
      _canResendEmail = false;
      _resendCooldown = cooldownDuration;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResendEmail = true;
        });
      }
    });
  }

  Future<void> _sendVerificationEmail({
    bool showSuccessSnackbar = false,
  }) async {
    if (!_canResendEmail) return;

    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) {
        showSnackbar(
          context,
          'User not logged in. Redirecting to login.',
          isError: true,
        );
        _navigateToLogin();
      }
      return;
    }

    setState(() => _isResendingEmail = true);
    try {
      await user.sendEmailVerification();
      if (mounted) {
        if (showSuccessSnackbar) {
          showSnackbar(
            context,
            'New verification email sent to ${widget.email}.',
          );
        }
        _startCooldown();
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(
          context,
          'Failed to send verification email. Try again later.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResendingEmail = false);
      }
    }
  }

  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      final user = _authService.currentUser;
      if (user != null) {
        // Reload the user to get the latest email verification status from Firebase
        await user.reload();

        if (user.emailVerified) {
          timer.cancel();

          _onVerificationSuccess();
          // Also update the Firestore field to ensure consistency
          await _authService.updateEmailVerificationStatus(user.uid, true);
          return;

          // if (mounted) {
          //   // Router will now handle the redirection based on the new AuthState
          //   context.go('/dashboard');
          // }
        }
      } else {
        // If the user logs out while on this screen
        timer.cancel();
        if (mounted) {
          context.go('/signin');
        }
      }
    });
  }

  /// Signs out the user and navigates to the login screen.
  void _navigateToLogin() async {
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      await container.read(authRepositoryProvider).signOut();
    } catch (_) {
      // Fallback to direct Firebase sign out (e.g., if GoogleSignIn signOut throws on web)
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isVerified) ...[
                      Icon(
                        Icons.check_circle_outline,
                        size: isDesktop ? 80 : 60,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Verification Complete!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You are now fully verified and will be automatically redirected to your dashboard in...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_dashboardCountdown',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      Icon(
                        Icons.email_outlined,
                        size: isDesktop ? 80 : 60,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Verify Your Email Address',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A verification link has been sent to:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Please click the link in your email to continue. You may need to check your spam folder.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Resend Email Button
                      SizedBox(
                        height: isDesktop ? 54 : 48,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isResendingEmail || !_canResendEmail
                              ? null
                              : () => _sendVerificationEmail(
                                  showSuccessSnackbar: true,
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 18 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isResendingEmail
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  _canResendEmail
                                      ? 'Resend Verification Email'
                                      : 'Resend in ${_resendCooldown}s',
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
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
