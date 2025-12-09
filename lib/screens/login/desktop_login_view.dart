import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'login_handlers.dart';

class DesktopLoginView extends StatelessWidget {
  final LoginHandlers handlers;
  const DesktopLoginView({super.key, required this.handlers});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Side: Branding and Contextual Information
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
								begin: Alignment.topCenter,
								end: Alignment.bottomCenter,
                colors: [
                  AppColors.background2,
                  AppColors.background1,
                ],
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
                      'ACCEL-O-ROT',
                      style: TextStyle(
                        color: AppColors.green100,
                        fontSize: 68,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Where rot meets acceleration.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 80),
                    Icon(
                      Icons.lock_outline,
                      color: AppColors.green100,
                      size: 100,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                  child: LoginFormContent(handlers: handlers, isDesktop: true),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
