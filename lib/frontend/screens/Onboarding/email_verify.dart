import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'dart:async';
import '../../../utils/snackbar_utils.dart';
import 'package:flutter_application_1/screens/login/login_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/qr_refer.dart';
import 'package:go_router/go_router.dart';

class EmailVerifyScreen extends StatefulWidget {
  final String email;

  const EmailVerifyScreen({super.key, required this.email});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  final AuthService _authService = AuthService();
  bool _isResendingEmail = false;
  bool _canResendEmail = true;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  Timer? _verificationTimer;

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

  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      bool isVerified = await _authService.isEmailVerified();
      if (isVerified && mounted) {
        timer.cancel();
        final user = _authService.getCurrentUser();
        if (user != null) {
          await _authService.updateEmailVerificationStatus(user.uid, true);
        }

        if (!mounted) return;
        showSnackbar(context, 'Email verified successfully!');

        // Determine team status and route accordingly
        final userObj = _authService.getCurrentUser();
        if (userObj == null) return;
        final status = await _authService.getUserTeamStatus(userObj.uid);
        final teamId = status['teamId'];
        final pendingTeamId = status['pendingTeamId'];

        if (!mounted) return;

        if (teamId != null) {
          context.go('/dashboard');
        } else if (pendingTeamId != null) {
          context.go('/pending-approval');
        } else {
          context.go('/referral');
        }
      }
    });
  }

  Future<void> _resendVerifyEmail() async {
    if (!_canResendEmail) return;

    setState(() {
      _isResendingEmail = true;
      _canResendEmail = false;
      _resendCooldown = 60;
    });
    final result = await _authService.sendEmailVerify();

    if (!mounted) return;
    setState(() => _isResendingEmail = false);
    showSnackbar(context, result['message'], isError: !result['success']);
    if (result['success']) {
      _startResendCooldown();
    } else {
      setState(() {
        _canResendEmail = true;
      });
    }
  }

  void _startResendCooldown() {
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) {
            _canResendEmail = true;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _navigateToLogin() {
    _verificationTimer?.cancel();
    _authService.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _checkVerificationStatus() async {
    bool isVerified = await _authService.isEmailVerified();
    if (!mounted) return;

    if (isVerified) {
      final user = _authService.getCurrentUser();
      if (user != null) {
        await _authService.updateEmailVerificationStatus(user.uid, true);
      }

      if (!mounted) return;
      showSnackbar(context, 'Email verified successfully!');

      // Redirect to QR referral screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const QRReferScreen()),
      );
    } else {
      showSnackbar(
        context,
        'Email not yet verified. Please check your inbox.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isWideScreen ? 32 : 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: isWideScreen ? 8 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isWideScreen ? 40 : 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Email verification icon
                      Container(
                        width: isWideScreen ? 120 : 100,
                        height: isWideScreen ? 120 : 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade400,
                              Colors.teal.shade700,
                            ],
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
                        child: Icon(
                          Icons.email_outlined,
                          size: isWideScreen ? 48 : 40,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isWideScreen ? 32 : 24),

                      Text(
                        'Verify Your Email',
                        style: TextStyle(
                          fontSize: isWideScreen ? 28 : 24,
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
                      const SizedBox(height: 24),

                      // Info box about next steps
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'After verification, you\'ll need to scan or enter a team invitation code.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isWideScreen ? 32 : 24),

                      // Manual check button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _checkVerificationStatus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isWideScreen ? 18 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'I\'ve Verified My Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Resend email button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canResendEmail && !_isResendingEmail
                              ? _resendVerifyEmail
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isWideScreen ? 18 : 16,
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
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
