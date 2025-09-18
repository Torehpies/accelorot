// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../utils/snackbar_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
/*************  ✨ Windsurf Command ⭐  *************/
/// Builds a scaffold with an app bar containing a logout button and a body
/// containing a centered column with a check circle icon, a welcome message, and
/// an elevated button to view the dashboard.
///
/// When the logout button is pressed, a snackbar is shown and the user is
/// navigated back to the root route after a delay of 800 milliseconds.
///
/// When the elevated button is pressed, a snackbar is shown with a message
/*******  d407cb3d-02da-463e-9023-7635c08185fc  *******/  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.check,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Accel-o-Rot!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'You are successfully logged in.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                showSnackbar(context, 'Feature coming soon!');
              },
              child: const Text('View Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}