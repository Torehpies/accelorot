import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/admin/admin_main_navigation.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Login Screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminMainNavigation()),
            );
          },
        ),
      ),
      body: Center(
        child: Text(
          "User Management Screen",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
