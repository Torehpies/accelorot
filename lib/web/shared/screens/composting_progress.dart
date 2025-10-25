import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: unused_element
Widget _buildCompostingProgressCard() {
  final progress = 45.0; // % completion
  final startDate = DateTime(2025, 8, 30);
  final endDate = startDate.add(const Duration(days: 10));
  final daysLeft = endDate.difference(DateTime.now()).inDays;

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.recycling, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Text(
                'Composting Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Decomposition', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      minHeight: 12,
                    ),
                    const SizedBox(height: 8),
                    Text('$progress% Complete', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Batch Start: ${DateFormat('MMM dd, yyyy').format(startDate)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Est Completion: ${DateFormat('MMM dd, yyyy').format(endDate)} • $daysLeft days left',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
