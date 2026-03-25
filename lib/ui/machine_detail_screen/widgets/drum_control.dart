import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/machine_model.dart';
import '../../../../data/providers/cycle_providers.dart';
import 'control_card.dart';

class DrumControl extends ConsumerStatefulWidget {
  final MachineModel machine;
  
  const DrumControl({super.key, required this.machine});

  @override
  ConsumerState<DrumControl> createState() => _DrumControlState();
}

class _DrumControlState extends ConsumerState<DrumControl> {
  Timer? _timer;
  String _uptime = '00:00';
  bool _isLoading = false;
  
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
  void didUpdateWidget(DrumControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.machine.drumActive != oldWidget.machine.drumActive ||
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
      final cycles = await cycleRepo.getDrumControllers(batchId: batchId);
      final cycle = cycles.isEmpty ? null : cycles.first;
      
      if (!mounted) return;

      if (widget.machine.drumActive) {
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
          
          // Calculate immediate uptime
          final elapsed = DateTime.now().difference(_startTime!).inSeconds;
          _uptime = _formatDuration(Duration(seconds: _accumulatedSeconds + elapsed));
        });
        _startTimer();
      } else if (!widget.machine.drumActive && widget.machine.drumPaused) {
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
      debugPrint('Error loading Drum state: $e');
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

  Future<void> _toggleDrum() async {
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

    setState(() => _isLoading = true);
    final cycleRepo = ref.read(cycleRepositoryProvider);

    try {
      if (_isRunning) {
        // Stop the drum
        final elapsed = _startTime != null 
            ? DateTime.now().difference(_startTime!).inSeconds 
            : 0;
        final totalAccumulated = _accumulatedSeconds + elapsed;

        await cycleRepo.stopDrumController(
          batchId: batchId,
          totalRuntimeSeconds: totalAccumulated,
          expectedStatus: 'running',
        );

        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _startTime = null;
          // We keep total accumulated to show what was ran until a new restart zeroes it out in _loadState,
          // though for visual clean slate we can zero it here. Let's zero it for a true 'stop/reset' feel.
          _accumulatedSeconds = 0; 
          _uptime = '00:00';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Drum stopped.')),
          );
        }

      } else {
        await cycleRepo.startDrumController(
          batchId: batchId,
          machineId: widget.machine.machineId,
          userId: user.uid,
          cycles: 1, // Defaulting to 1 cycle continuously
          duration: 'Continuous', 
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Drum started.'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle Drum: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ControlCard(
      title: 'Drum Uptime',
      timerValue: _uptime,
      buttonLabel: _isLoading ? '...' : (_isRunning ? 'Stop Drum' : 'Start Drum'),
      isRunning: _isRunning,
      onPressed: widget.machine.currentBatchId?.isNotEmpty == true ? _toggleDrum : null,
    );
  }
}
