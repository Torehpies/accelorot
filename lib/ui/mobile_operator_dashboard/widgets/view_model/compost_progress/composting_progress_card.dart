// lib/frontend/operator/dashboard/compost_progress/composting_progress_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../home_screen/compost_progress_components/batch_start_dialog.dart';
import '../../../../home_screen/compost_progress_components/batch_complete_dialog.dart';
import 'compost_batch_model.dart';
import '../../../../activity_logs/widgets/machine_selector.dart';
import '../../../../activity_logs/widgets/batch_selector.dart';
import '../../../../../data/providers/batch_providers.dart';
import '../../../../../data/models/batch_model.dart';

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
  ConsumerState<CompostingProgressCard> createState() => _CompostingProgressCardState();
}

class _CompostingProgressCardState extends ConsumerState<CompostingProgressCard> {
  String? _selectedMachineId;
  String? _selectedBatchId;
  BatchModel? _activeBatch;

  @override
  void initState() {
    super.initState();
    _selectedMachineId = widget.preSelectedMachineId;
  }

  @override
  void didUpdateWidget(CompostingProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update machine if it changed from parent
    if (widget.preSelectedMachineId != oldWidget.preSelectedMachineId) {
      setState(() {
        _selectedMachineId = widget.preSelectedMachineId;
        _selectedBatchId = null;
        _activeBatch = null;
      });
      // Auto-select latest batch for the new machine
      if (_selectedMachineId != null) {
        _autoSelectLatestBatch();
      }
    }
  }
    void _autoSelectLatestBatch() {
    final batchesAsync = ref.read(userTeamBatchesProvider);
    batchesAsync.whenData((batches) {
      if (_selectedMachineId != null) {
        final machineBatches = batches
            .where((b) => b.machineId == _selectedMachineId)
            .toList();
        
        if (machineBatches.isNotEmpty) {
          // Sort by createdAt to get the newest
          machineBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final latestBatch = machineBatches.first;
          
          if (mounted) {
            setState(() {
              _selectedBatchId = latestBatch.id;
              _activeBatch = latestBatch;
            });
            // Notify parent of batch change
            widget.onBatchChanged?.call(latestBatch);
          }
        } else {
          // No batches for this machine - notify parent
          if (mounted) {
            widget.onBatchChanged?.call(null);
          }
        }
      }
    });
  }

