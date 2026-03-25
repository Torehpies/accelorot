import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/machine_model.dart';
import '../../../../data/providers/cycle_providers.dart';
import 'control_card.dart';

class AeratorControl extends ConsumerStatefulWidget {
  final MachineModel machine;
  
  const AeratorControl({super.key, required this.machine});

  @override
  ConsumerState<AeratorControl> createState() => _AeratorControlState();
}

class _AeratorControlState extends ConsumerState<AeratorControl> {
  Timer? _timer;
  String _uptime = '00:00';
  bool _isLoading = false;
  bool? _intendedState; // Tracks what state we are waiting for
  
  // State from Firestore
  bool _isRunning = false;
  DateTime? _startTime;
  int _accumulatedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadState();
  }
  
  @override
  void didUpdateWidget(AeratorControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.machine.aeratorActive != oldWidget.machine.aeratorActive ||
        widget.machine.currentBatchId != oldWidget.machine.currentBatchId) {
      _loadState();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadState() async {
    final batchId = widget.machine.currentBatchId;
    if (batchId == null || batchId.isEmpty) {
      _resetState();
      return;
    }

    try {
      final cycleRepo = ref.read(cycleRepositoryProvider);
      final cycles = await cycleRepo.getAerators(batchId: batchId);
      final cycle = cycles.isEmpty ? null : cycles.first;
      
      if (!mounted) return;

      setState(() {
        if (_intendedState != null) {
          if (widget.machine.aeratorActive == _intendedState!) {
            _isLoading = false;
            _intendedState = null;
          }
        } else {
          _isLoading = false;
        }
      });

      if (widget.machine.aeratorActive) {
        // It's actively running (database status)
        setState(() {
          _isRunning = true;
          if (cycle != null && cycle.action == 'started') {
            _startTime = cycle.startedAt ?? _startTime ?? DateTime.now();
            _accumulatedSeconds = cycle.accumulatedRuntimeSeconds ?? cycle.totalRuntimeSeconds ?? 0;
          } else {
            _startTime ??= DateTime.now();
            _accumulatedSeconds = 0;
          }
          
          final elapsed = DateTime.now().difference(_startTime!).inSeconds;
          _uptime = _formatDuration(Duration(seconds: _accumulatedSeconds + elapsed));
        });
        _startTimer();
      } else if (!widget.machine.aeratorActive && widget.machine.aeratorPaused) {
        // It's paused
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _startTime = null;
          if (cycle != null) {
            _accumulatedSeconds = cycle.accumulatedRuntimeSeconds ?? cycle.totalRuntimeSeconds ?? 0;
            _uptime = _formatDuration(Duration(seconds: _accumulatedSeconds));
          }
        });
      } else {
        // Idle/Stopped
        _resetState();
      }
    } catch (e) {
      debugPrint('Error loading Aerator state: $e');
    }
  }

  void _resetState() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _isRunning = false;
        _startTime = null;
        _accumulatedSeconds = 0;
        _uptime = '00:00';
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!).inSeconds;
        setState(() {
          _uptime = _formatDuration(Duration(seconds: _accumulatedSeconds + elapsed));
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _toggleAerator() async {
    if (_isLoading) return;

    final batchId = widget.machine.currentBatchId;
    if (batchId == null || batchId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot start without an active batch.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _intendedState = !_isRunning;
    });
    
    final cycleRepo = ref.read(cycleRepositoryProvider);

    try {
      if (_isRunning) {
        // Stop the aerator
        final elapsed = _startTime != null 
            ? DateTime.now().difference(_startTime!).inSeconds 
            : 0;
        final totalAccumulated = _accumulatedSeconds + elapsed;

        await cycleRepo.stopAerator(
          batchId: batchId,
          totalRuntimeSeconds: totalAccumulated,
          expectedStatus: 'running',
        );

        _timer?.cancel();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aerator stopped.')),
          );
        }

      } else {
        await cycleRepo.startAerator(
          batchId: batchId,
          machineId: widget.machine.machineId,
          userId: user.uid,
          cycles: 1, 
          duration: 'Continuous', 
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aerator started.'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Clear loading on error
          _intendedState = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle Aerator: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ControlCard(
      title: 'Aerator Uptime',
      timerValue: _uptime,
      buttonLabel: _isLoading ? '...' : (_isRunning ? 'Stop Aerator' : 'Start Aerator'),
      isRunning: _isRunning,
      onPressed: widget.machine.currentBatchId?.isNotEmpty == true ? _toggleAerator : null,
    );
  }
}
