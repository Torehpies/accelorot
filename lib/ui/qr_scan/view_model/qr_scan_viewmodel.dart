// lib/ui/qr_scan/view_model/qr_scan_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/repositories/machine_repository/machine_repository.dart';
import '../../../data/repositories/batch_repository/batch_repository.dart';

/// Result of a QR scan validation
sealed class QrScanResult {}

class QrScanSuccess extends QrScanResult {
  final MachineModel machine;
  QrScanSuccess(this.machine);
}

class QrScanError extends QrScanResult {
  final String message;
  QrScanError(this.message);
}

/// Handles QR scan business logic: machine lookup + team validation
class QrScanViewModel {
  final MachineRepository _machineRepo;
  final BatchRepository _batchRepo;

  QrScanViewModel({
    required MachineRepository machineRepo,
    required BatchRepository batchRepo,
  })  : _machineRepo = machineRepo,
        _batchRepo = batchRepo;

  /// Validate a scanned QR code value.
  /// Returns [QrScanSuccess] with the machine if valid,
  /// or [QrScanError] with a user-facing message.
  Future<QrScanResult> validateScan(String scannedValue) async {
    try {
      // 1. Check authentication
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return QrScanError('Please log in first.');
      }

      // 2. Look up the machine
      final machine = await _machineRepo.getMachineById(scannedValue);
      if (machine == null) {
        return QrScanError('Machine not found: $scannedValue');
      }

      // 3. Validate team membership
      final userTeamId = await _batchRepo.getUserTeamId(userId);
      if (userTeamId == null || userTeamId != machine.teamId) {
        return QrScanError("You don't have access to this machine.");
      }

      debugPrint('✅ QR scan validated: ${machine.machineName}');
      return QrScanSuccess(machine);
    } catch (e) {
      debugPrint('❌ QR scan error: $e');
      return QrScanError('Error scanning: $e');
    }
  }
}
