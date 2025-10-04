import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String email;
  final bool isArchived;
  final VoidCallback? onRestore;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const UserCard({
    super.key,
    required this.name,
    required this.email,
    this.isArchived = false,
    this.onRestore,
    this.onDelete,
    this.onEdit,
  });

  // Confirmation Dialog
  Future<void> _showConfirmationDialog(
    BuildContext context, {
    required String message,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          content: Text(message, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                onConfirm();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isArchived) ...[
              // Restore Button
              IconButton(
                icon: const Icon(Icons.restore, color: Colors.green),
                onPressed: () {
                  _showConfirmationDialog(
                    context,
                    message:
                        "Are you sure you want to restore this user back to the User List?",
                    onConfirm: onRestore ?? () {},
                  );
                },
              ),
            ] else ...[
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showConfirmationDialog(
                    context,
                    message: "Are you sure you want to move this to archive?",
                    onConfirm: onDelete ?? () {},
                  );
                },
              ),
              // Edit Button
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.green),
                onPressed: onEdit,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
