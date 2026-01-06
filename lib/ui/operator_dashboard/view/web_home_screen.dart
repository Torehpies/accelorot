// lib/web/operator/screens/web_home_screen.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:flutter_application_1/ui/operator_dashboard/widgets/add_waste/add_waste_product.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/submit_report/submit_report.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/batch_management/composting_progress_card.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/compost_batch_model.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/drum_control_card.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/aerator_card.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/activity_logs/activity_logs_card.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/batch_management/batch_start_dialog.dart';
import 'package:flutter_application_1/data/models/machine_model.dart';
import 'package:flutter_application_1/data/providers/batch_providers.dart';
import 'package:flutter_application_1/data/providers/activity_providers.dart';
import 'package:flutter_application_1/data/models/batch_model.dart';


class WebHomeScreen extends ConsumerStatefulWidget {
  final MachineModel? focusedMachine; 

  const WebHomeScreen({super.key, this.focusedMachine}); 

  @override
  ConsumerState<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends ConsumerState<WebHomeScreen> {
  //final GlobalKey<ActivityLogsCardState> _activityLogsKey =
  //  GlobalKey<ActivityLogsCardState>();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waste entry added successfully!'),
            backgroundColor: Colors.teal,
          ),
        );
        ref.invalidate(allActivitiesProvider);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(allActivitiesProvider);
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
                          SizedBox(
                            height: 360,
                            child: CompostingProgressCard(
                              currentBatch: _currentBatch,
                              onBatchStarted: _handleBatchStarted,
                              onBatchCompleted: _handleBatchCompleted,
                              preSelectedMachineId: widget.focusedMachine?.machineId,
                              onBatchChanged: _updateActiveBatch,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ActivityLogsCard(
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
                            child: DrumControlCard(
                              currentBatch: _activeBatchModel, 
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: AeratorCard(
                              currentBatch: _activeBatchModel, 
                            ),
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