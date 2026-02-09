// lib/ui/web_operator/bottom_sheets/team_member_view_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/edit_operator_dialog.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_base.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_buttons.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_field.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_section.dart';

typedef UpdateTeamMemberCallback = Future<void> Function(EditOperatorForm form);

class TeamMemberViewSheet extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onEdit;

  const TeamMemberViewSheet({
    super.key,
    required this.member,
    required this.onEdit,
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

  String _getStatusLabel(String statusValue) {
    return statusValue.substring(0, 1).toUpperCase() + statusValue.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: '${member.lastName}, ${member.firstName}',
      subtitle: 'Team Member',
      actions: [
        BottomSheetAction.primary(
          label: 'Edit',
          onPressed: onEdit,
        ),
      ],
      body: MobileReadOnlySection(
        sectionTitle: null,
        fields: [
          MobileReadOnlyField(label: 'Member ID', value: member.id),
          MobileReadOnlyField(label: 'Email', value: member.email),
          MobileReadOnlyField(
            label: 'Status',
            value: _getStatusLabel(member.status.value),
          ),
          MobileReadOnlyField(
            label: 'Created',
            value: _formatDateTime(member.addedAt),
          ),
        ],
      ),
    );
  }
}