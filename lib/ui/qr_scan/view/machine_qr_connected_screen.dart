import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/providers/machine_providers.dart';
import '../../machine_detail_screen/view/machine_detail_screen.dart';


/// Shown immediately after a successful QR scan.
/// Confirms the user is "connected" to the machine as the current operator.
/// The user must press "Unown Machine" before they can scan a different machine.
class MachineQrConnectedScreen extends ConsumerStatefulWidget {
  final MachineModel machine;
  final String operatorName;

  const MachineQrConnectedScreen({
    super.key,
    required this.machine,
    required this.operatorName,
  });

  @override
  ConsumerState<MachineQrConnectedScreen> createState() =>
      _MachineQrConnectedScreenState();
}

class _MachineQrConnectedScreenState
    extends ConsumerState<MachineQrConnectedScreen>
    with SingleTickerProviderStateMixin {
  bool _isUnowning = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _unownMachine() async {
    if (_isUnowning) return;
    setState(() => _isUnowning = true);

    try {
      await ref.read(machineRepositoryProvider).updateMachineOperator(
            widget.machine.machineId,
            null,
            null,
          );

      if (!mounted) return;
      // Pop back — the QRScanScreen's finally block handles resetting state
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unown machine: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      setState(() => _isUnowning = false);
    }
  }


  void _openMachineDetail() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MachineDetailScreen(machine: widget.machine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent back-swipe: user must explicitly unown
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF4FB),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),

                // ── Pulsing connected indicator ──────────────────────────
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3B717B).withValues(alpha: 0.12),
                        border: Border.all(
                          color: const Color(0xFF3B717B),
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.wifi_tethering_rounded,
                        size: 56,
                        color: Color(0xFF3B717B),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── "Connected" label ────────────────────────────────────
                const Center(
                  child: Text(
                    'CONNECTED',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B717B),
                      letterSpacing: 2.5,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Machine name ─────────────────────────────────────────
                Center(
                  child: Text(
                    widget.machine.machineName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Operator info
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 16, color: Color(0xFF547589)),
                      const SizedBox(width: 6),
                      Text(
                        widget.operatorName,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF547589),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── "Open Machine" button ────────────────────────────────
                FilledButton.icon(
                  onPressed: _openMachineDetail,
                  icon: const Icon(Icons.dashboard_rounded),
                  label: const Text('Open Machine Dashboard'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF3B717B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── "Unown" button ───────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: _isUnowning ? null : _unownMachine,
                  icon: _isUnowning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFB0583A),
                          ),
                        )
                      : const Icon(Icons.link_off_rounded,
                          color: Color(0xFFB0583A)),
                  label: Text(
                    _isUnowning ? 'Disconnecting...' : 'Unown Machine',
                    style: const TextStyle(
                      color: Color(0xFFB0583A),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: Color(0xFFB0583A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
