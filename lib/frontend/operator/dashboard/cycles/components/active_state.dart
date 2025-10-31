// lib/frontend/operator/dashboard/cycles/components/active_state.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../models/drum_rotation_settings.dart';
import '../models/system_status.dart';
import '../widgets/drum_input_fields.dart';
import '../widgets/system_action_buttons.dart';

class ActiveState extends StatefulWidget {
  final String batchNumber;
  final DateTime batchStartTime;
  final DrumRotationSettings settings;
  final SystemStatus status;
  final Function(SystemStatus) onStatusChanged;
  final Function(DrumRotationSettings) onSettingsChanged;

  const ActiveState({
    super.key,
    required this.batchNumber,
    required this.batchStartTime,
    required this.settings,
    required this.status,
    required this.onStatusChanged,
    required this.onSettingsChanged,
  });

  @override
  State<ActiveState> createState() => _ActiveStateState();
}

class _ActiveStateState extends State<ActiveState> {
  Timer? _uptimeTimer;
  DateTime? _startTime;
  Duration _totalPausedTime = Duration.zero;
  DateTime? _lastPausedAt;

  @override
  void initState() {
    super.initState();
    _startUptimeTimer();
  }

  @override
  void dispose() {
    _uptimeTimer?.cancel();
    super.dispose();
  }

  void _startUptimeTimer() {
    _uptimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && widget.status == SystemStatus.running) {
        setState(() {});
      }
    });
  }

  Duration _getUptime() {
    if (_startTime == null) return Duration.zero;
    
    var elapsed = DateTime.now().difference(_startTime!);
    var pausedTime = _totalPausedTime;
    
    // If currently paused, add the current pause duration
    if (widget.status == SystemStatus.paused && _lastPausedAt != null) {
      pausedTime += DateTime.now().difference(_lastPausedAt!);
    }
    
    return elapsed - pausedTime;
  }

  String _formatUptime() {
    final uptime = _getUptime();
    final hours = uptime.inHours.toString().padLeft(2, '0');
    final minutes = (uptime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (uptime.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _getLastCycleText() {
    if (widget.settings.lastCycleCompleted == null) {
      return 'Never';
    }
    
    final now = DateTime.now();
    final difference = now.difference(widget.settings.lastCycleCompleted!);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _handleStart() {
    setState(() {
      _startTime = DateTime.now();
      _totalPausedTime = Duration.zero;
      _lastPausedAt = null;
    });
    widget.onStatusChanged(SystemStatus.running);
  }

  void _handlePause() {
    if (widget.status == SystemStatus.running) {
      setState(() {
        _lastPausedAt = DateTime.now();
      });
      widget.onStatusChanged(SystemStatus.paused);
    } else if (widget.status == SystemStatus.paused) {
      // Resume
      if (_lastPausedAt != null) {
        setState(() {
          _totalPausedTime += DateTime.now().difference(_lastPausedAt!);
          _lastPausedAt = null;
        });
      }
      widget.onStatusChanged(SystemStatus.running);
    }
  }

  void _handleStop() {
    setState(() {
      _startTime = null;
      _totalPausedTime = Duration.zero;
      _lastPausedAt = null;
    });
    widget.onStatusChanged(SystemStatus.stopped);
  }

  bool get _isSettingsLocked {
    return widget.status == SystemStatus.running || 
           widget.status == SystemStatus.paused;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Batch info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.science_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Batch: ${widget.batchNumber}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem('Uptime', _formatUptime()),
                  _buildInfoItem('Last Cycle', _getLastCycleText()),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Drum Rotation Settings Header
        const Text(
          'Drum Rotation Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),

        // Input fields
        DrumInputFields(
          selectedCycle: widget.settings.cycles.toString(),
          selectedPeriod: widget.settings.period,
          isLocked: _isSettingsLocked,
          onCycleChanged: (value) {
            if (value != null) {
              final updated = widget.settings.copyWith(
                cycles: int.parse(value),
              );
              widget.onSettingsChanged(updated);
            }
          },
          onPeriodChanged: (value) {
            if (value != null) {
              final updated = widget.settings.copyWith(period: value);
              widget.onSettingsChanged(updated);
            }
          },
        ),
        const SizedBox(height: 20),

        // Action buttons
        SystemActionButtons(
          status: widget.status,
          onStart: _handleStart,
          onStop: _handleStop,
          onTogglePause: _handlePause,
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}