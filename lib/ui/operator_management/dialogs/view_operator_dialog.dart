// lib/ui/operator_management/dialogs/view_operator_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/base_dialog.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_action.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_fields.dart';
import 'package:flutter_application_1/utils/format.dart';

class ViewOperatorDialog extends StatelessWidget {
  final TeamMember operator;

  const ViewOperatorDialog({super.key, required this.operator});

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: '${operator.firstName} ${operator.lastName}',
      subtitle: 'Operator Details',
      maxHeightFactor: 0.6,
      content: ReadOnlySection(
        fields: [
          ReadOnlyField(
            label: 'First Name',
            value: operator.firstName,
          ),
          ReadOnlyField(
            label: 'Last Name',
            value: operator.lastName,
          ),
          ReadOnlyField(
            label: 'Email',
            value: operator.email,
          ),
          ReadOnlyField(
            label: 'Status',
            value: toTitleCase(operator.status.value),
          ),
          ReadOnlyField(
            label: 'Operator ID',
            value: operator.id,
          ),
          ReadOnlyField(
            label: 'Added At',
            value: formatDateAndTime(operator.addedAt),
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