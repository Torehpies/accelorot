// lib/ui/activity_logs/view/activity_logs_main_view.dart

import 'package:flutter/material.dart';
import '../widgets/mobile/activity_section_card.dart';
import '../widgets/mobile/navigation_section_card.dart';
import '../widgets/mobile/batch_filter_section.dart';
import '../models/activity_filter_model.dart';

class ActivityLogsScreen extends StatelessWidget {
  const ActivityLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Removed the machine filter banner

              // Main content container with white background
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.grey.shade300, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Scrollable section cards area (behind)
                      Padding(
                        padding: const EdgeInsets.only(top: 70),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // All Activity Section
                              const NavigationSectionCard(
                                icon: Icons.history,
                                title: 'View All Activity',
                                route: '/all-activity',
                                // Removed focusedMachineId
                              ),
                              const SizedBox(height: 16),

                              // Substrate Section
                              const ActivitySectionCard(
                                icon: Icons.eco_outlined,
                                title: 'Substrate',
                                viewAllRoute: '/substrates',
                                // Removed focusedMachineId
                                filters: [
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
                              const ActivitySectionCard(
                                icon: Icons.warning_amber_outlined,
                                title: 'Alerts',
                                viewAllRoute: '/alerts',
                                // Removed focusedMachineId
                                filters: [
                                  FilterConfig(
                                    icon: Icons.thermostat,
                                    label: 'Temperature',
                                    filterValue: 'Temp',
                                    route: '/alerts',
                                    initialFilterArg: 'Temperature',
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
                                // Removed focusedMachineId
                              ),
                              const SizedBox(height: 16),

                              // Reports Section
                              const ActivitySectionCard(
                                icon: Icons.report_outlined,
                                title: 'Reports',
                                viewAllRoute: '/reports',
                                // Removed focusedMachineId
                                filters: [
                                  FilterConfig(
                                    icon: Icons.build,
                                    label: 'Maintenance',
                                    filterValue: 'Maintenance',
                                    route: '/reports',
                                    initialFilterArg: 'Maintenance',
                                  ),
                                  FilterConfig(
                                    icon: Icons.visibility,
                                    label: 'Observation',
                                    filterValue: 'Observation',
                                    route: '/reports',
                                    initialFilterArg: 'Observation',
                                  ),
                                  FilterConfig(
                                    icon: Icons.warning,
                                    label: 'Safety',
                                    filterValue: 'Safety',
                                    route: '/reports',
                                    initialFilterArg: 'Safety',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Batch filter header - positioned on top
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: BatchFilterSection(),
                      ),
                    ],
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