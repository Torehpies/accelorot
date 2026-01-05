import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/utils/format.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';

class ViewOperatorDialog extends StatelessWidget {
  final TeamMember operator;

  const ViewOperatorDialog({super.key, required this.operator});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background2,
      title: const Text(
        'Operator Details',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('View in-depth information about this operator.'),
            const Divider(thickness: 1, height: 24),
            const SizedBox(height: 5),
            _buildDetailsFields(context),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailsFields(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildReadOnlyField(
                  context: context,
                  label: 'First Name',
                  value: operator.firstName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildReadOnlyField(
                  context: context,
                  label: 'Last Name',
                  value: operator.lastName,
                ),
              ),
            ],
          ),
        ),

        _buildReadOnlyField(
          context: context,
          label: 'Email',
          value: operator.email,
        ),
        const SizedBox(height: 20),

        _buildReadOnlyField(
          context: context,
          label: 'Operator ID',
          value: operator.id,
        ),
        const SizedBox(height: 20),

        _buildReadOnlyField(
          context: context,
          label: 'Status',
          value: toTitleCase(operator.status.value),
        ),
        const SizedBox(height: 20),

        _buildReadOnlyField(
          context: context,
          label: 'Added At',
          value: _formatDate(operator.addedAt),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _statusLabel(UserStatus status) {
    return switch (status) {
      UserStatus.active => 'Active',
      UserStatus.archived => 'Archived',
      UserStatus.removed => 'Removed',
      _ => status.value,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
