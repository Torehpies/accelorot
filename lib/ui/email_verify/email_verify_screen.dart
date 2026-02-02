import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_application_1/ui/core/ui/outline_app_button.dart';
import 'package:flutter_application_1/ui/core/ui/primary_button.dart';
import 'package:flutter_application_1/ui/email_verify/email_verify_state.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'email_verify_notifier.dart';

class EmailVerifyScreen extends ConsumerWidget {
  final String email;

  const EmailVerifyScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(emailVerifyProvider);
    final notifier = ref.read(emailVerifyProvider.notifier);
    final canResend = state.resendCooldown > 0;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    // Dynamic Padding based on screen size
    final cardPadding = isDesktop
        ? const EdgeInsets.all(40.0)
        : const EdgeInsets.all(24.0);

    ref.listen<EmailVerifyState>(emailVerifyProvider, (previous, next) {
      final message = next.message;
      if (message == null) return;

      message.when(
        success: (text) => AppSnackbar.success(context, text),
        error: (text) => AppSnackbar.error(context, text),
      );

      ref.read(emailVerifyProvider.notifier).clearMessage();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: isDesktop ? 12 : 4,
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
                      const SizedBox(height: 32),
                    ] else ...[
                      Icon(
                        Icons.email_outlined,
                        size: 80,
                        color: AppColors.green100,
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
                          color: AppColors.green100,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Please check your inbox (and spam folder!) and click the link to continue.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        text: canResend
                            ? 'Resend in ${state.resendCooldown}s'
                            : 'Resend Verification Email',
                        onPressed: state.isResending || canResend
                            ? null
                            : notifier.resendVerificationEmail,
                        isLoading: state.isResending,
                        enabled: !canResend,
                      ),
                      const SizedBox(height: 16),

                      // Back to login button
                      OutlineAppButton(
                        onPressed: notifier.signOutAndNavigate,
                        text: 'Logout',
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
