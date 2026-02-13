// lib/ui/activity_logs/bottom_sheets/mobile_substrate_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/substrate.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_field.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_section.dart';

class MobileSubstrateDetailSheet extends StatelessWidget {
  final Substrate substrate;

  const MobileSubstrateDetailSheet({super.key, required this.substrate});

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: substrate.title,
      subtitle: 'Substrate Details',
      actions: [
        BottomSheetAction.secondary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      body: MobileReadOnlySection(
        fields: [
          MobileReadOnlyField(
            label: 'Category',
            value: substrate.category,
          ),
          MobileReadOnlyField(
            label: 'Quantity',
            value: '${substrate.quantity.toStringAsFixed(2)} kg',
          ),
          MobileReadOnlyField(
            label: 'Machine Name',
            value: substrate.machineName ?? 'N/A',
          ),
          MobileReadOnlyField(
            label: 'Submitted By',
            value: substrate.operatorName ?? 'Unknown',
          ),
          MobileReadOnlyField(
            label: 'Description',
            value: substrate.description,
          ),
          MobileReadOnlyField(
            label: 'Date Added',
            value: DateFormat('MM/dd/yyyy, hh:mm a').format(substrate.timestamp),
          ),
          if (substrate.batchId != null)
            MobileReadOnlyField(
              label: 'Batch ID',
              value: substrate.batchId!,
            ),
        ],
      ),
    );
  }
}