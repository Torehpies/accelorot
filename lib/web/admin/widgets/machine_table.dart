// lib/web/widgets/machine_table.dart

import 'package:flutter/material.dart';
import '../models/machine.dart'; // 

class MachineTable extends StatelessWidget {
  final List<Machine> machines;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MachineTable({
    super.key,
    required this.machines,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (_, _) => const Divider(height: 16, color: Colors.grey),
        itemCount: machines.length,
        itemBuilder: (context, index) {
          final machine = machines[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                Expanded(flex: 4, child: Text(machine.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                Expanded(flex: 3, child: Text(machine.machineId, style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)))),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 14),
                        onPressed: onEdit,
                        color: Colors.blue,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 14),
                        onPressed: onDelete,
                        color: Colors.red,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}