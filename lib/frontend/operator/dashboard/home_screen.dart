// lib/frontend/operator/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'cycles/system_card.dart';
import '../dashboard/environmental_sensor/view_screens/environmental_sensors_view.dart';
import 'compost_progress/composting_progress_card.dart';
import 'compost_progress/models/compost_batch_model.dart';
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
  
  // State lifted from CompostingProgressCard - shared between cards
  CompostBatch? _currentBatch;

  // Callback when batch is started from CompostingProgressCard
  void _handleBatchStarted(CompostBatch batch) {
    setState(() {
      _currentBatch = batch;
    });
  }

  // Callback when batch is completed from CompostingProgressCard
  void _handleBatchCompleted() {
    setState(() {
      _currentBatch = null;
    });
  }
      
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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
              
              // Composting Progress Card - now receives batch and callbacks
              CompostingProgressCard(
                currentBatch: _currentBatch,
                onBatchStarted: _handleBatchStarted,
                onBatchCompleted: _handleBatchCompleted,
              ),
              
              const SizedBox(height: 16),
              
              // System Card - Drum rotation controls (receives current batch)
              SystemCard(
                currentBatch: _currentBatch,
              ),
              
              const SizedBox(height: 16),
              
              // Activity Logs Card - Recent waste activities
              ActivityLogsCard(
                key: _activityLogsKey,
                viewingOperatorId: widget.viewingOperatorId,
              ),
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
            onPressed: () async {
              // Open Add Waste Product dialog
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => AddWasteProduct(
                  viewingOperatorId: widget.viewingOperatorId,
                ),
              );

              // Refresh activity logs if waste was added
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