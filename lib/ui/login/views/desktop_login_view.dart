import 'package:flutter/material.dart';
//import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/login/views/login_form.dart';
import 'package:flutter_application_1/ui/login/widgets/auth_left_panel.dart';

class DesktopLoginView extends StatelessWidget {
  const DesktopLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Side: Animated Onboarding Illustration
        Expanded(
          flex: 3,
          child: const AuthLeftPanel(),
        ),

        // Right Side: The Form Area
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxFormWidth),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: LoginForm(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
