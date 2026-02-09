// lib/ui/operator_dashboard/fields/machine_selection_field.dart

import 'package:flutter/material.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_dropdown_field.dart';
import '../../core/skeleton/skeleton_dropdown.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/services/firebase/firebase_machine_service.dart';
import '../../../data/repositories/machine_repository/machine_repository.dart';
import '../../../data/repositories/machine_repository/machine_repository_remote.dart';
import '../../../services/sess_service.dart';

class MachineSelectionField extends StatefulWidget {
  final String? selectedMachineId;
  final Function(String?)? onChanged;
  final bool isLocked;
  final String? errorText;

  const MachineSelectionField({
    super.key,
    required this.selectedMachineId,
    this.onChanged,
    this.isLocked = false,
    this.errorText,
  });

  @override
  State<MachineSelectionField> createState() => _MachineSelectionFieldState();
}

class _MachineSelectionFieldState extends State<MachineSelectionField> {
  late final MachineRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = MachineRepositoryRemote(FirebaseMachineService());
  }

  /// Fetch machines based on user's teamId
  Future<List<MachineModel>> _fetchTeamMachines() async {
    final sessionService = SessionService();
    final userData = await sessionService.getCurrentUserData();

    if (userData == null) {
      throw Exception('User not authenticated');
    }

    final teamId = userData['teamId'] as String?;
    if (teamId == null || teamId.isEmpty) {
      throw Exception('User not assigned to a team');
    }

    return await _repository.getMachinesByTeam(teamId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MachineModel>>(
      future: _fetchTeamMachines(),
      builder: (context, snapshot) {
        // Show skeleton loader while loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SkeletonDropdown(
            label: 'Machine',
            showRequired: true,
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }

        final machines = snapshot.data ?? [];
        if (machines.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'No machines available for your team. Please contact your admin.',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Convert machines to dropdown items
        final items = machines.map((machine) {
          return MobileDropdownItem<String>(
            value: machine.machineId,
            label: machine.machineName,
          );
        }).toList();

        return MobileDropdownField<String>(
          label: 'Machine',
          value: widget.selectedMachineId,
          items: items,
          required: true,
          enabled: !widget.isLocked,
          onChanged: widget.isLocked ? null : widget.onChanged,
          errorText: widget.errorText,
          hintText: 'Select machine',
          helperText: widget.isLocked ? 'Machine is locked for this context' : null,
        );
      },
    );
  }
}