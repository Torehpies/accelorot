import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/drum_rotation_settings.dart';
import 'package:flutter_application_1/ui/operator_dashboard/models/system_status.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/empty_state.dart';
import 'package:flutter_application_1/ui/operator_dashboard/widgets/cycle_controls/info_item.dart';
import 'package:flutter_application_1/data/models/batch_model.dart';
import 'package:flutter_application_1/data/providers/cycle_providers.dart';
import 'package:flutter_application_1/data/models/cycle_recommendation.dart';


class AeratorCard extends ConsumerStatefulWidget {
  final BatchModel? currentBatch;

  const AeratorCard({super.key, this.currentBatch});

  @override
  ConsumerState<AeratorCard> createState() => _AeratorCardState();
}

class _AeratorCardState extends ConsumerState<AeratorCard> {
  DrumRotationSettings settings = DrumRotationSettings();
  SystemStatus status = SystemStatus.idle;
  
  String _uptime = '00:00:00';
  DateTime? _startTime;
  Timer? _timer;
  CycleRecommendation? _cycleDoc;

  @override
  void initState() {
    super.initState();
    if (widget.currentBatch != null && widget.currentBatch!.isActive) {
      _loadExistingCycle();
    }
  }

  @override
  void didUpdateWidget(AeratorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if batch ID changed (new batch selected or created)
    final currentBatchId = widget.currentBatch?.id;
    final oldBatchId = oldWidget.currentBatch?.id;
    
    if (currentBatchId != oldBatchId) {
      // Batch changed - reset and reload
      _stopTimer();
      
      if (widget.currentBatch == null || !widget.currentBatch!.isActive) {
        // No active batch - clear everything
        setState(() {
          settings.reset();
          status = SystemStatus.idle;
          _uptime = '00:00:00';
          _startTime = null;
          _cycleDoc = null;
        });
      } else {
        // New active batch - load its cycle
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _loadExistingCycle();
          }
        });
      }
    } else if (widget.currentBatch != null && 
               oldWidget.currentBatch?.isActive == true && 
               !widget.currentBatch!.isActive) {
      // Same batch but became inactive
      _stopTimer();
      
      if (_cycleDoc != null && widget.currentBatch?.id != null) {
        _completeCycleInFirebase();
      }
      
      setState(() {
        status = SystemStatus.stopped;
      });
    }
  }

  Future<void> _loadExistingCycle() async {
    if (widget.currentBatch == null) return;

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);
      final cycle = await cycleRepository.getAerator(
        batchId: widget.currentBatch!.id,
      );

      if (mounted && cycle != null) {
        setState(() {
          _cycleDoc = cycle;
          settings = DrumRotationSettings(
            activeMinutes: cycle.activeMinutes ?? 1,
            restMinutes: cycle.restMinutes ?? 59,
          );

          if (cycle.status == 'running') {
            status = SystemStatus.running;
            _startTime = cycle.startedAt;
            if (_startTime != null) {
              _startTimer();
            }
          } else if (cycle.status == 'completed') {
            status = SystemStatus.stopped;
            if (cycle.totalRuntimeSeconds != null) {
              _uptime = _formatDuration(
                Duration(seconds: cycle.totalRuntimeSeconds!),
              );
            }
          }
        });
      } else if (mounted) {
        // No existing cycle - reset to idle state for new batch
        setState(() {
          settings.reset();
          status = SystemStatus.idle;
          _uptime = '00:00:00';
          _startTime = null;
          _cycleDoc = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading aerator cycle: $e');
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        setState(() {
          _uptime = _formatDuration(elapsed);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _handleStart() async {
    if (widget.currentBatch == null || !widget.currentBatch!.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot start: No active batch'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to start the aerator'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);
      
      // Start aerator in Firebase
      await cycleRepository.startAerator(
        batchId: widget.currentBatch!.id,
        machineId: widget.currentBatch!.machineId,
        userId: user.uid,
        activeMinutes: settings.activeMinutes,
        restMinutes: settings.restMinutes,
      );

      // Reload the cycle to get the ID
      final cycle = await cycleRepository.getAerator(
        batchId: widget.currentBatch!.id,
      );

      setState(() {
        _cycleDoc = cycle;
        status = SystemStatus.running;
        _startTime = DateTime.now();
        _startTimer();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeCycleInFirebase() async {
    if (widget.currentBatch?.id == null) return;

    try {
      final cycleRepository = ref.read(cycleRepositoryProvider);
      await cycleRepository.completeAerator(
        batchId: widget.currentBatch!.id,
      );
    } catch (e) {
      debugPrint('Failed to complete aerator: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveBatch = widget.currentBatch != null && widget.currentBatch!.isActive;
    final batchCompleted = widget.currentBatch != null && !widget.currentBatch!.isActive;

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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Aerator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: batchCompleted
                        ? const Color(0xFFF3F4F6)
                        : (hasActiveBatch
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFFEF3C7)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    batchCompleted
                        ? 'Completed'
                        : (hasActiveBatch ? 'Active' : 'Inactive'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: batchCompleted
                          ? const Color(0xFF6B7280)
                          : (hasActiveBatch
                              ? const Color(0xFF065F46)
                              : const Color(0xFF92400E)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (!hasActiveBatch && !batchCompleted)
              const EmptyState()
            else
              _buildActiveState(batchCompleted),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveState(bool batchCompleted) {
    final canInteract = !batchCompleted && status == SystemStatus.idle;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InfoItem(
                label: 'Machine Name',
                value: widget.currentBatch!.machineId,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoItem(
                label: 'Batch Name',
                value: widget.currentBatch!.displayName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: InfoItem(
                label: 'Uptime',
                value: _uptime,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoItem(
                label: 'Pattern',
                value: '${settings.activeMinutes}/${settings.restMinutes} min',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        const Text(
          'Set Controller',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 12),

        _buildDropdown(
          label: 'Select Cycle Pattern',
          value: settings.pattern,
          items: ['1/59', '3/57', '5/55'],
          onChanged: canInteract
              ? (value) {
                  if (value != null) {
                    setState(() {
                      settings.setPattern(value);
                    });
                  }
                }
              : null,
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canInteract ? _handleStart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: batchCompleted
                  ? Colors.grey.shade400
                  : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Text(
              batchCompleted
                  ? 'Completed'
                  : (status == SystemStatus.idle ? 'Start' : status.displayName),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: onChanged == null ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          isDense: true,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade600,
            size: 20,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                '$item min (${item.split('/')[0]} ON / ${item.split('/')[1]} OFF)',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}