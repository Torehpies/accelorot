import 'package:flutter/material.dart';
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
          flex: 2,
          child: Container(
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
                      'ACCEL-O-ROT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 68,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Where rot meets acceleration eme.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 80),
                    Icon(Icons.lock_outline, color: Colors.white, size: 100),
                  ],
                ),
              ),
            ),
          ),
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

