// lib/ui/machine_management/helpers/machine_status_helper.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';

/// Extension methods on MachineModel for UI-specific properties
extension MachineModelUI on MachineModel {
  Color get iconColor {
    if (isArchived) {
      return const Color(0xFFFFB74D);
    }

    switch (status) {
      case MachineStatus.active:
        return const Color(0xFF66BB6A);
      case MachineStatus.inactive:
        return const Color(0xFFFFB74D);
      case MachineStatus.underMaintenance:
        return const Color(0xFFEF5350);
    }
  }

  Color get statusBgColor {
    if (isArchived) {
      return const Color(0xFFFFF4E6);
    }

    switch (status) {
      case MachineStatus.active:
        return const Color(0xFFE8F5E9);
      case MachineStatus.inactive:
        return const Color(0xFFFFF4E6);
      case MachineStatus.underMaintenance:
        return const Color(0xFFFFEBEE);
    }
  }

  String get statusLabel {
    if (isArchived) {
      return 'Archived';
    }

    switch (status) {
      case MachineStatus.active:
        return 'Active';
      case MachineStatus.inactive:
        return 'Inactive';
      case MachineStatus.underMaintenance:
        return 'Under Maintenance';
    }
  }

  String get cardDescription {
    return 'ID: $machineId';
  }

  String get formattedDateCreated {
    return DateFormat('MMM dd, yyyy').format(dateCreated);
  }
}