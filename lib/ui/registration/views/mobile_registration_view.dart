import 'package:flutter/material.dart';
import 'registration_handlers.dart'; 

class MobileRegistrationView extends StatelessWidget {
  final RegistrationHandlers handlers;
  const MobileRegistrationView({super.key, required this.handlers});

  @override
  Widget build(BuildContext context) {
    // Uses SingleChildScrollView for keyboard safety on mobile
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: kMaxFormWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0, // Reduced vertical padding from login view
            ),
            // Delegates the content rendering to the shared form
            child: RegistrationFormContent(handlers: handlers),
          ),
        ),
      ),
    );
  }
}
