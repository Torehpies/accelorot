import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/core/constants/spacing.dart';
import 'package:flutter_application_1/ui/core/themes/web_text_styles.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_row.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/status_badge.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/team_member_action_buttons.dart';

class TeamMemberRow extends StatelessWidget {
  final TeamMember member;
  final TeamMembersNotifier notifier;

  const TeamMemberRow({
    super.key,
    required this.member,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return GenericTableRow(
      hoverColor: const Color(0xFFF9FAFB),
      cellSpacing: AppSpacing.md,
      cells: [
        // First Name (flex: 2)
        TableCellWidget(
          flex: 2,
          child: Text(
            member.firstName,
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),

        // Last Name (flex: 2)
        TableCellWidget(
          flex: 2,
          child: Text(
            member.lastName,
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),

        // Email (flex: 3)
        TableCellWidget(
          flex: 3,
          child: Text(
            member.email,
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),

        // Status (flex: 1)
        TableCellWidget(
          flex: 1,
          child: Center(child: StatusBadge(status: member.status.value)),
        ),

        // Actions (flex: 1)
        TableCellWidget(
          flex: 1,
          child: Center(
            child: TeamMemberActionButtons(notifier: notifier, member: member),
          ),
        ),
      ],
    );
  }
}

