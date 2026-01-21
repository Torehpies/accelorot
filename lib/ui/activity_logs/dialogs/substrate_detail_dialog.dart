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
          // All substrate information in one gray section
          ReadOnlySection(
            fields: [
              ReadOnlyField(
                label: 'Title',
                value: substrate.title,
              ),
              ReadOnlyField(
                label: 'Category',
                value: substrate.category,
              ),
              ReadOnlyField(
                label: 'Quantity',
                value: '${substrate.quantity.toStringAsFixed(2)} kg',
              ),
              ReadOnlyField(
                label: 'Machine Name',
                value: substrate.machineName ?? 'N/A',
              ),
              ReadOnlyField(
                label: 'Submitted By',
                value: substrate.operatorName ?? 'Unknown',
              ),
              
              // Description as multiline field
              ReadOnlyMultilineField(
                label: 'Description',
                value: substrate.description,
              ),
              
              // Date Added
              ReadOnlyField(
                label: 'Date Added',
                value: DateFormat('MM/dd/yyyy, hh:mm a').format(substrate.timestamp),
              ),
              
              // Batch ID if available
              if (substrate.batchId != null)
                ReadOnlyField(
                  label: 'Batch ID',
                  value: substrate.batchId!,
                ),
            ],
          ),
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