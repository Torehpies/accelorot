// archive_confirmation_dialog.dart
import 'package:flutter/material.dart';

class ArchiveConfirmationDialog extends StatelessWidget {
  final String operatorName;
  final VoidCallback onConfirm;

  const ArchiveConfirmationDialog({
    super.key,
    required this.operatorName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Archive Operator'),
      content: Text(
        'Are you sure you want to archive $operatorName?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Archive'),
        ),
      ],
    );
  }
}
