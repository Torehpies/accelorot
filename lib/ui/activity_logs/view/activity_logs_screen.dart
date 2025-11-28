// lib/ui/activity_logs/activity_logs_screen.dart

import 'package:flutter/material.dart';
import '../widgets/activity_section_card.dart';
import '../widgets/navigation_section_card.dart';
import '../../../data/models/activity_filter_model.dart';

class ActivityLogsScreen extends StatelessWidget {
  const ActivityLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Activity Logs",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // All Activity Section
              const NavigationSectionCard(
                icon: Icons.history,
                title: 'View All Activity',
                route: '/all-activity',
              ),
              const SizedBox(height: 16),

              // Substrate Section
              ActivitySectionCard(
                icon: Icons.eco_outlined,
                title: 'Substrate',
                viewAllRoute: '/substrates',
                filters: const [
                  FilterConfig(
                    icon: Icons.eco,
                    label: 'Green',
                    filterValue: 'Greens',
                    route: '/substrates',
                    initialFilterArg: 'Greens',
                  ),
                  FilterConfig(
                    icon: Icons.energy_savings_leaf,
                    label: 'Brown',
                    filterValue: 'Browns',
                    route: '/substrates',
                    initialFilterArg: 'Browns',
                  ),
                  FilterConfig(
                    icon: Icons.recycling,
                    label: 'Compost',
                    filterValue: 'Compost',
                    route: '/substrates',
                    initialFilterArg: 'Compost',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Alerts Section
              ActivitySectionCard(
                icon: Icons.warning_amber_outlined,
                title: 'Alerts',
                viewAllRoute: '/alerts',
                filters: const [
                  FilterConfig(
                    icon: Icons.thermostat,
                    label: 'Temp',
                    filterValue: 'Temp',
                    route: '/alerts',
                    initialFilterArg: 'Temp',
                  ),
                  FilterConfig(
                    icon: Icons.water_drop,
                    label: 'Moisture',
                    filterValue: 'Moisture',
                    route: '/alerts',
                    initialFilterArg: 'Moisture',
                  ),
                  FilterConfig(
                    icon: Icons.bubble_chart,
                    label: 'Air Quality',
                    filterValue: 'Oxygen',
                    route: '/alerts',
                    initialFilterArg: 'Air Quality',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cycles & Recommendations Section
              const NavigationSectionCard(
                icon: Icons.auto_awesome,
                title: 'Cycles & Recommendations',
                route: '/cycles-recom',
              ),
            ],
          ),
        ),
      ),
    );
  }
}