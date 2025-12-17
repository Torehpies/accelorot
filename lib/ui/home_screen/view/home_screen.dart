// lib/frontend/operator/dashboard/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/dashboard/compost_progress/models/compost_batch_model.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';
import '../widgets/system_card.dart';
import '../widgets/composting_progress_card.dart';
import '../widgets/add_waste/add_waste_product.dart';
import '../widgets/add_waste/submit_report.dart';
import '../widgets/add_waste/quick_actions_sheet.dart';
import '../widgets/activity_logs_card.dart';


class HomeScreen extends StatefulWidget {
  final MachineModel? focusedMachine;

  const HomeScreen({super.key, this.focusedMachine});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ActivityLogsCardState> _activityLogsKey =
      GlobalKey<ActivityLogsCardState>();

  CompostBatch? _currentBatch;

  void _handleBatchStarted(CompostBatch batch) {
    if (mounted) setState(() => _currentBatch = batch);
  }

  void _handleBatchCompleted() {
    if (mounted) setState(() => _currentBatch = null);
  }

  Future<void> _handleFABPress() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const QuickActionsSheet(),
    );

    if (action == null || !mounted) return;

    switch (action) {
      case 'add_waste':
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => AddWasteProduct(
            preSelectedMachineId: widget.focusedMachine?.machineId,
          ),
        );
        if (result != null && mounted) {
          await _activityLogsKey.currentState?.refresh();
        }
        break;

      case 'submit_report':
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => SubmitReport(
            preSelectedMachineId: widget.focusedMachine?.machineId,
          ),
        );
        if (result != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report submitted successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          await _activityLogsKey.currentState?.refresh();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMachineView = widget.focusedMachine != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: isMachineView,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 800; // heuristic for desktop/web

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isMachineView)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE0F7FA), Color(0xFFB2DFDB)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_alt, color: Colors.teal.shade700, size: 20),
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

                  CompostingProgressCard(
                    currentBatch: _currentBatch,
                    onBatchStarted: _handleBatchStarted,
                    onBatchCompleted: _handleBatchCompleted,
                  ),
                  const SizedBox(height: 16),

                  SystemCard(currentBatch: _currentBatch),
                  const SizedBox(height: 16),

                  // ✅ Activity Logs — placed AFTER System Card, as requested
                  ActivityLogsCard(
                    key: _activityLogsKey,
                    focusedMachineId: widget.focusedMachine?.machineId,
                    maxHeight: isWeb ? null : 160, // Web: full scroll; Mobile: capped
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
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
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}