// lib/web/operator/screens/web_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/dashboard/add_waste/add_waste_product.dart';

import '../components/stat_card.dart';
import '../components/environmental_sensors_card.dart';
import '../components/system_card.dart';
import '../components/composting_progress_card.dart';

class WebHomeScreen extends StatelessWidget {
  final String? viewingOperatorId;

  const WebHomeScreen({super.key, this.viewingOperatorId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1400),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ROW 1: STAT CARDS - Fixed height
                    if (isDesktop)
                      SizedBox(
                        height: 100,
                        child: Row(
                          children: [
                            const Expanded(child: StatCard(title: 'Total Machines', value: '10', icon: Icons.factory)),
                            const SizedBox(width: 16),
                            const Expanded(child: StatCard(title: 'Total Admin', value: '10', icon: Icons.person)),
                            const SizedBox(width: 16),
                            const Expanded(child: StatCard(title: 'Total User', value: '10', icon: Icons.person_outline)),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: const [
                          StatCard(title: 'Total Machines', value: '10', icon: Icons.factory),
                          SizedBox(height: 12),
                          StatCard(title: 'Total Admin', value: '10', icon: Icons.person),
                          SizedBox(height: 12),
                          StatCard(title: 'Total User', value: '10', icon: Icons.person_outline),
                        ],
                      ),
                    const SizedBox(height: 16),

                    // ROW 2: ENVIRONMENTAL + SYSTEM - Flexible
                    Expanded(
                      flex: 2,
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: const [
                                Expanded(flex: 2, child: EnvironmentalSensorsCard()),
                                SizedBox(width: 16),
                                Expanded(flex: 1, child: SystemCard()),
                              ],
                            )
                          : Column(
                              children: const [
                                Expanded(child: EnvironmentalSensorsCard()),
                                SizedBox(height: 16),
                                Expanded(child: SystemCard()),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),

                    // ROW 3: COMPOSTING PROGRESS - Flexible
                    const Expanded(
                      flex: 1,
                      child: CompostingProgressCard(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => const AddWasteProduct(),
          );

          if (result != null) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Waste entry added successfully!'),
                backgroundColor: Colors.teal,
              ),
            );
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}