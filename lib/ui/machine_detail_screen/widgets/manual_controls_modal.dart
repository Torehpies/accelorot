import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/machine_model.dart';
import '../../../../data/providers/cycle_providers.dart';

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
  DateTime? _drumStartTime;
  int _drumAccumulatedSeconds = 0;

  // Aerator state
  Timer? _aeratorTimer;
  String _aeratorUptime = '00:00';
  bool _aeratorLoading = false;
  bool _aeratorRunning = false;
  DateTime? _aeratorStartTime;
  int _aeratorAccumulatedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  @override
  void dispose() {
    _drumTimer?.cancel();
    _aeratorTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStates() async {
    final batchId = widget.machine.currentBatchId;
    if (batchId == null || batchId.isEmpty) return;

    try {
      final cycleRepo = ref.read(cycleRepositoryProvider);
      
      // Load Drum
      final drumCycles = await cycleRepo.getDrumControllers(batchId: batchId);
      final drumCycle = drumCycles.isEmpty ? null : drumCycles.first;
      
      if (drumCycle != null && widget.machine.drumActive) {
        _drumRunning = true;
        _drumStartTime = drumCycle.startedAt ?? DateTime.now();
        _drumAccumulatedSeconds = drumCycle.accumulatedRuntimeSeconds ?? drumCycle.totalRuntimeSeconds ?? 0;
        _startDrumTimer();
      } else if (drumCycle != null && widget.machine.drumPaused) {
        _drumRunning = false;
        _drumAccumulatedSeconds = drumCycle.accumulatedRuntimeSeconds ?? drumCycle.totalRuntimeSeconds ?? 0;
        _drumUptime = _formatDuration(Duration(seconds: _drumAccumulatedSeconds));
      }

      // Load Aerator
      final aeratorCycles = await cycleRepo.getAerators(batchId: batchId);
      final aeratorCycle = aeratorCycles.isEmpty ? null : aeratorCycles.first;

      if (aeratorCycle != null && widget.machine.aeratorActive) {
        _aeratorRunning = true;
        _aeratorStartTime = aeratorCycle.startedAt ?? DateTime.now();
        _aeratorAccumulatedSeconds = aeratorCycle.accumulatedRuntimeSeconds ?? aeratorCycle.totalRuntimeSeconds ?? 0;
        _startAeratorTimer();
      } else if (aeratorCycle != null && widget.machine.aeratorPaused) {
        _aeratorRunning = false;
        _aeratorAccumulatedSeconds = aeratorCycle.accumulatedRuntimeSeconds ?? aeratorCycle.totalRuntimeSeconds ?? 0;
        _aeratorUptime = _formatDuration(Duration(seconds: _aeratorAccumulatedSeconds));
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error loading states: $e');
    }
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
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _toggleDrum() async {
    if (_drumLoading) return;
    final batchId = widget.machine.currentBatchId;
    if (batchId == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _drumLoading = true);
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
        setState(() {
          _drumRunning = false;
          _drumUptime = '00:00';
          _drumAccumulatedSeconds = 0;
        });
      } else {
        await cycleRepo.startDrumController(
          batchId: batchId,
          machineId: widget.machine.machineId,
          userId: user.uid,
          cycles: 1,
          duration: 'Manual',
        );
        setState(() {
          _drumRunning = true;
          _drumStartTime = DateTime.now();
        });
        _startDrumTimer();
      }
    } catch (e) {
      debugPrint('Error toggling drum: $e');
    } finally {
      if (mounted) setState(() => _drumLoading = false);
    }
  }

  Future<void> _toggleAerator() async {
    if (_aeratorLoading) return;
    final batchId = widget.machine.currentBatchId;
    if (batchId == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _aeratorLoading = true);
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
        setState(() {
          _aeratorRunning = false;
          _aeratorUptime = '00:00';
          _aeratorAccumulatedSeconds = 0;
        });
      } else {
        await cycleRepo.startAerator(
          batchId: batchId,
          machineId: widget.machine.machineId,
          userId: user.uid,
          cycles: 1,
          duration: 'Manual',
        );
        setState(() {
          _aeratorRunning = true;
          _aeratorStartTime = DateTime.now();
        });
        _startAeratorTimer();
      }
    } catch (e) {
      debugPrint('Error toggling aerator: $e');
    } finally {
      if (mounted) setState(() => _aeratorLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              fontSize: 32,
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
