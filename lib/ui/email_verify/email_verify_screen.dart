import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/email_verify/email_verify_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/snackbar_utils.dart';
import 'email_verify_notifier.dart';

class EmailVerifyScreen extends ConsumerWidget {
  final String email;

  const EmailVerifyScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(emailVerifyProvider);
    final notifier = ref.read(emailVerifyProvider.notifier);
    final canResend = state.resendCooldown == 0;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    // Dynamic Padding based on screen size
    final cardPadding = isDesktop
        ? const EdgeInsets.all(40.0)
        : const EdgeInsets.all(24.0);

    ref.listen<EmailVerifyState>(emailVerifyProvider, (previous, current) {
      if (!previous!.isVerified && current.isVerified) {
        Future.microtask(() {
          showSnackbar(context, 'Email successfully verified!');
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Card(
            color: AppColors.background2,
            elevation: isDesktop ? 12 : 4, // Higher elevation on web for depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: cardPadding,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.isVerified) ...[
                      Icon(
                        Icons.check_circle_outline,
                        size: 96,
                        color: theme
                            .colorScheme
                            .primary, // Primary color for success
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Verification Complete!',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You are now fully verified and will be automatically redirected to your dashboard in:',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${state.dashboardCountdown}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ] else ...[
                      // 📧 PENDING UI
                      Icon(
                        Icons.email_outlined,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Verify Your Email Address',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'A verification link has been successfully sent to:',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Highlighted email address
                      Text(
                        email,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Please check your inbox (and spam folder!) and click the link to continue.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: state.isResending || !canResend
                              ? null
                              : () async {
                                  try {
                                    if (context.mounted) {
                                      await notifier.resendVerificationEmail();

                                      if (context.mounted) {
                                        showSnackbar(
                                          context,
                                          'New verification email sent to $email.',
                                        );
                                      }
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    if (context.mounted) {
                                      // Check for the specific Firebase rate limit error code
                                      if (e.code == 'too-many-requests') {
                                        showSnackbar(
                                          context,
                                          'Max send limit reached. Please wait a bit before sending another message.',
                                          isError: true,
                                        );
                                      } else {
                                        // Handle other FirebaseAuth errors gracefully
                                        showSnackbar(
                                          context,
                                          'Error: ${e.message}. Try again later.',
                                          isError: true,
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    // Handle generic errors (network, unknown)
                                    if (context.mounted) {
                                      showSnackbar(
                                        context,
                                        'An unexpected error occurred. Try again later.',
                                        isError: true,
                                      );
                                    }
                                  }
                                },
                          child: state.isResending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  canResend
                                      ? 'Resend Verification Email'
                                      : 'Resend in ${state.resendCooldown}s',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Back to login button
                      OutlinedButton(
                        onPressed: () => notifier.signOutAndNavigate,
                        child: const Text('Log Out and Go Back to Login'),
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
