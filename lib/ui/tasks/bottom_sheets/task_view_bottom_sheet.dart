// lib/ui/tasks/bottom_sheets/task_view_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../../data/models/task_model.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_field.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_section.dart';

class TaskViewBottomSheet extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onMarkComplete;

  const TaskViewBottomSheet({
    super.key,
    required this.task,
    required this.onMarkComplete,
  });

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: task.title,
      subtitle: 'Task Details',
      actions: [
        if (!task.isCompleted)
          BottomSheetAction.primary(
            label: 'Mark Complete',
            onPressed: onMarkComplete,
          ),
      ],
      body: MobileReadOnlySection(
        sectionTitle: null,
        fields: [
          MobileReadOnlyField(label: 'Task ID', value: task.id),
          MobileReadOnlyField(label: 'Status', value: task.statusLabel),
          MobileReadOnlyField(label: 'Priority', value: task.priorityLabel),
          MobileReadOnlyField(
            label: 'Assigned To',
            value: task.assignedToName,
          ),
          MobileReadOnlyField(
            label: 'Created By',
            value: task.createdByName,
          ),
          MobileReadOnlyField(
            label: 'Description',
            value: task.description,
          ),
          if (task.machineName != null)
            MobileReadOnlyField(
              label: 'Machine',
              value: task.machineName!,
            ),
          if (task.dueDate != null)
            MobileReadOnlyField(
              label: 'Due Date',
              value:
                  '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
            ),
          if (task.notes != null && task.notes!.isNotEmpty)
            MobileReadOnlyField(label: 'Notes', value: task.notes!),
          MobileReadOnlyField(
            label: 'Created At',
            value: _formatDateTime(task.createdAt),
          ),
          if (task.updatedAt != null)
            MobileReadOnlyField(
              label: 'Updated At',
              value: _formatDateTime(task.updatedAt!),
            ),
          if (task.completedAt != null)
            MobileReadOnlyField(
              label: 'Completed At',
              value: _formatDateTime(task.completedAt!),
            ),
        ],
      ),
    );
  }
}
