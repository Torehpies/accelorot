import 'package:flutter/material.dart';
import 'registration_handlers.dart';

class DesktopRegistrationView extends StatelessWidget {
  final RegistrationHandlers handlers;
  const DesktopRegistrationView({super.key, required this.handlers});

  // Reuses the login screen's branding structure for consistency
  Widget _buildBranding() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade600, Colors.teal.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JOIN US',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 68,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Create your account to start accelerating.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 80),
              Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 100),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Side: Branding and Contextual Information (same flex ratio as login)
        Expanded(
          flex: 2,
          child: _buildBranding(),
        ),

        // Right Side: The Form Area
        Expanded(
          flex: 3,
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
