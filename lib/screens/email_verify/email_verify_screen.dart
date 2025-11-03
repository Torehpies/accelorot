import 'package:flutter/material.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_application_1/screens/email_verify/email_verify_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        ? const EdgeInsets.all(40.0) // More padding on web
        : const EdgeInsets.all(24.0); // Less padding on mobile

    // 3. LISTEN for side effects (using ref.listen)
    ref.listen<EmailVerifyState>(emailVerifyProvider, (
      previous,
      current,
    ) {
      // Handle success navigation/snackbar
      if (!previous!.isVerified && current.isVerified) {
        // NOTE: This call to showSnackbar inside ref.listen is the source of the warning
        // unless showSnackbar is implemented using a GlobalKey<ScaffoldMessengerState>.
        // Since we cannot see snackbar_utils.dart, we leave it as is,
        // but remember the best fix is in that utility file.
        showSnackbar(
          context,
          '🎉 Email successfully verified! Redirecting to Dashboard.',
        );
      }
      
      // Handle explicit sign-out (if the user was logged out during polling)
      if (ref.read(authRepositoryProvider).currentUser == null) {
        // Use a safe navigation method here, context is safe in this listener's scope.
        context.go('/signin');
      }
    });

    // --- UI Logic based on state ---
    return Scaffold(
      // The background color for web/large screens
      backgroundColor: isDesktop ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface,
      body: Center(
        child: Container(
          // Max width for the entire verification flow container
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: isDesktop ? 12 : 4, // Higher elevation on web for depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: cardPadding,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch, // **KEY for responsiveness**
                  children: [
                    if (state.isVerified) ...[
                      // 💚 VERIFIED UI
                      Icon(
                        Icons.check_circle_outline,
                        size: 96,
                        color: theme.colorScheme.primary, // Primary color for success
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
                        color: theme.colorScheme.secondary,
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
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 40),
                      
                      // Resend Email Button (Full Width)
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
                                    await notifier.resendVerificationEmail();
                                    // SAFEGURAD: Check if the widget is still mounted
                                    if (context.mounted) {
                                       showSnackbar(
                                        context,
                                        'New verification email sent to $email.',
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      showSnackbar(
                                        context,
                                        'Failed to send verification email. Try again later.',
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
                      TextButton(
                        onPressed: notifier.signOutAndNavigate,
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
