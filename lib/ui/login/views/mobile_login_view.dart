import 'package:flutter/material.dart';
import 'login_handlers.dart'; // Import the handlers and the shared form

class MobileLoginView extends StatelessWidget {
  final LoginHandlers handlers;
  const MobileLoginView({super.key, required this.handlers});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kMaxFormWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 80.0,
                    ),
                    child: LoginFormContent(handlers: handlers),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
