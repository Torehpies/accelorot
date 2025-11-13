// lib/frontend/operator/machine_management/machine_view/machine_view_screen.dart
import 'package:flutter/material.dart';
import '../../machine_management/models/machine_model.dart';
import '../../../operator/dashboard/home_screen.dart';

class MachineViewScreen extends StatelessWidget {
  final MachineModel machine;

  const MachineViewScreen({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              machine.machineName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'ID: ${machine.machineId}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: HomeScreen(focusedMachine: machine),
    );
  }
}
