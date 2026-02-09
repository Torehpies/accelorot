import 'package:flutter/material.dart';
import 'registration_handlers.dart';

class MobileRegistrationView extends StatelessWidget {
  const MobileRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 16.0 + bottomInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kMaxFormWidth),
                  // Delegates the content rendering to the shared form
                  child: const RegistrationFormContent(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
