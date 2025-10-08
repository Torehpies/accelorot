import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/snackbar_utils.dart';
import 'login_screen.dart';
import 'package:flutter_application_1/frontend/screens/main_navigation.dart';

class EmailVerifyScreen extends StatefulWidget {
  final String email;

  const EmailVerifyScreen({super.key, required this.email});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  bool _isResendingEmail = false;
  bool _canResendEmail = true;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _resendVerifyEmail() async {
    if (!_canResendEmail) return;

    setState(() {
      _isResendingEmail = true;
      _canResendEmail = false;
      _resendCooldown = 60;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isResendingEmail = false);
      showSnackbar(context, 'Verification email sent!');
      _startResendCooldown();
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _simulateEmailVerified() {
    showSnackbar(context, 'Email verified!');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email_outlined, size: 48, color: Colors.teal),
              const SizedBox(height: 16),
              Text('Verify your email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.email, style: TextStyle(color: Colors.teal)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _simulateEmailVerified,
                child: const Text('Email Verified'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _canResendEmail && !_isResendingEmail ? _resendVerifyEmail : null,
                child: _isResendingEmail
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_canResendEmail ? 'Resend Email' : 'Resend in ${_resendCooldown}s'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _navigateToLogin,
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
