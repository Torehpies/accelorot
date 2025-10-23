import 'package:flutter/material.dart';

/// A standardized button for signing in using Google.
///
/// This widget handles the look and feel of the button, taking in
/// an [onPressed] callback and an [isLoading] state from the parent.
class GoogleSignInButton extends StatelessWidget {
  /// The callback function to be executed when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether a sign-in operation is currently in progress.
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  // A publicly accessible URL for the Google logo to use as a widget icon.
  static const String _googleLogoUrl =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/48px-Google_%22G%22_logo.svg.png';

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 60;
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,

        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 1,
          padding: EdgeInsets.zero, // Remove default padding to center image
        ),
        child: isLoading
            ? const SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.blue,
                  ), // Using blue for Google-like loader
                ),
              )
            : Image.asset(
                'assets/images/google_logo_sq.png',
                height: buttonSize,
                width: buttonSize,
                // Add a fallback in case the network image fails to load
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.g_mobiledata, // Fallback icon
                    color: Colors.red,
                    size: buttonSize,
                  );
                },
              ),
      ),
    );
  }
}
