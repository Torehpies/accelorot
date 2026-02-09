import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/registration/widgets/registration_left_panel.dart';
import 'registration_handlers.dart';

class DesktopRegistrationView extends StatelessWidget {
  const DesktopRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Side: Shared Auth Panel (match login)
        const Expanded(flex: 3, child: RegistrationLeftPanel()),

        // Right Side: The Form Area
        Expanded(
          flex: 4,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
                child: RegistrationFormContent(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
