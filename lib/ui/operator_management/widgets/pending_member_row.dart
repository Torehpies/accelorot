import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/ui/core/constants/spacing.dart';
import 'package:flutter_application_1/ui/core/themes/web_text_styles.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_row.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/operator_management/widgets/pending_member_action_buttons.dart';
import 'package:flutter_application_1/utils/format.dart';

class PendingMemberRow extends StatelessWidget {
  final PendingMember member;
  final PendingMembersNotifier notifier;

  const PendingMemberRow({super.key, required this.member, required this.notifier});

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

        // Email (flex: 2)
        TableCellWidget(
          flex: 2,
          child: Text(
            member.email,
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),

        // Requested At (flex: 2)
        TableCellWidget(
          flex: 2,
          child: Text(
            formatDateAndTime(member.requestedAt),
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),

        // Actions (flex: 1)
        TableCellWidget(
          flex: 1,
          child: Center(
            child: PendingMemberActionButtons(
              notifier: notifier,
              member: member,
            ),
          ),
        ),
      ],
    );
  }
}