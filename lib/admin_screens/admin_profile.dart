import 'package:flutter/material.dart';

class AdminProfile extends StatelessWidget {
  const AdminProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 77, 68, 68),
      ),
      body: const Center(
        child: Text(
          'Admin Profile Content',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}