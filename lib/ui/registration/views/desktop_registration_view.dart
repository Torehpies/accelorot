import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/registration/widgets/registration_web_branding.dart';
import 'registration_handlers.dart';

class DesktopRegistrationView extends StatelessWidget {
  const DesktopRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight = constraints.maxHeight < 760;
        final isNarrow = constraints.maxWidth < 980;
        final form = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxFormWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: isCompactHeight ? 12.0 : 28.0,
              ),
              child: RegistrationFormContent(
                compact: isCompactHeight,
                narrow: isNarrow,
              ),
            ),
          ),
        );

        return Row(
          children: [
            // Left Side: Branding and Contextual Information (same flex ratio as login)
            Expanded(flex: 3, child: RegistrationWebBranding()),

            // Right Side: The Form Area
            Expanded(
              flex: 4,
              child: isCompactHeight
                  ? SingleChildScrollView(
                      child: form,
                    )
                  : form,
            ),
          ],
        );
      },
    );
  }
}
