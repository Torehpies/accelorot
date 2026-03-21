import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
          padding: EdgeInsets.zero,
					side: BorderSide.none
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
            : SvgPicture.asset(
                'assets/images/google_logo.svg',
                width: buttonSize,
                height: buttonSize,
                fit: BoxFit.contain,
                semanticsLabel: 'Google Logo',
              ),
      ),
    );
  }
}
