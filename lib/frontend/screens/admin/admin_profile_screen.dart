import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/auth_wrapper.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Ensure we leave the admin navigation stack and return to the auth flow.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _signOut(context),
        ),
      ),
      body: const Center(
        child: Text(
          "Admin Profile Screen",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
