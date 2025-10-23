// lib/web/screens/web_profile_screen.dart

import 'package:flutter/material.dart';

class WebProfileScreen extends StatelessWidget {
  const WebProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Web Profile Screen')),
    );
  }
}