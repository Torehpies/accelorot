import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/drum_rotation_settings.dart';
import '../../models/system_status.dart';
import 'system_action_buttons.dart';
import 'info_item.dart';

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
  Timer? _ticker;
  DateTime? _startTime;
  Duration _totalPausedTime = Duration.zero;
  DateTime? _lastPausedAt;

  @override
  void initState() {
    super.initState();
    _startTicker();
    if (widget.status == SystemStatus.running) {
      _startTime = widget.batchStartTime;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // Runs every second to update UI counter and check for phase switch
  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      // Update UI
      setState(() {});

      // Check if we need to switch phases (Only if running)
      if (widget.status == SystemStatus.running && 
          widget.settings.currentPhase != 'stopped') {
        _checkPhaseTransition();
      }
    });
  }

  void _checkPhaseTransition() {
    final remaining = widget.settings.remainingTime;

    // If time is up (0 seconds remaining)
    if (remaining.inSeconds <= 0) {
      // Determine next phase
      final nextPhase = widget.settings.currentPhase == 'active' ? 'resting' : 'active';
      
      // Update Settings Object
      final updatedSettings = widget.settings.copyWith(
        currentPhase: nextPhase,
        phaseStartTime: DateTime.now(), // Reset clock for new phase
      );

      // SAVE TO DB via Callback
      widget.onSettingsChanged(updatedSettings);
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Duration _getUptime() {
    if (_startTime == null) return Duration.zero;
    var elapsed = DateTime.now().difference(_startTime!);
    var pausedTime = _totalPausedTime;

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

  void _handleStart() {
    // Start in ACTIVE phase
    final startSettings = widget.settings.copyWith(
      currentPhase: 'active',
      phaseStartTime: DateTime.now(),
    );
    
    setState(() {
      _startTime = DateTime.now();
      _totalPausedTime = Duration.zero;
      _lastPausedAt = null;
    });
    
    widget.onSettingsChanged(startSettings); // Saves to DB
    widget.onStatusChanged(SystemStatus.running);
  }

  void _handlePause() {
    if (widget.status == SystemStatus.running) {
      setState(() {
        _lastPausedAt = DateTime.now();
      });
      widget.onStatusChanged(SystemStatus.paused);
    } else if (widget.status == SystemStatus.paused) {
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
    // Stop everything
    final stopSettings = widget.settings.copyWith(
      currentPhase: 'stopped',
      phaseStartTime: null,
    );
    
    setState(() {
      _startTime = null;
      _totalPausedTime = Duration.zero;
      _lastPausedAt = null;
    });
    
    widget.onSettingsChanged(stopSettings); // Saves to DB
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
        Padding(
          padding: const EdgeInsets.only(right: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: InfoItem(label: 'Uptime', value: _formatUptime())),
              const SizedBox(width: 16),
              Expanded(
                child: InfoItem(
                  label: 'Pattern',
                  value:
                      '${widget.settings.activeMinutes}/${widget.settings.restMinutes} min',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Drum Rotation Settings Header
        const Text(
          'Drum Rotation Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),

        // Pattern selector
        _buildDropdown(
          label: 'Select Cycle Pattern',
          value: widget.settings.pattern,
          items: ['1/59', '3/57', '5/55'],
          onChanged: _isSettingsLocked
              ? null
              : (value) {
                  if (value != null) {
                    final updated = widget.settings.copyWith();
                    updated.setPattern(value);
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