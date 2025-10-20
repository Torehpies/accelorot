import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // AuthWrapper will detect sign-out and redirect automatically
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
