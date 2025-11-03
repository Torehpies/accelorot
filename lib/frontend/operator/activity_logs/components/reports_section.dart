// lib/frontend/operator/activity_logs/components/reports_section.dart
import 'package:flutter/material.dart';
import '../widgets/filter_box.dart';

// Section card for report logs with filter boxes
class ReportsSection extends StatelessWidget {
  final String? focusedMachineId;

  const ReportsSection({
    super.key,
    this.focusedMachineId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header with title and view all button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.report_outlined,
                          color: Colors.teal.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Reports',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/reports');
                    },
                    child: Text(
                      'View All >',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Filter boxes for report types
              Expanded(
                child: Row(
                  children: [
                    FilterBox(
                      icon: Icons.build,
                      label: 'Maintenance',
                      filterValue: 'Maintenance',
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/reports',
                          arguments: {'initialFilter': 'Maintenance'},
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterBox(
                      icon: Icons.visibility,
                      label: 'Observation',
                      filterValue: 'Observation',
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/reports',
                          arguments: {'initialFilter': 'Observation'},
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterBox(
                      icon: Icons.warning,
                      label: 'Safety',
                      filterValue: 'Safety',
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/reports',
                          arguments: {'initialFilter': 'Safety'},
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}