import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../utils/snackbar_utils.dart';
import 'package:flutter_application_1/frontend/operator/main_navigation.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/team_selection_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/waiting_approval_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/providers/auth_providers.dart';

class EmailVerifyScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerifyScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends ConsumerState<EmailVerifyScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
          //await _handlePostVerification(user.uid);
        }
      }
    });
  }

  Future<void> _handlePostVerification(String userId) async {
    if (!mounted) return;
    showSnackbar(context, 'Email verified successfully!');

    // Check if user selected a team during registration
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final pendingTeamSelection =
        userDoc.data()?['pendingTeamSelection'] as String?;

    if (pendingTeamSelection != null) {
      // Send team join request
      await _sendTeamJoinRequest(userId, pendingTeamSelection);

      // Clear the pending team selection
      await _firestore.collection('users').doc(userId).update({
        'pendingTeamSelection': FieldValue.delete(),
      });

      if (!mounted) return;
      // Navigate to waiting approval screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WaitingApprovalScreen()),
      );
    } else {
      // Check regular team status
      final status = await _authService.getUserTeamStatus(userId);
      final teamId = status['teamId'];
      final pendingTeamId = status['pendingTeamId'];

      if (!mounted) return;

      if (teamId != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else if (pendingTeamId != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const WaitingApprovalScreen(),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TeamSelectionScreen()),
        );
      }
    }
  }

  Future<void> _sendTeamJoinRequest(String userId, String teamId) async {
    try {
      final batch = _firestore.batch();

      // Add to pending_members subcollection
      final pendingRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .doc(userId);

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final email = userDoc.data()?['email'] as String? ?? '';

      batch.set(pendingRef, {
        'requestorId': userId,
        'requestorEmail': email,
        'requestedAt': FieldValue.serverTimestamp(),
      });

      // Set pendingTeamId in user document
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {'pendingTeamId': teamId});

      await batch.commit();
    } catch (e) {
      if (mounted) {
        showSnackbar(context, 'Failed to send team request', isError: true);
      }
    }
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

        //final authListenable = ref.read(authListenableProvider.notifier);
        //await authListenable.refreshUser();
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

  //  void _startVerificationCheck() {
  //    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (
  //      timer,
  //    ) async {
  //      final user = _authService.currentUser;
  //      if (user != null) {
  //        // Reload the user to get the latest email verification status from Firebase
  //        await user.reload();
  //
  //        if (user.emailVerified) {
  //          timer.cancel();
  //
  //          _onVerificationSuccess();
  //          // Also update the Firestore field to ensure consistency
  //          await _authService.updateEmailVerificationStatus(user.uid, true);
  //          return;
  //
  //          // if (mounted) {
  //          //   // Router will now handle the redirection based on the new AuthState
  //          //   context.go('/dashboard');
  //          // }
  //        }
  //      } else {
  //        // If the user logs out while on this screen
  //        timer.cancel();
  //        if (mounted) {
  //          context.go('/signin');
  //        }
  //      }
  //    });
  //  }
  //
  /// Signs out the user and navigates to the login screen.
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

  void _navigateToLogin() async {
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      await container.read(authRepositoryProvider).signOut();
    } catch (_) {
      // Fallback to direct Firebase sign out (e.g., if GoogleSignIn signOut throws on web)
      await FirebaseAuth.instance.signOut();
    }
  }

  Future<void> _checkVerificationStatus() async {
    bool isVerified = await _authService.isEmailVerified();
    if (!mounted) return;

    if (isVerified) {
      final user = _authService.getCurrentUser();
      if (user != null) {
        await _authService.updateEmailVerificationStatus(user.uid, true);
        await _handlePostVerification(user.uid);
      }
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
                      //TODO
                      //                      const Text(
                      //                        'Verification Complete!',
                      //                        textAlign: TextAlign.center,
                      //                        style: TextStyle(
                      //                          fontSize: 24,
                      //                          fontWeight: FontWeight.bold,
                      //                          color: Colors.green,

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
                                'After verification, you\'ll be directed to join a team or wait for approval if you selected one.',
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
                      SizedBox(height: isDesktop ? 32 : 24),

                      // Manual check button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _checkVerificationStatus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 18 : 16,
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
