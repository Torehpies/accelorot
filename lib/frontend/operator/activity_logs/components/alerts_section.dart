// lib/frontend/operator/activity_logs/components/alerts_section.dart
import 'package:flutter/material.dart';
import '../widgets/filter_box.dart';

// Section card for alert logs with filter boxes
class AlertsSection extends StatelessWidget {
  final String? focusedMachineId;

  const AlertsSection({
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
                      Icon(Icons.warning_amber_outlined,
                          color: Colors.teal.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Alerts',
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
                      Navigator.of(context).pushNamed('/alerts');
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

              // Filter boxes for alert types
              Expanded(
                child: Row(
                  children: [
                    FilterBox(
                      icon: Icons.thermostat,
                      label: 'Temp',
                      filterValue: 'Temp',
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/alerts',
                          arguments: {'initialFilter': 'Temp'},
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterBox(
                      icon: Icons.water_drop,
                      label: 'Moisture',
                      filterValue: 'Moisture',
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/alerts',
                          arguments: {'initialFilter': 'Moisture'},
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterBox(
                      icon: Icons.bubble_chart,
                      label: 'Air Quality',
                      filterValue: 'Oxygen',
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/alerts',
                          arguments: {'initialFilter': 'Air Quality'},
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