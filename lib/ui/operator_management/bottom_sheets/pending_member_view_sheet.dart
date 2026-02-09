// lib/ui/web_operator/bottom_sheets/pending_member_view_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_base.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_buttons.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_field.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_section.dart';

class PendingMemberViewSheet extends StatelessWidget {
  final PendingMember member;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const PendingMemberViewSheet({
    super.key,
    required this.member,
    required this.onAccept,
    required this.onDecline,
  });

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: '${member.lastName}, ${member.firstName}',
      subtitle: 'Pending Request',
      actions: [
        BottomSheetAction.destructive(
          label: 'Decline',
          onPressed: onDecline,
        ),
        BottomSheetAction.primary(
          label: 'Accept',
          onPressed: onAccept,
        ),
      ],
      body: MobileReadOnlySection(
        sectionTitle: null,
        fields: [
          MobileReadOnlyField(label: 'Email', value: member.email),
          MobileReadOnlyField(
            label: 'Requested At',
            value: _formatDateTime(member.requestedAt),
          ),
        ],
      ),
    );
  }
}