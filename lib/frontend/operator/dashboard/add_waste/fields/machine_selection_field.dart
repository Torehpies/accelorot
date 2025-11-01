import 'package:flutter/material.dart';
import '../../../../operator/machine_management/models/machine_model.dart';
import '../../../../../services/machine_services/firestore_machine_service.dart';

class MachineSelectionField extends StatelessWidget {
  final String? selectedMachineId;
  final Function(String?) onChanged;

  const MachineSelectionField({
    super.key,
    required this.selectedMachineId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MachineModel>>(
      future: FirestoreMachineService.getMachinesByOperatorId(
        FirestoreMachineService.getCurrentUserId() ?? '',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text('Error loading machines');
        }

        final machines = snapshot.data ?? [];
        if (machines.isEmpty) {
          return const Text(
            'No machines available. Please add a machine first.',
            style: TextStyle(color: Colors.red),
          );
        }

        return DropdownButtonFormField<String>(
          value: selectedMachineId,
          decoration: InputDecoration(
            labelText: 'Select Machine',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: machines.map((machine) {
            return DropdownMenuItem<String>(
              value: machine.machineId,
              child: Text(machine.machineName),
            );
          }).toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}