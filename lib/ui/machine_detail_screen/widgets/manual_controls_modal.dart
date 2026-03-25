import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/machine_model.dart';
import '../../../../data/providers/cycle_providers.dart';
import '../../../../data/providers/machine_providers.dart';

class ManualControlsModal extends ConsumerStatefulWidget {
  final MachineModel machine;

  const ManualControlsModal({super.key, required this.machine});

  @override
  ConsumerState<ManualControlsModal> createState() => _ManualControlsModalState();
}

class _ManualControlsModalState extends ConsumerState<ManualControlsModal> {
  // Drum state
  Timer? _drumTimer;
  String _drumUptime = '00:00';
  bool _drumLoading = false;
  bool _drumRunning = false;
  bool? _intendedDrumState;
  DateTime? _drumStartTime;
  int _drumAccumulatedSeconds = 0;

  // Aerator state
  Timer? _aeratorTimer;
  String _aeratorUptime = '00:00';
  bool _aeratorLoading = false;
  bool _aeratorRunning = false;
  bool? _intendedAeratorState;
  DateTime? _aeratorStartTime;
  int _aeratorAccumulatedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  @override
  void didUpdateWidget(ManualControlsModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.machine.drumActive != oldWidget.machine.drumActive ||
        widget.machine.aeratorActive != oldWidget.machine.aeratorActive ||
        widget.machine.currentBatchId != oldWidget.machine.currentBatchId) {
      _loadStates();
    }
  }

  @override
  void dispose() {
    _drumTimer?.cancel();
    _aeratorTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStates() async {
    try {
      final liveMachine = ref.read(machineStreamProvider(widget.machine.machineId)).value ?? widget.machine;
      final batchId = liveMachine.currentBatchId;
      if (batchId == null || batchId.isEmpty) return;

      final teamCyclesAsync = ref.read(teamCyclesStreamProvider);
      if (teamCyclesAsync.value == null) return;
      
      final cycles = teamCyclesAsync.value!;

      // Load Drum
      final drumCycles = cycles.where((c) => c.batchId == batchId && c.controllerType == 'drum_controller').toList();
      drumCycles.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return 1;
        if (b.timestamp == null) return -1;
        return b.timestamp!.compareTo(a.timestamp!);
      });
      final drumCycle = drumCycles.isEmpty ? null : drumCycles.first;
      
      // Apply intent tracking for loading states
      setState(() {
        if (_intendedDrumState != null) {
          if (liveMachine.drumActive == _intendedDrumState!) {
            _drumLoading = false;
            _intendedDrumState = null;
          }
        } else {
          _drumLoading = false;
        }

        if (_intendedAeratorState != null) {
          if (liveMachine.aeratorActive == _intendedAeratorState!) {
            _aeratorLoading = false;
            _intendedAeratorState = null;
          }
        } else {
          _aeratorLoading = false;
        }
      });

      if (liveMachine.drumActive) {
        // Start/Continue timer based on machine activity
        if (!_drumRunning) {
          _drumRunning = true;
          _startDrumTimer();
        }
        
        if (drumCycle != null && drumCycle.action == 'started') {
          // Precise calibration from database cycle
          _drumStartTime = drumCycle.startedAt ?? _drumStartTime ?? DateTime.now();
          _drumAccumulatedSeconds = drumCycle.accumulatedRuntimeSeconds ?? drumCycle.totalRuntimeSeconds ?? 0;
        } else if (_drumStartTime == null) {
          // Fallback if no cycle doc yet
          _drumStartTime = DateTime.now();
          _drumAccumulatedSeconds = 0;
        }
      } else if (liveMachine.drumPaused) {
        // Handle Paused state
        _drumRunning = false;
        _drumTimer?.cancel();
        if (drumCycle != null) {
          _drumAccumulatedSeconds = drumCycle.accumulatedRuntimeSeconds ?? drumCycle.totalRuntimeSeconds ?? 0;
          _drumUptime = _formatDuration(Duration(seconds: _drumAccumulatedSeconds));
        }
      } else {
        // Stopped/Idle
        _resetDrumState();
      }

      // Load Aerator
      final aeratorCycles = cycles.where((c) => c.batchId == batchId && c.controllerType == 'aerator').toList();
      aeratorCycles.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return 1;
        if (b.timestamp == null) return -1;
        return b.timestamp!.compareTo(a.timestamp!);
      });
      final aeratorCycle = aeratorCycles.isEmpty ? null : aeratorCycles.first;

      if (liveMachine.aeratorActive) {
        // Start/Continue timer based on machine activity
        if (!_aeratorRunning) {
          _aeratorRunning = true;
          _startAeratorTimer();
        }
        
        if (aeratorCycle != null && aeratorCycle.action == 'started') {
          // Precise calibration from database cycle
          _aeratorStartTime = aeratorCycle.startedAt ?? _aeratorStartTime ?? DateTime.now();
          _aeratorAccumulatedSeconds = aeratorCycle.accumulatedRuntimeSeconds ?? aeratorCycle.totalRuntimeSeconds ?? 0;
        } else if (_aeratorStartTime == null) {
          // Fallback if no cycle doc yet
          _aeratorStartTime = DateTime.now();
          _aeratorAccumulatedSeconds = 0;
        }
      } else if (liveMachine.aeratorPaused) {
        // Handle Paused state
        _aeratorRunning = false;
        _aeratorTimer?.cancel();
        if (aeratorCycle != null) {
          _aeratorAccumulatedSeconds = aeratorCycle.accumulatedRuntimeSeconds ?? aeratorCycle.totalRuntimeSeconds ?? 0;
          _aeratorUptime = _formatDuration(Duration(seconds: _aeratorAccumulatedSeconds));
        }
      } else {
        // Stopped/Idle
        _resetAeratorState();
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error loading states: $e');
    }
  }

  void _resetDrumState() {
    _drumTimer?.cancel();
    _drumRunning = false;
    _drumStartTime = null;
    _drumAccumulatedSeconds = 0;
    _drumUptime = '00:00';
  }

  void _resetAeratorState() {
    _aeratorTimer?.cancel();
    _aeratorRunning = false;
    _aeratorStartTime = null;
    _aeratorAccumulatedSeconds = 0;
    _aeratorUptime = '00:00';
  }

  void _startDrumTimer() {
    _drumTimer?.cancel();
    _drumTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _drumStartTime != null) {
        final elapsed = DateTime.now().difference(_drumStartTime!).inSeconds;
        setState(() {
          _drumUptime = _formatDuration(Duration(seconds: _drumAccumulatedSeconds + elapsed));
        });
      }
    });
  }

  void _startAeratorTimer() {
    _aeratorTimer?.cancel();
    _aeratorTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _aeratorStartTime != null) {
        final elapsed = DateTime.now().difference(_aeratorStartTime!).inSeconds;
        setState(() {
          _aeratorUptime = _formatDuration(Duration(seconds: _aeratorAccumulatedSeconds + elapsed));
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
    if (_drumLoading) return;
    final batchId = widget.machine.currentBatchId;
    if (batchId == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _drumLoading = true;
      _intendedDrumState = !_drumRunning;
    });
    final cycleRepo = ref.read(cycleRepositoryProvider);

    try {
      if (_drumRunning) {
        final elapsed = _drumStartTime != null ? DateTime.now().difference(_drumStartTime!).inSeconds : 0;
        
        await cycleRepo.stopDrumController(
          batchId: batchId,
          totalRuntimeSeconds: _drumAccumulatedSeconds + elapsed,
          expectedStatus: 'running',
        );
        _drumTimer?.cancel();
      } else {
        await cycleRepo.startDrumController(
          batchId: batchId,
          machineId: widget.machine.machineId,
          userId: user.uid,
          cycles: 1,
          duration: 'Manual',
        );
      }
    } catch (e) {
      debugPrint('Error toggling drum: $e');
      if (mounted) {
        setState(() {
          _drumLoading = false;
          _intendedDrumState = null;
        });
      }
    }
  }

  Future<void> _toggleAerator() async {
    if (_aeratorLoading) return;
    final batchId = widget.machine.currentBatchId;
    if (batchId == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _aeratorLoading = true;
      _intendedAeratorState = !_aeratorRunning;
    });
    final cycleRepo = ref.read(cycleRepositoryProvider);

    try {
      if (_aeratorRunning) {
        final elapsed = _aeratorStartTime != null ? DateTime.now().difference(_aeratorStartTime!).inSeconds : 0;
        
        await cycleRepo.stopAerator(
          batchId: batchId,
          totalRuntimeSeconds: _aeratorAccumulatedSeconds + elapsed,
          expectedStatus: 'running',
        );
        _aeratorTimer?.cancel();
      } else {
        await cycleRepo.startAerator(
          batchId: batchId,
          machineId: widget.machine.machineId,
          userId: user.uid,
          cycles: 1,
          duration: 'Manual',
        );
      }
    } catch (e) {
      debugPrint('Error toggling aerator: $e');
      if (mounted) {
        setState(() {
          _aeratorLoading = false;
          _intendedAeratorState = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(machineStreamProvider(widget.machine.machineId), (previous, next) {
      if (next.hasValue && next.value != null) {
        _loadStates();
      }
    });

    ref.listen(teamCyclesStreamProvider, (previous, next) {
      if (next.hasValue && next.value != null && next.value!.isNotEmpty) {
        _loadStates();
      }
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manual Controls',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF789CA4)),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildControlSection(
                    'Drum', 
                    _drumUptime, 
                    _drumRunning, 
                    _drumLoading, 
                    _toggleDrum,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildControlSection(
                    'Aerator', 
                    _aeratorUptime, 
                    _aeratorRunning, 
                    _aeratorLoading, 
                    _toggleAerator,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSection(
    String title, 
    String uptime, 
    bool isRunning, 
    bool isLoading, 
    VoidCallback onToggle,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFD0DFE9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7C909C), width: 1),
      ),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF789CA4),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6, 
                height: 6, 
                decoration: BoxDecoration(
                  color: isRunning ? Colors.green : Colors.grey, 
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isRunning ? 'Running' : 'Idle', 
                style: const TextStyle(
                  fontSize: 10, 
                  color: Color(0xFF789CA4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            uptime,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: isRunning
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFEAF4FB),
                foregroundColor: isRunning
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFF3B717B),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isLoading ? '...' : (isRunning ? 'Stop $title' : 'Start $title'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
