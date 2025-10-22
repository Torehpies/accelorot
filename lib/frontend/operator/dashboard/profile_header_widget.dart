import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[800]!,
            Colors.green[400]!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // CircleAvatar removed
          Text(
            'Welcome!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}