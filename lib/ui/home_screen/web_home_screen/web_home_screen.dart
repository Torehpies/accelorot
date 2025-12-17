// lib/web/operator/screens/web_home_screen.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/add_waste/add_waste_product.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/add_waste/submit_report.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/view_model/compost_progress/composting_progress_card.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/view_model/compost_progress/compost_batch_model.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/cycles/drum_control_card.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/cycles/aerator_card.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/add_waste/activity_logs_card.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';

class WebHomeScreen extends StatefulWidget {
  final MachineModel? focusedMachine; 

  const WebHomeScreen({super.key, this.focusedMachine}); 

  @override
  State<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends State<WebHomeScreen> {
  final GlobalKey<ActivityLogsCardState> _activityLogsKey =
      GlobalKey<ActivityLogsCardState>();
  CompostBatch? _currentBatch;

  void _handleBatchStarted(CompostBatch batch) {
    setState(() => _currentBatch = batch);
  }

  void _handleBatchCompleted() {
    setState(() => _currentBatch = null);
  }

  void _handleFABPress() async {
    final action = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: 12,
          ),
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.add_circle_outline,
                    color: Colors.teal.shade700,
                    size: 24,
                  ),
                  title: const Text(
                    'Add Waste',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.of(context).pop('add_waste'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.note_add_outlined,
                    color: Colors.teal.shade700,
                    size: 24,
                  ),
                  title: const Text(
                    'Submit Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.of(context).pop('submit_report'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (action == null || !mounted) return;

    if (action == 'add_waste') {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AddWasteProduct(
          preSelectedMachineId: widget.focusedMachine?.machineId,
        ),
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waste entry added successfully!'),
            backgroundColor: Colors.teal,
          ),
        );
        await _activityLogsKey.currentState?.refresh();
      }
    } else if (action == 'submit_report') {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => SubmitReport(
          preSelectedMachineId: widget.focusedMachine?.machineId, 
        ),
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        await _activityLogsKey.currentState?.refresh();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left side - Batch Tracker and Recent Activity
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Fixed height for Composting Progress Card
                          SizedBox(
                            height: 360,
                            child: CompostingProgressCard(
                              currentBatch: _currentBatch,
                              onBatchStarted: _handleBatchStarted,
                              onBatchCompleted: _handleBatchCompleted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ActivityLogsCard(
                              key: _activityLogsKey,
                              focusedMachineId: widget.focusedMachine?.machineId,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right side - Drum Controller and Aerator Cards
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: DrumControlCard(currentBatch: _currentBatch),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: AeratorCard(currentBatch: _currentBatch),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleFABPress,
        backgroundColor: Colors.teal[800],
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }
}