 void _startBatch(BuildContext context) async {
    // Check if there's an active batch for this machine
    if (_selectedMachineId != null) {
      final batchesAsync = ref.read(userTeamBatchesProvider);
      final hasActiveBatch = await batchesAsync.when(
        data: (batches) {
          return batches.any((b) => 
            b.machineId == _selectedMachineId && b.isActive
          );
        },
        loading: () => false,
        error: (_, __) => false,
      );

      if (hasActiveBatch && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot start new batch: An active batch already exists for this machine'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => BatchStartDialog(
        preSelectedMachineId: _selectedMachineId,
      ),
    );

    if (result == true && mounted) {
      // Refresh the batches using the new notifier method
      await ref.read(userTeamBatchesProvider.notifier).refresh();
      
      // Auto-select the newly created batch for the current machine
      if (_selectedMachineId != null) {
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 300));
        _autoSelectLatestBatch();
      }
    }
  }

  void _completeBatch(BuildContext context) {
    if (_activeBatch == null) return;

      showDialog(
      context: context,
      builder: (ctx) => BatchCompleteDialog(
        batch: _convertToCompostBatch(_activeBatch!),
        onComplete: () async {
          // Refresh the provider first
          await ref.read(userTeamBatchesProvider.notifier).refresh();
          
          // Wait a bit for the refresh to complete
          await Future.delayed(const Duration(milliseconds: 300));
          
          // Update local state to reflect the completed batch
          if (mounted) {
            final batchesAsync = ref.read(userTeamBatchesProvider);
            batchesAsync.whenData((batches) {
              final updatedBatch = batches.firstWhere(
                (b) => b.id == _selectedBatchId,
                orElse: () => batches.first,
              );
              
              if (mounted) {
                setState(() {
                  _activeBatch = updatedBatch;
                });
              }
            });
          }
          
          // Call parent callback
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

  int _getDaysPassed() {
    if (_activeBatch == null) return 0;
    final now = DateTime.now();
    return now.difference(_activeBatch!.createdAt).inDays.clamp(0, CompostingProgressCard.totalDays);
  }

  double _getProgress() {
    return (_getDaysPassed() / CompostingProgressCard.totalDays).clamp(0.0, 1.0);
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }
@override
  Widget build(BuildContext context) {
    //  auto-update when selected batch changes
    final batchesAsync = ref.watch(userTeamBatchesProvider);

    // Update active batch when selection changes
    batchesAsync.whenData((batches) {
      if (_selectedMachineId != null && _selectedBatchId == null) {
        final machineBatches = batches
            .where((b) => b.machineId == _selectedMachineId)
            .toList();
        
if (machineBatches.isNotEmpty) {
          Future.microtask(() {
            if (mounted) {
              machineBatches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final latestBatch = machineBatches.first;
              setState(() {
                _selectedBatchId = latestBatch.id;
                _activeBatch = latestBatch;
              });
              // Notify parent of batch change
              widget.onBatchChanged?.call(latestBatch);
            }
          });
        } else {
          // No batches for this machine
          Future.microtask(() {
            if (mounted) {
              widget.onBatchChanged?.call(null);
            }
          });
        }
      } else if (_selectedBatchId != null) {
        final batch = batches.firstWhere(
          (b) => b.id == _selectedBatchId,
          orElse: () => batches.first,
        );
        if (batch.id == _selectedBatchId && _activeBatch?.id != batch.id) {
          Future.microtask(() {
            if (mounted) {
              setState(() => _activeBatch = batch);
              // Notify parent of batch change
              widget.onBatchChanged?.call(batch);
            }
          });
        }
      }
    });

    final isActive = _activeBatch?.isActive ?? false;
    final progress = _getProgress();
    final batchIsCompleted = _activeBatch != null && !_activeBatch!.isActive;
    final hasBatchSelected = _activeBatch != null;
    final hasMachineSelected = _selectedMachineId != null;

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
                    selectedMachineId: _selectedMachineId,
                    onChanged: (machineId) {
                      setState(() {
                        _selectedMachineId = machineId;
                        _selectedBatchId = null;
                        _activeBatch = null;
                      });
                      // Notify parent immediately that batch is cleared
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
                    selectedBatchId: _selectedBatchId,
                    selectedMachineId: _selectedMachineId,
                    onChanged: (batchId) {
                      setState(() {
                        _selectedBatchId = batchId;
                        if (batchId == null) {
                          _activeBatch = null;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Decomposition Progress',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: batchIsCompleted 
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
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
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasMachineSelected 
                          ? () => _startBatch(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
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
                          _activeBatch!.displayName,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailItem(
                          'Batch Number',
                          '#${_activeBatch!.batchNumber}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailItem(
                          'Started',
                          _formatDate(_activeBatch!.createdAt),
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
                          _activeBatch!.machineId,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailItem(
                          'Days Elapsed',
                          '${_getDaysPassed()} days',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailItem(
                          batchIsCompleted ? 'Completed' : 'Status',
                          batchIsCompleted 
                              ? _formatDate(_activeBatch!.completedAt!)
                              : (_activeBatch!.isActive ? 'Active' : 'Inactive'),
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
                          ? null  // Disabled when machine not selected and batch completed
                          : () {
                              // If machine is not selected and batch is active, allow complete
                              if (!hasMachineSelected && !batchIsCompleted) {
                                _completeBatch(context);
                                return;
                              }
                              // Normal flow: machine is selected
                              if (batchIsCompleted) {
                                _startBatch(context);
                              } else {
                                _completeBatch(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
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
                            : (batchIsCompleted ? 'Start New Batch' : 'Complete Batch'),
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