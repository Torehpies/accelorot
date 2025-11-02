// lib/frontend/operator/activity_logs/components/alerts_section.dart
import 'package:flutter/material.dart';
import '../widgets/slide_page_route.dart';
import '../view_screens/alerts_screen.dart';
import '../widgets/filter_box.dart';

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
      child: Container( // Replaced Card with Container to use BoxDecoration for shadow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          boxShadow: [ // ⭐ ADDED: Shadow styling from FilterBox
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
              // Header
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
                      Navigator.of(context).push(
                        SlidePageRoute(
                          page: AlertsScreen(

                            focusedMachineId: focusedMachineId, 
                          ),
                        ),
                      );
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

              // Boxes using unified FilterBox
              Expanded(
                child: Row(
                  children: [
                    FilterBox(
                      icon: Icons.thermostat,
                      label: 'Temperature',
                      filterValue: 'Temperature',
                      destination: AlertsScreen(
                        initialFilter: 'Temperature',
                        
                        focusedMachineId: focusedMachineId, 
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterBox(
                      icon: Icons.water_drop,
                      label: 'Moisture',
                      filterValue: 'Moisture',
                      destination: AlertsScreen(
                        initialFilter: 'Moisture',
                       
                        focusedMachineId: focusedMachineId,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterBox(
                      icon: Icons.bubble_chart,
                      label: 'Oxygen',
                      filterValue: 'Oxygen',
                      destination: AlertsScreen(
                        initialFilter: 'Oxygen',
                        
                        focusedMachineId: focusedMachineId,
                      ),
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