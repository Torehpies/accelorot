// lib/ui/activity_logs/dialogs/substrate_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/substrate.dart';
import '../../core/dialog/base_dialog.dart';
import '../../core/dialog/dialog_action.dart';
import '../../core/dialog/dialog_fields.dart';

class SubstrateDetailDialog extends StatelessWidget {
  final Substrate substrate;

  const SubstrateDetailDialog({
    super.key,
    required this.substrate,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'View Substrate',
      subtitle: 'View in-depth information about this substrate.',
      maxHeightFactor: 0.7,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReadOnlyField(label: 'Title:', value: substrate.title),
          const SizedBox(height: 16),
          
          ReadOnlyField(label: 'Category:', value: substrate.category),
          const SizedBox(height: 16),
          
          ReadOnlyField(
            label: 'Quantity:', 
            value: '${substrate.quantity.toStringAsFixed(2)} kg',
          ),
          const SizedBox(height: 16),
          
          ReadOnlyField(
            label: 'Machine Name:', 
            value: substrate.machineName ?? 'N/A',
          ),
          const SizedBox(height: 16),
          
          ReadOnlyMultilineField(
            label: 'Description:',
            value: substrate.description,
          ),
          const SizedBox(height: 16),
          
          ReadOnlyField(
            label: 'Submitted By:', 
            value: substrate.operatorName ?? 'Unknown',
          ),
          const SizedBox(height: 16),
          
          ReadOnlyField(
            label: 'Date Added:',
            value: DateFormat('MM/dd/yyyy, hh:mm a').format(substrate.timestamp),
          ),
          
          if (substrate.batchId != null) ...[
            const SizedBox(height: 16),
            ReadOnlyField(label: 'Batch ID:', value: substrate.batchId!),
          ],
        ],
      ),
      actions: [
        DialogAction.secondary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}