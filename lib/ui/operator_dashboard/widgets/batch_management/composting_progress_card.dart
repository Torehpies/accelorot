// lib/frontend/operator/dashboard/compost_progress/composting_progress_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'batch_start_dialog.dart';
import 'batch_complete_dialog.dart';
import '../../models/compost_batch_model.dart';
import '../../../activity_logs/widgets/mobile/machine_selector.dart';
import '../../../activity_logs/widgets/mobile/batch_selector.dart';
import '../../../../data/providers/batch_providers.dart';
import '../../../../data/providers/selected_batch_provider.dart';
import '../../../../data/providers/selected_machine_provider.dart';
import '../../../../data/models/batch_model.dart';
import '../../../core/themes/app_theme.dart';

class CompostingProgressCard extends ConsumerStatefulWidget {
  static const int totalDays = 12; // Fixed 12-day cycle

  final CompostBatch? currentBatch;
  final Function(CompostBatch) onBatchStarted;
  final VoidCallback onBatchCompleted;
  final String? preSelectedMachineId;
  final Function(BatchModel?)? onBatchChanged;

  const CompostingProgressCard({
    super.key,
    required this.currentBatch,
    required this.onBatchStarted,
    required this.onBatchCompleted,
    this.preSelectedMachineId,
    this.onBatchChanged,
  });

  @override
  ConsumerState<CompostingProgressCard> createState() =>
      _CompostingProgressCardState();
}

