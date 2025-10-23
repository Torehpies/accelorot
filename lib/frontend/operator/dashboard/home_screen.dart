// lib/frontend/operator/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../components/system_card.dart';
import '../dashboard/environmental_sensor/view_screens/environmental_sensors_view.dart';
import '../../components/composting_progress_card.dart';
import 'add_waste/add_waste_product.dart';
import 'add_waste/activity_logs_card.dart';

class HomeScreen extends StatefulWidget {
  final String? viewingOperatorId;
  
  const HomeScreen({super.key, this.viewingOperatorId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // GlobalKey to control and refresh the ActivityLogsCard widget
  final GlobalKey<ActivityLogsCardState> _activityLogsKey =
      GlobalKey<ActivityLogsCardState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Live Environmental Sensors Card
              const EnvironmentalSensorsView(),

              const SizedBox(height: 16),
              CompostingProgressCard(batchStart: DateTime(2025, 9, 15)),
              const SizedBox(height: 16),
              const SystemCard(),
              const SizedBox(height: 16),
              ActivityLogsCard(key: _activityLogsKey),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 16),
        child: SizedBox(
          width: 58,
          height: 58,
          child: FloatingActionButton(
            // Handles the FAB press to open the Add Waste Product dialog and refresh activity logs
            onPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => const AddWasteProduct(),
              );

              if (result != null && mounted) {
                await _activityLogsKey.currentState?.refresh();
              }
            },
            backgroundColor: Colors.teal,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
