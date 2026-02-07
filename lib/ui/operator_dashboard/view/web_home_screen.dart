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
import 'package:flutter_application_1/data/models/batch_model.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/fabs/web_add_waste_fab.dart';

class WebHomeScreen extends ConsumerStatefulWidget {
  final MachineModel? focusedMachine;

  const WebHomeScreen({super.key, this.focusedMachine});

  @override
  ConsumerState<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends ConsumerState<WebHomeScreen> {
  CompostBatch? _currentBatch;
  String? _selectedMachineId;
  String? _selectedBatchId;
  BatchModel? _activeBatchModel;

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
    if (_selectedMachineId != null) {
      await _autoSelectBatchForMachine(_selectedMachineId!);
    }
  }

  Widget _buildFixedLayout(BuildContext context, double screenHeight, double screenWidth) {
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
                    currentBatch: _currentBatch,
                    onBatchStarted: _handleBatchStarted,
                    onBatchCompleted: _handleBatchCompleted,
                    preSelectedMachineId: widget.focusedMachine?.machineId,
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
                  Expanded(
                    child: ControlInputCard(
                      currentBatch: _activeBatchModel,
                      machineId: _selectedMachineId,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Expanded(
                    child: AeratorCard(
                      currentBatch: _activeBatchModel,
                      machineId: _selectedMachineId,
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
                      currentBatch: _currentBatch,
                      onBatchStarted: _handleBatchStarted,
                      onBatchCompleted: _handleBatchCompleted,
                      preSelectedMachineId: widget.focusedMachine?.machineId,
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
                      machineId: _selectedMachineId,
                    ),
                    const SizedBox(height: 20),
                    AeratorCard(
                      currentBatch: _activeBatchModel,
                      machineId: _selectedMachineId,
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
        preSelectedMachineId: _selectedMachineId,
        preSelectedBatchId: _selectedBatchId,
        onSuccess: _handleFABSuccess,
      ),
    );
  }
}