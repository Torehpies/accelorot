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
      width: double.infinity, // fill parent width
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon + text
              Row(
                children: const [
                  Icon(Icons.history, size: 26, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    "Activity Log",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Divider(thickness: 1, color: Colors.grey),

              const SizedBox(height: 12),

              // Sample log entries
              _buildLogItem(
                icon: Icons.error,
                iconColor: Colors.red,
                message: "Moisture levels have dropped below optimal range",
                time: "10:15",
              ),
              _buildLogItem(
                icon: Icons.warning,
                iconColor: Colors.orange,
                message: "Brown Matter Added",
                time: "09:45",
              ),
              _buildLogItem(
                icon: Icons.check_circle,
                iconColor: Colors.green,
                message: "This is a sample text for smart suggestions.",
                time: "09:30",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Helper widget for log entries
  static Widget _buildLogItem({
    required IconData icon,
    required Color iconColor,
    required String message,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
