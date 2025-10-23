// lib/frontend/operator/web/web_home_screen.dart
import 'package:flutter/material.dart';
import '../../../frontend/components/system_card.dart';
import '../../../frontend/operator/dashboard/environmental_sensor/view_screens/environmental_sensors_view.dart';
import '../../../frontend/components/composting_progress_card.dart';
import '../../../frontend/operator/dashboard/add_waste/add_waste_product.dart';
import '../../../frontend/operator/dashboard/add_waste/activity_logs_card.dart';

class WebHomeScreen extends StatefulWidget {
  final String? viewingOperatorId;
  
  const WebHomeScreen({super.key, this.viewingOperatorId});

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  final GlobalKey<ActivityLogsCardState> _activityLogsKey =
      GlobalKey<ActivityLogsCardState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWideScreen ? 32 : 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: isWideScreen
                  ? _buildWideLayout()
                  : _buildNarrowLayout(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Waste',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Column(
      children: [
        // Top Row: Environmental Sensors + Progress
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: const EnvironmentalSensorsView(),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: CompostingProgressCard(batchStart: DateTime(2025, 9, 15)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Bottom Row: System Card + Activity Logs
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              flex: 1,
              child: SystemCard(),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: ActivityLogsCard(key: _activityLogsKey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const EnvironmentalSensorsView(),
        const SizedBox(height: 20),
        CompostingProgressCard(batchStart: DateTime(2025, 9, 15)),
        const SizedBox(height: 20),
        const SystemCard(),
        const SizedBox(height: 20),
        ActivityLogsCard(key: _activityLogsKey),
      ],
    );
  }
}