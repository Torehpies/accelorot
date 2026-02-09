// lib/ui/operator_dashboard/widgets/quick_actions/quick_actions_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import '../../../core/dialog/base_dialog.dart';
import '../../../core/dialog/dialog_action.dart';
import '../../../core/themes/web_colors.dart';
import '../../../core/themes/web_text_styles.dart';
import '../add_waste/add_waste_dialog.dart';
import '../submit_report/submit_report_dialog.dart';

class QuickActionsDialog extends StatelessWidget {
  final String? preSelectedMachineId;
  final String? preSelectedBatchId;

  const QuickActionsDialog({
    super.key,
    this.preSelectedMachineId,
    this.preSelectedBatchId,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Quick Actions',
      subtitle: 'Choose an action to perform',
      actions: [
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add Waste Product Option
          _WebActionTile(
            icon: Icons.inventory_2,
            iconColor: AppColors.green100,
            title: 'Add Waste Product',
            subtitle: 'Log waste material for composting',
            onTap: () async {
              Navigator.of(context).pop(); // Close quick actions
              
              final result = await showDialog<bool>(
                context: context,
                barrierColor: WebColors.dialogBarrier,
                barrierDismissible: false,
                builder: (context) => AddWasteDialog(
                  preSelectedMachineId: preSelectedMachineId,
                  preSelectedBatchId: preSelectedBatchId,
                ),
              );

              if (result == true && context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
          
          const SizedBox(height: 16),
          
          // Submit Report Option
          _WebActionTile(
            icon: Icons.description,
            iconColor: AppColors.error,
            title: 'Submit Report',
            subtitle: 'Create maintenance or observation report',
            onTap: () async {
              Navigator.of(context).pop(); // Close quick actions
              
              final result = await showDialog<bool>(
                context: context,
                barrierColor: WebColors.dialogBarrier,
                barrierDismissible: false,
                builder: (context) => SubmitReportDialog(
                  preSelectedMachineId: preSelectedMachineId,
                  preSelectedBatchId: preSelectedBatchId,
                ),
              );

              if (result == true && context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _WebActionTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _WebActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_WebActionTile> createState() => _WebActionTileState();
}

class _WebActionTileState extends State<_WebActionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered 
                ? WebColors.greenAccent.withValues(alpha: 0.05)
                : WebColors.badgeBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: WebColors.cardBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: WebTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: WebTextStyles.bodyMedium.copyWith(
                        color: WebColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: WebColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}