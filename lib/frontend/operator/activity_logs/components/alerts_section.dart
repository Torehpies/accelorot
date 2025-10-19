//alerts_section.dart
import 'package:flutter/material.dart';
import '../widgets/slide_page_route.dart';
import '../view_screens/alerts_screen.dart';
import '../widgets/filter_box.dart';

class AlertsSection extends StatelessWidget {
  const AlertsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_outlined,
                          color: Colors.grey, size: 20),
                      SizedBox(width: 8),
                      Text(
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
                        SlidePageRoute(page: const AlertsScreen()),
                      );
                    },
                    child: const Text(
                      'View All >',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
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
                  children: const [
                    FilterBox(
                      icon: Icons.thermostat,
                      label: 'Temp',
                      filterValue: 'Temp',
                      destination: AlertsScreen(initialFilter: 'Temp'),
                    ),
                    SizedBox(width: 8),
                    FilterBox(
                      icon: Icons.water_drop,
                      label: 'Moisture',
                      filterValue: 'Moisture',
                      destination: AlertsScreen(initialFilter: 'Moisture'),
                    ),
                    SizedBox(width: 8),
                    FilterBox(
                      icon: Icons.air,
                      label: 'Humidity',
                      filterValue: 'Humidity',
                      destination: AlertsScreen(initialFilter: 'Humidity'),
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