class _CompostingProgressCardState
    extends ConsumerState<CompostingProgressCard>
    with AutomaticKeepAliveClientMixin {
 
  // String? _selectedMachineId;
  // String? _selectedBatchId;
  // BatchModel? _activeBatch;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Initialize machine provider if preSelectedMachineId is provided
    if (widget.preSelectedMachineId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedMachineIdProvider.notifier).setMachine(
          widget.preSelectedMachineId!
        );
      });
    }
  }

  @override
  void didUpdateWidget(CompostingProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update machine provider if it changed from parent
    if (widget.preSelectedMachineId != oldWidget.preSelectedMachineId) {

      Future.microtask(() {
        if (mounted && widget.preSelectedMachineId != null) {
          ref.read(selectedMachineIdProvider.notifier).setMachine(
            widget.preSelectedMachineId!
          );
  
          ref.read(selectedBatchIdProvider.notifier).clearSelection();
          // Auto-select latest batch for the new machine
          _autoSelectLatestBatch();
        }
      });
    }
  }

  void _autoSelectLatestBatch() {
    final selectedMachineId = ref.read(selectedMachineIdProvider);
    final batchesAsync = ref.read(userTeamBatchesProvider);
    batchesAsync.whenData((batches) {
      if (selectedMachineId.isNotEmpty) {
        final machineBatches = batches
            .where((b) => b.machineId == selectedMachineId)
            .toList();

        if (machineBatches.isNotEmpty) {
          machineBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final latestBatch = machineBatches.first;

     
          Future.microtask(() {
            if (mounted) {
              ref.read(selectedBatchIdProvider.notifier).setBatch(latestBatch.id);
              widget.onBatchChanged?.call(latestBatch);
            }
          });
        } else {
        
          Future.microtask(() {
            if (mounted) {
              ref.read(selectedBatchIdProvider.notifier).clearSelection();
              widget.onBatchChanged?.call(null);
            }
          });
        }
      }
    });
  }

  void _startBatch(BuildContext context) async {
    final selectedMachineId = ref.read(selectedMachineIdProvider);
    
    // Check if there's an active batch for this machine
    if (selectedMachineId.isNotEmpty) {
      final batchesAsync = ref.read(userTeamBatchesProvider);
      final hasActiveBatch = batchesAsync.when(
        data: (batches) {
          return batches.any(
            (b) => b.machineId == selectedMachineId && b.isActive,
          );
        },
        loading: () => false,
        error: (_, __) => false,
      );

      if (hasActiveBatch) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot start new batch: An active batch already exists for this machine',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          BatchStartDialog(
            preSelectedMachineId: selectedMachineId.isEmpty ? null : selectedMachineId,
          ),
    );

    if (result == true && mounted) {
      // Refresh the batches using the new notifier method
      await ref.read(userTeamBatchesProvider.notifier).refresh();

      // Auto-select the newly created batch for the current machine
      if (selectedMachineId.isNotEmpty) {
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 300));
        _autoSelectLatestBatch();
      }
    }
  }

  void _completeBatch(BuildContext context, BatchModel? activeBatch) {
    if (activeBatch == null) return;

    showDialog(
      context: context,
      builder: (ctx) => BatchCompleteDialog(
        batch: _convertToCompostBatch(activeBatch),
        onComplete: () async {
          // Refresh the provider first
          await ref.read(userTeamBatchesProvider.notifier).refresh();

          // Wait a bit for the refresh to complete
          await Future.delayed(const Duration(milliseconds: 300));

          // Notify parent callback
          widget.onBatchCompleted();
        },
      ),
    );
  }

  // Helper to convert BatchModel to CompostBatch for the dialog
  CompostBatch _convertToCompostBatch(BatchModel batch) {
    return CompostBatch(
      batchName: 'Batch #${batch.batchNumber}',
      batchNumber: batch.id,
      startedBy: null,
      batchStart: batch.createdAt,
      startNotes: null,
      status: batch.isActive ? 'active' : 'completed',
    );
  }

  int _getDaysPassed(BatchModel? activeBatch) {
    if (activeBatch == null) return 0;
    final now = DateTime.now();
    return now
        .difference(activeBatch.createdAt)
        .inDays
        .clamp(0, CompostingProgressCard.totalDays);
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // ✅ Watch the persisted providers
    final selectedMachineId = ref.watch(selectedMachineIdProvider);
    final selectedBatchId = ref.watch(selectedBatchIdProvider);
    final batchesAsync = ref.watch(userTeamBatchesProvider);

    // Find the active batch from provider state
    BatchModel? activeBatch;
    final batchesValue = batchesAsync.asData?.value;
    if (batchesValue != null && selectedBatchId != null) {
      try {
        final matchingBatches = batchesValue.where((b) => b.id == selectedBatchId).toList();
        if (matchingBatches.isNotEmpty) {
          activeBatch = matchingBatches.first;
        }
      } catch (e) {
        // Handle error silently
      }
    }

    final isActive = activeBatch?.isActive ?? false;
    final batchIsCompleted = activeBatch != null && !activeBatch.isActive;
    final hasBatchSelected = activeBatch != null;
    final hasMachineSelected = selectedMachineId.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Batch Tracker',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: -0.5,
                  ),
                ),
                if (hasBatchSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: batchIsCompleted
                          ? const Color(0xFFF3F4F6)
                          : (isActive
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEF3C7)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      batchIsCompleted
                          ? 'Completed'
                          : (isActive ? 'Active' : 'Inactive'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: batchIsCompleted
                            ? const Color(0xFF6B7280)
                            : (isActive
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF92400E)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Machine and Batch Selector Row
            Row(
              children: [
                Expanded(
                  child: MachineSelector(
                    selectedMachineId: selectedMachineId.isEmpty ? null : selectedMachineId,
                    onChanged: (machineId) {
                      // ✅ Update provider instead of local state
                      ref.read(selectedMachineIdProvider.notifier).setMachine(machineId ?? "");
                      // ✅ Clear batch in provider
                      ref.read(selectedBatchIdProvider.notifier).clearSelection();
                      // Notify parent that batch is cleared
                      widget.onBatchChanged?.call(null);
                      // Auto-select latest batch for new machine
                      if (machineId != null) {
                        _autoSelectLatestBatch();
                      }
                    },
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BatchSelector(
                    selectedBatchId: selectedBatchId,  // ✅ Use provider value
                    selectedMachineId: selectedMachineId.isEmpty ? null : selectedMachineId,
                    onMachineAutoSelect: (machineId) {

                      if (machineId != null) {
                        ref.read(selectedMachineIdProvider.notifier).setMachine(machineId);
                      }
                    },
                    onChanged: (batchId) {
                     
                      ref.read(selectedBatchIdProvider.notifier).setBatch(batchId);
                      
                      // Update parent
                      batchesAsync.whenData((batches) {
                        if (batchId != null) {
                          try {
                            final batch = batches.firstWhere((b) => b.id == batchId);
                            widget.onBatchChanged?.call(batch);
                          } catch (e) {
                            widget.onBatchChanged?.call(null);
                          }
                        } else {
                          widget.onBatchChanged?.call(null);
                        }
                      });
                    },
                    isCompact: true,
                    showLabel: false,
                    showAllOption: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Decomposition Progress section
            const Text(
              'Decomposition Progress',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 16),

            // Conditional content
            if (!hasBatchSelected)
              Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 40,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasMachineSelected
                        ? 'No batch selected, select or start a batch!'
                        : 'Select a machine to get started',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasMachineSelected
                          ? () => _startBatch(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green100,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                      ),
                      child: Text(
                        hasMachineSelected
                            ? 'Start New Batch'
                            : 'Select a Machine First',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            if (hasBatchSelected)
              Column(
                children: [
                  // Batch details grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Batch Name',
                          activeBatch.displayName,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailItem(
                          'Batch Number',
                          '#${activeBatch.batchNumber}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailItem(
                          'Started',
                          _formatDate(activeBatch.createdAt),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Machine ID',
                          activeBatch.machineId,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailItem(
                          'Days Elapsed',
                          '${_getDaysPassed(activeBatch)} days',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailItem(
                          batchIsCompleted ? 'Completed' : 'Status',
                          batchIsCompleted
                              ? _formatDate(activeBatch.completedAt!)
                              : (activeBatch.isActive
                                    ? 'Active'
                                    : 'Inactive'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Complete Batch / Start New Batch / Select Machine button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (!hasMachineSelected && batchIsCompleted)
                          ? null // Disabled when machine not selected and batch completed
                          : () {
                              // If machine is not selected and batch is active, allow complete
                              if (!hasMachineSelected && !batchIsCompleted) {
                                _completeBatch(context, activeBatch);
                                return;
                              }
                              // Normal flow: machine is selected
                              if (batchIsCompleted) {
                                _startBatch(context);
                              } else {
                                _completeBatch(context, activeBatch);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green100,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                      ),
                      child: Text(
                        !hasMachineSelected && batchIsCompleted
                            ? 'Select a Machine First'
                            : (batchIsCompleted
                                  ? 'Start New Batch'
                                  : 'Complete Batch'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1a1a1a),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
