import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
        ),
      ),
      body: const Center(
        child: Text("Profile Page", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
