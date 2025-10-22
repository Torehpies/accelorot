// lib/frontend/screens/machine_detail_screen.dart
import 'package:flutter/material.dart';

class MachineDetailScreen extends StatelessWidget {
  final String machineName;
  final String productCode;
  final String userRole;
  final String date;

  const MachineDetailScreen({
    super.key,
    required this.machineName,
    required this.productCode,
    this.userRole = 'Admin',
    this.date = 'Aug-25-2025',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Machine Details',
          style: TextStyle(color: Colors.teal), // ✅ Teal title
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal, // Affects system icons if any
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.devices,
                        color: Colors.teal.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        machineName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal, // ✅ Teal name
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Product Code/ID:', productCode),
                const SizedBox(height: 12),
                _buildDetailRow('User Role:', userRole),
                const SizedBox(height: 12),
                _buildDetailRow('Date:', date),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey, // Keep label grey for readability
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.teal, // ✅ Teal value
            ),
          ),
        ),
      ],
    );
  }
}