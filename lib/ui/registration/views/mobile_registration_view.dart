import 'package:flutter/material.dart';
import 'registration_handlers.dart';

class MobileRegistrationView extends StatelessWidget {
  const MobileRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight = constraints.maxHeight < 720;
        final isNarrow = constraints.maxWidth < 420;
        final form = Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kMaxFormWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: isCompactHeight ? 16.0 : 32.0,
              ),
              // Delegates the content rendering to the shared form
              child: RegistrationFormContent(
                compact: isCompactHeight,
                narrow: isNarrow,
              ),
            ),
          ),
        );

        return isCompactHeight
            ? SingleChildScrollView(
                child: form,
              )
            : form;
      },
    );
  }
}
