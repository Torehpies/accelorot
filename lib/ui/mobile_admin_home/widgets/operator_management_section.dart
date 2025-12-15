// lib/ui/mobile_admin_home/widgets/operator_management_section.dart

import 'package:flutter/material.dart';
import '../../../data/models/operator_model.dart';
import 'operator_card.dart';
import 'operator_detail_dialog.dart';

class OperatorManagementSection extends StatelessWidget {
  final List<OperatorModel> operators;
  final VoidCallback onManageTap;

  const OperatorManagementSection({
    super.key,
    required this.operators,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Operators', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(onPressed: onManageTap, child: const Text('Manage >', style: TextStyle(color: Colors.teal))),
        ],
      ),
      const SizedBox(height: 12),
      if (operators.isEmpty)
        const Center(child: Text('No operators yet'))
      else
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: operators.length,
            itemBuilder: (context, index) {
              final op = operators[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: OperatorCard(operator: op, onTap: () => _showDetail(context, op)),
              );
            },
          ),
        ),
    ]);
  }

  void _showDetail(BuildContext context, OperatorModel operator) {
    showDialog(context: context, builder: (_) => OperatorDetailDialog(operator: operator));
  }
}