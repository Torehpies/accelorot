// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../components/activity-logs.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: const [
                Spacer(), // pushes card to the bottom
                ActivityLogs(title: "Activity Logs"),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
