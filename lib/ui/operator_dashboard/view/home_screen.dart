import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/add_waste/quick_actions_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/compost_batch_model.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/add_waste/add_waste_product.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/submit_report/submit_report.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/batch_management/composting_progress_card.dart';

import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/swipeable_cycle_cards.dart';

import 'package:flutter_application_1/ui/admin_dashboard/web_widgets/recent_activities_table.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/batch_management/batch_start_dialog.dart';
import 'package:flutter_application_1/data/providers/batch_providers.dart';
import 'package:flutter_application_1/data/providers/activity_providers.dart';
import 'package:flutter_application_1/data/models/batch_model.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/mobile_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final MachineModel? focusedMachine;

  const HomeScreen({super.key, this.focusedMachine});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  CompostBatch? _currentBatch;
  String? _selectedMachineId;
  String? _selectedBatchId;
  BatchModel? _activeBatchModel;

  // Add this to force widget rebuilds
  int _rebuildKey = 0;

  @override
  void initState() {
    super.initState();
    _selectedMachineId = widget.focusedMachine?.machineId;
  }

  void _updateActiveBatch(BatchModel? batch) {
    debugPrint('🔄 _updateActiveBatch called with batch: ${batch?.id}');

    if (mounted) {
      setState(() {
        _activeBatchModel = batch;
        _selectedBatchId = batch?.id;
        // Increment rebuild key to force cards to rebuild
        _rebuildKey++;

        if (batch != null) {
          _selectedMachineId = batch.machineId;
          _currentBatch = CompostBatch(
            batchName: batch.displayName,
            batchNumber: batch.id,
            startedBy: null,
            batchStart: batch.createdAt,
            startNotes: batch.startNotes,
            status: batch.isActive ? 'active' : 'completed',
          );
        } else {
          _currentBatch = null;
        }
      });
    }

    debugPrint('✅ _updateActiveBatch completed - rebuildKey: $_rebuildKey');
  }

  Future<void> _autoSelectBatchForMachine(String machineId) async {
    // Wait for provider to refresh
    await Future.delayed(const Duration(milliseconds: 500));

    final batchesAsync = ref.read(userTeamBatchesProvider);
    batchesAsync.whenData((batches) {
      final machineBatches = batches
          .where((b) => b.machineId == machineId)
          .toList();

      if (machineBatches.isNotEmpty) {
        // Sort by createdAt to get newest
        machineBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final latestBatch = machineBatches.first;

        if (mounted) {
          setState(() {
            _selectedBatchId = latestBatch.id;
            _activeBatchModel = latestBatch;
            _currentBatch = CompostBatch(
              batchName: latestBatch.displayName,
              batchNumber: latestBatch.id,
              startedBy: null,
              batchStart: latestBatch.createdAt,
              startNotes: latestBatch.startNotes,
              status: latestBatch.isActive ? 'active' : 'completed',
            );
            _rebuildKey++;
          });
        }
      }
    });
  }

  void _handleBatchStarted(CompostBatch batch) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BatchStartDialog(
        preSelectedMachineId: widget.focusedMachine?.machineId,
      ),
    );

    if (result == true && mounted) {
      // Refresh the activity logs after batch is created
      ref.invalidate(allActivitiesProvider);

      // Force rebuild by incrementing key
      setState(() {
        _rebuildKey++;
      });

      debugPrint('🔄 Batch created, forced rebuild with key: $_rebuildKey');
    }
  }

  void _handleBatchCompleted() {
    setState(() {
      _currentBatch = null;
      _rebuildKey++;
    });
  }

  Future<void> _handleFABPress() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const QuickActionsSheet(),
    );

    if (action == null || !mounted) return;

    if (action == 'add_waste') {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AddWasteProduct(
          preSelectedMachineId: _selectedMachineId,
          preSelectedBatchId: _selectedBatchId,
        ),
      );

      if (result == true && mounted) {
        ref.invalidate(allActivitiesProvider);
        ref.invalidate(userTeamBatchesProvider);

        if (_selectedMachineId != null) {
          await _autoSelectBatchForMachine(_selectedMachineId!);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Waste entry added successfully!'),
              backgroundColor: Colors.teal,
            ),
          );
        }
      }
    } else if (action == 'submit_report') {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => SubmitReport(
          preSelectedMachineId: _selectedMachineId,
          preSelectedBatchId: _selectedBatchId,
        ),
      );

      if (result == true && mounted) {
        ref.invalidate(allActivitiesProvider);
        ref.invalidate(userTeamBatchesProvider);

        if (_selectedMachineId != null) {
          await _autoSelectBatchForMachine(_selectedMachineId!);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMachineView = widget.focusedMachine != null;

    return Scaffold(
      appBar: MobileHeader(title: 'Dashboard'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isMachineView)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Machine: ${widget.focusedMachine!.machineName}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  CompostingProgressCard(
                    currentBatch: _currentBatch,
                    onBatchStarted: _handleBatchStarted,
                    onBatchCompleted: _handleBatchCompleted,
                    preSelectedMachineId: _selectedMachineId,
                    onBatchChanged: _updateActiveBatch,
                  ),
                  const SizedBox(height: 16),

                  // Swipeable cycle cards
                  // Swipeable cycle cards
                  SwipeableCycleCards(
                    currentBatch: _activeBatchModel,
                    machineId: _selectedMachineId,
                  ),
                  const SizedBox(height: 16),

                  // Activity logs
                  const SizedBox(
                    height: 400,
                    child: RecentActivitiesTable(),
                  ),
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