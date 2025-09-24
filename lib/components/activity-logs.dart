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
      width: 400,
      height: 190,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18, // header size
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              // Straight line
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
