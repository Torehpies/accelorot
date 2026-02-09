import 'package:flutter/material.dart';
import 'registration_handlers.dart';

/// Tablet view for registration (800px - 999px width)
/// Shows a simplified layout without the decorative left panel
class TabletRegistrationView extends StatelessWidget {
  const TabletRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.0, 6.0, 24.0, 20.0 + bottomInset),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: RegistrationFormContent(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
