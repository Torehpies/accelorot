import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
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
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      bool isVerified = await _authService.isEmailVerified();
      if (isVerified && mounted) {
        timer.cancel();
        // Update Firestore with verification status
        final user = _authService.getCurrentUser();
        if (user != null) {
          await _authService.updateEmailVerificationStatus(user.uid, true);
        }
        
        if (!mounted) return; 
        showSnackbar(context, 'Email verified successfully!');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
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

    if (!mounted) return; // <--- Add this line
    setState(() => _isResendingEmail = false);
    showSnackbar(
      context,
      result['message'],
      isError: !result['success'],
    );
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
   // NEW: Manual check for verification
  Future<void> _checkVerificationStatus() async {
    bool isVerified = await _authService.isEmailVerified();
    if (isVerified && mounted) {
      final user = _authService.getCurrentUser();
      if (user != null) {
        await _authService.updateEmailVerificationStatus(user.uid, true);
      }
      
      if (!mounted) return; 
      showSnackbar(context, 'Email verified successfully!');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else {
      showSnackbar(context, 'Email not yet verified. Please check your inbox.', isError: true);
    }
  }

  
 @override
  Widget build(BuildContext context) {
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
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
              
              // NEW: Manual check button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkVerificationStatus,
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                            valueColor: AlwaysStoppedAnimation(Colors.white),
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
              const SizedBox(height: 32),
              
            ],
          ),
        ),
      ),
    );
  }
}