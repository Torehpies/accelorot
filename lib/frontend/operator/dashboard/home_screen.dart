// lib/frontend/operator/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'cycles/system_card.dart';
import '../dashboard/environmental_sensor/view_screens/environmental_sensors_view.dart';
import 'compost_progress/composting_progress_card.dart';
import 'compost_progress/models/compost_batch_model.dart';
import 'add_waste/add_waste_product.dart';
import 'add_waste/activity_logs_card.dart';
import '../machine_management/models/machine_model.dart';

class HomeScreen extends StatefulWidget {
  final MachineModel? focusedMachine;

  const HomeScreen({super.key, this.focusedMachine});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final bool isMachineView = widget.focusedMachine != null;

    return Scaffold(
      // ⭐ ALWAYS show AppBar (let MainNavigation handle hiding it if needed)
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading:
            isMachineView, // Show back button in machine view
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Machine Focus Banner
              if (isMachineView)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade50, Colors.teal.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        color: Colors.teal.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Filtered view • All data shown for this machine only',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ⭐ Show these cards regardless of machine view
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
              SystemCard(currentBatch: _currentBatch),

              const SizedBox(height: 16),

              // Activity Logs Card - Recent waste activities
              ActivityLogsCard(
                key: _activityLogsKey,
                focusedMachineId: widget.focusedMachine?.machineId,
              ),
              const SizedBox(height: 16),

              // It should only be shown in its own tab in MainNavigation
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
                  preSelectedMachineId: widget.focusedMachine?.machineId,
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
