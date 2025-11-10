// lib/frontend/operator/dashboard/home_screen.dart

import 'package:flutter/material.dart';
import 'cycles/system_card.dart';
import 'compost_progress/composting_progress_card.dart';
import 'compost_progress/models/compost_batch_model.dart';
import 'add_waste/add_waste_product.dart';
import 'add_waste/submit_report.dart';
import 'add_waste/quick_actions_sheet.dart';
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

  // Handle FAB press - show action sheet
  void _handleFABPress() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const QuickActionsSheet(),
    );

    if (action == null || !mounted) return;

    // Handle selected action
    if (action == 'add_waste') {
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
    } else if (action == 'submit_report') {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => SubmitReport(
          preSelectedMachineId: widget.focusedMachine?.machineId,
        ),
      );

      // Show confirmation AND refresh activity logs if report was submitted
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the activity logs to show the new report
        await _activityLogsKey.currentState?.refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMachineView = widget.focusedMachine != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: isMachineView,
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

              // ✅ Environmental Sensors section is PERMANENTLY REMOVED
              CompostingProgressCard(
                currentBatch: _currentBatch,
                onBatchStarted: _handleBatchStarted,
                onBatchCompleted: _handleBatchCompleted,
              ),

              const SizedBox(height: 16),

              SystemCard(currentBatch: _currentBatch),

              const SizedBox(height: 16),

              ActivityLogsCard(
                key: _activityLogsKey,
                focusedMachineId: widget.focusedMachine?.machineId,
              ),
              const SizedBox(height: 16),
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
            onPressed: _handleFABPress,
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
