import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/constants/spacing.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/core/themes/web_text_styles.dart';
import 'package:flutter_application_1/ui/team_management/widgets/add_team_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamManagementHeader extends ConsumerWidget {
  const TeamManagementHeader({super.key});

  void _showAddTeamDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AddTeamDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.group, color: WebColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text('Teams', style: WebTextStyles.sectionTitle),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddTeamDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Team'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
