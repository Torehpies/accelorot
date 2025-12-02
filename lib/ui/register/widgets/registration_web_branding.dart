import 'package:flutter/material.dart';

class RegistrationWebBranding extends StatelessWidget {
  const RegistrationWebBranding({super.key});

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              SizedBox(height: 80),
              Icon(
                Icons.person_add_alt_1_outlined,
                color: Colors.white,
                size: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
