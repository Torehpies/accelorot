// lib/ui/qr_scan/view/qr_scan_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/providers/machine_providers.dart';
import '../../../data/providers/batch_providers.dart';
import '../../machine_detail_screen/view/machine_detail_screen.dart';
import '../view_model/qr_scan_viewmodel.dart';
import '../widgets/scan_frame_overlay.dart';

class QRScanScreen extends ConsumerStatefulWidget {
  const QRScanScreen({super.key});

  @override
  ConsumerState<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends ConsumerState<QRScanScreen> {
  late final MobileScannerController _scannerController;
  late final QrScanViewModel _viewModel;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = QrScanViewModel(
      machineRepo: ref.read(machineRepositoryProvider),
      batchRepo: ref.read(batchRepositoryProvider),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(String scannedValue) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final result = await _viewModel.validateScan(scannedValue);

    switch (result) {
      case QrScanSuccess(:final machine):
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MachineDetailScreen(machine: machine),
          ),
        );
      case QrScanError(:final message):
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildHeader(),
            const SizedBox(height: 32),
            _buildCameraPreview(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'I-scan ang makina',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A5F),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hanapin ang QR code sa drum composter',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF547589),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Camera
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final value = barcodes.first.rawValue;
                    if (value != null && value.isNotEmpty) {
                      _onDetect(value);
                    }
                  }
                },
              ),

              // Scan frame
              const ScanFrameOverlay(),

              // Loading overlay
              if (_isProcessing)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF4ECDC4)),
                        SizedBox(height: 16),
                        Text(
                          'Checking machine...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
