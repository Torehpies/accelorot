import 'package:flutter/material.dart';
import 'registration_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Login Screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RegistrationScreen(),
              ),
            );
          },
        ),
      ),
      body: const Center(
        child: Text("Profile Page", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
