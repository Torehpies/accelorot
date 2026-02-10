// lib/ui/operator_dashboard/screens/web_home_screen.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/batch_management/composting_progress_card.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/compost_batch_model.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/drum_control_card.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/aerator_card.dart';
import 'package:flutter_application_1/ui/admin_dashboard/web_widgets/recent_activities_table.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/batch_management/batch_start_dialog.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';
import 'package:flutter_application_1/data/providers/batch_providers.dart';
import 'package:flutter_application_1/data/providers/activity_providers.dart';
import 'package:flutter_application_1/data/providers/selected_batch_provider.dart';
import 'package:flutter_application_1/data/providers/selected_machine_provider.dart';
import 'package:flutter_application_1/data/models/batch_model.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/fabs/web_add_waste_fab.dart';

class WebHomeScreen extends ConsumerStatefulWidget {
  final MachineModel? focusedMachine;

  const WebHomeScreen({super.key, this.focusedMachine});

  @override
  ConsumerState<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends ConsumerState<WebHomeScreen>
    with AutomaticKeepAliveClientMixin {
  CompostBatch? _currentBatch;
  // ❌ Removed _selectedMachineId - now using provider

  BatchModel? _activeBatchModel;

  int _rebuildKey = 0;

  // GlobalKey to preserve CompostingProgressCard across layout switches
  final _compostCardKey = GlobalKey();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Initialize provider with focusedMachine if provided
    if (widget.focusedMachine?.machineId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedMachineIdProvider.notifier).setMachine(
          widget.focusedMachine!.machineId
        );
      });
    }
  }

  void _updateActiveBatch(BatchModel? batch) {
    debugPrint('🔄 _updateActiveBatch called with batch: ${batch?.id}');

    if (mounted) {
      setState(() {
        _activeBatchModel = batch;
    
        ref.read(selectedBatchIdProvider.notifier).setBatch(batch?.id);
        _rebuildKey++;

        if (batch != null) {
 
          ref.read(selectedMachineIdProvider.notifier).setMachine(batch.machineId);
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
    await Future.delayed(const Duration(milliseconds: 500));

    final batchesAsync = ref.read(userTeamBatchesProvider);
    batchesAsync.whenData((batches) {
      final machineBatches = batches
          .where((b) => b.machineId == machineId)
          .toList();

      if (machineBatches.isNotEmpty) {
        machineBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final latestBatch = machineBatches.first;

        if (mounted) {
          setState(() {

            ref.read(selectedBatchIdProvider.notifier).setBatch(latestBatch.id);
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
    final selectedMachineId = ref.read(selectedMachineIdProvider);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BatchStartDialog(
        preSelectedMachineId: selectedMachineId.isEmpty ? null : selectedMachineId,
      ),
    );

    if (result == true && mounted) {
      ref.invalidate(allActivitiesProvider);

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

  void _handleFABSuccess() async {
    final selectedMachineId = ref.read(selectedMachineIdProvider);
    if (selectedMachineId.isNotEmpty) {
      await _autoSelectBatchForMachine(selectedMachineId);
    }
  }

  Widget _buildFixedLayout(BuildContext context, double screenHeight, double screenWidth) {
 
    final selectedMachineId = ref.watch(selectedMachineIdProvider);
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02,
          vertical: screenHeight * 0.02,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - Batch Tracker and Recent Activity
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CompostingProgressCard(
                    key: _compostCardKey,
                    currentBatch: _currentBatch,
                    onBatchStarted: _handleBatchStarted,
                    onBatchCompleted: _handleBatchCompleted,
                    preSelectedMachineId: selectedMachineId.isEmpty ? null : selectedMachineId,
                    onBatchChanged: _updateActiveBatch,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  const Expanded(
                    child: RecentActivitiesTable(),
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.015),
            // Right side - Drum Controller and Aerator Cards
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ControlInputCard(
                      currentBatch: _activeBatchModel,
                      machineId: selectedMachineId.isEmpty ? null : selectedMachineId,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: AeratorCard(
                      currentBatch: _activeBatchModel,
                      machineId: selectedMachineId.isEmpty ? null : selectedMachineId,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableLayout(BuildContext context, double screenHeight, double screenWidth) {
  
    final selectedMachineId = ref.watch(selectedMachineIdProvider);
    
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: 20, // Fixed vertical padding for scrollable view
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CompostingProgressCard(
                      key: _compostCardKey,
                      currentBatch: _currentBatch,
                      onBatchStarted: _handleBatchStarted,
                      onBatchCompleted: _handleBatchCompleted,
                      preSelectedMachineId: selectedMachineId.isEmpty ? null : selectedMachineId,
                      onBatchChanged: _updateActiveBatch,
                    ),
                    const SizedBox(height: 20),
                    // Constrain table height in scrollable view
                    const SizedBox(
                      height: 500, 
                      child: RecentActivitiesTable(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.015),
              // Right side - NO EXPANDED, Natural sizes
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ControlInputCard(
                      currentBatch: _activeBatchModel,
                      machineId: selectedMachineId.isEmpty ? null : selectedMachineId,
                    ),
                    const SizedBox(height: 20),
                    AeratorCard(
                      currentBatch: _activeBatchModel,
                      machineId: selectedMachineId.isEmpty ? null : selectedMachineId,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final selectedMachineId = ref.watch(selectedMachineIdProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check if we should use scrollable layout (screen too small)
            final isCompactHeight = constraints.maxHeight < 800;
            
            if (isCompactHeight) {
                return _buildScrollableLayout(context, screenHeight, screenWidth);
            }
            
            return _buildFixedLayout(context, screenHeight, screenWidth);
          },
        ),
      ),
      floatingActionButton: WebAddWasteFAB(
        preSelectedMachineId: selectedMachineId.isEmpty ? null : selectedMachineId,
        preSelectedBatchId: ref.watch(selectedBatchIdProvider),  // ✅ Use provider
        onSuccess: _handleFABSuccess,
      ),
    );
  }
}
