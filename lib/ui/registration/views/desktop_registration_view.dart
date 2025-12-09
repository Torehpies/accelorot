import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/registration/widgets/registration_web_branding.dart';
import 'registration_handlers.dart';

class DesktopRegistrationView extends StatelessWidget {
  final RegistrationHandlers handlers;
  const DesktopRegistrationView({super.key, required this.handlers});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Side: Branding and Contextual Information (same flex ratio as login)
        Expanded(
          flex: 3,
          child: RegistrationWebBranding(),
        ),

        // Right Side: The Form Area
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxFormWidth),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  // Delegates the content rendering to the shared form
                  child: RegistrationFormContent(handlers: handlers, isDesktop: true),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
