import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class RegistrationWebBranding extends StatelessWidget {
  const RegistrationWebBranding({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background2, AppColors.background1],
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
                  color: AppColors.green100,
                  fontSize: 68,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Create your account to start accelerating.',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
              ),
              SizedBox(height: 80),
              Icon(
                Icons.person_add_alt_1_outlined,
                color: AppColors.green100,
                size: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
