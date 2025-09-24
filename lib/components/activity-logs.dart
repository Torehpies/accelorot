import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;

  const CustomCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // full width within parent constraints
      height: 190,
      child: Card(
        elevation: 10, // match splash screen elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // match splash screen rounding
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0), // match splash screen padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // Divider line
              const Divider(
                thickness: 1,
                color: Colors.grey,
              ),

              const SizedBox(height: 12),

              // Placeholder for alerts (Firestore data will go here later)
              const Expanded(
                child: Center(
                  child: Text(
                    "Alerts will appear here...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
