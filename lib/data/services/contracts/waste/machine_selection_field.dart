import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/machine_management/models/machine_model.dart';
import '../../../../services/machine_services/firestore_machine_service.dart';
import '../../../../services/sess_service.dart';

class MachineSelectionField extends StatelessWidget {
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

    // ⭐ Fetch machines by teamId instead of operatorId
    return await FirestoreMachineService.getMachinesByTeamId(teamId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MachineModel>>(
      future: _fetchTeamMachines(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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

        return DropdownButtonFormField<String>(
          initialValue: selectedMachineId,
          decoration: InputDecoration(
            labelText: 'Select Machine',
            prefixIcon: const Icon(Icons.precision_manufacturing, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            suffixIcon: isLocked
                ? const Icon(Icons.lock, size: 18, color: Colors.grey)
                : null,
            errorText: errorText,
          ),
          items: machines.map((machine) {
            return DropdownMenuItem<String>(
              value: machine.machineId,
              enabled: !isLocked,
              child: Text(
                machine.machineName,
                style: TextStyle(
                  color: isLocked ? Colors.grey : Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: isLocked ? null : onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a machine';
            }
            return null;
          },
        );
      },
    );
  }
}
