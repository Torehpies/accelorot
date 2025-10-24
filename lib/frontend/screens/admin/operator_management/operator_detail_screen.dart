// lib/frontend/screens/admin/operator_management/operator_detail_screen.dart
import 'package:flutter/material.dart';
import 'operator_view_navigation.dart';

class OperatorDetailScreen extends StatelessWidget {
  final String operatorId;
  final String operatorName;
  final String role;
  final String email;
  final String dateAdded;

  const OperatorDetailScreen({
    super.key,
    required this.operatorId,
    required this.operatorName,
    this.role = 'Operator',
    this.email = 'operator@example.com',
    this.dateAdded = 'Aug-25-2025',
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
          'Operator Details',
          style: TextStyle(color: Colors.teal),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
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
                            Icons.person,
                            color: Colors.teal.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            operatorName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Role:', role),
                    const SizedBox(height: 12),
                    _buildDetailRow('Email:', email),
                    const SizedBox(height: 12),
                    _buildDetailRow('Date Added:', dateAdded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // View as Operator button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OperatorViewNavigation(
                        operatorId: operatorId,
                        operatorName: operatorName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View as Operator'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
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
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.teal,
            ),
          ),
        ),
      ],
    );
  }
}