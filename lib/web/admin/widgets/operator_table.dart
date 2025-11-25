// lib/web/widgets/operator_table.dart

import 'package:flutter/material.dart';
import '../models/operator.dart'; // 

class OperatorTable extends StatelessWidget {
  final List<Operator> operators;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const OperatorTable({
    super.key,
    required this.operators,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (_, _) => const Divider(height: 16, color: Colors.grey),
        itemCount: operators.length,
        itemBuilder: (context, index) {
          final operator = operators[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(operator.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                Expanded(flex: 4, child: Text(operator.email, style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)))),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: operator.isArchived ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ),
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