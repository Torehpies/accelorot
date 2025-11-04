// lib/web/operator/screens/web_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/dashboard/add_waste/add_waste_product.dart';
import '../components/environmental_sensors_card.dart';
import '../components/system_card.dart';
import '../components/composting_progress_card.dart';

class WebHomeScreen extends StatelessWidget {


  const WebHomeScreen({super.key});

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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade900],
            ),
          ),
        ),
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
                  vertical: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ROW 1: Environmental Sensors + System Card (side by side)
                      if (isDesktop)
                        SizedBox(
                          height: 280,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: const [
                              Expanded(
                                flex: 3,
                                child: EnvironmentalSensorsCard(),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: SystemCard(),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: const [
                            EnvironmentalSensorsCard(),
                            SizedBox(height: 16),
                            SystemCard(),
                          ],
                        ),
                      
                      const SizedBox(height: 16),

                      // ROW 2: Composting Progress
                      const CompostingProgressCard(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Waste',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}