// lib/ui/qr_scan/view_model/qr_scan_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/repositories/machine_repository/machine_repository.dart';
import '../../../data/repositories/batch_repository/batch_repository.dart';
import '../../../data/repositories/app_user_repository/app_user_repository.dart';

/// Result of a QR scan validation
sealed class QrScanResult {}

class QrScanSuccess extends QrScanResult {
  final MachineModel machine;
  final String operatorName;
  QrScanSuccess(this.machine, this.operatorName);
}

class QrScanError extends QrScanResult {
  final String message;
  QrScanError(this.message);
}

/// Handles QR scan business logic: machine lookup + team validation + operator sync
class QrScanViewModel {
  final MachineRepository _machineRepo;
  final BatchRepository _batchRepo;
  final AppUserRepository _appUserRepo;

  QrScanViewModel({
    required MachineRepository machineRepo,
    required BatchRepository batchRepo,
    required AppUserRepository appUserRepo,
  })  : _machineRepo = machineRepo,
        _batchRepo = batchRepo,
        _appUserRepo = appUserRepo;

  /// Validate a scanned QR code value.
  /// On success, writes the scanning user as the current operator on the machine,
  /// so the ESP32 hardware can attribute manual button presses to this user.
  Future<QrScanResult> validateScan(String scannedValue) async {
    try {
      // 1. Check authentication
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        return QrScanError('Please log in first.');
      }

      // 2. Look up the machine
      final machine = await _machineRepo.getMachineById(scannedValue);
      if (machine == null) {
        return QrScanError('Machine not found: $scannedValue');
      }

      // 3. Validate team membership
      final userTeamId = await _batchRepo.getUserTeamId(firebaseUser.uid);
      if (userTeamId == null || userTeamId != machine.teamId) {
        return QrScanError("You don't have access to this machine.");
      }

      // 4. Resolve full name from AppUser (fallback to Firebase display name)
      String operatorName = firebaseUser.displayName ?? 'Operator';
      final userResult = await _appUserRepo.getUser(firebaseUser.uid);
      if (userResult.isSuccess) {
        final appUser = userResult.asSuccess;
        operatorName = '${appUser.firstname} ${appUser.lastname}'.trim();
      } else {
        debugPrint('⚠️ Could not fetch AppUser, using Firebase display name');
      }

      // 5. Push operator info to Firestore → ESP32 reads this on button press
      await _machineRepo.updateMachineOperator(
        machine.machineId,
        firebaseUser.uid,
        operatorName,
      );

      debugPrint('✅ QR scan validated: ${machine.machineName} | Operator: $operatorName');
      return QrScanSuccess(machine, operatorName);
    } catch (e) {
      debugPrint('❌ QR scan error: $e');
      return QrScanError('Error scanning: $e');
    }
  }
}
