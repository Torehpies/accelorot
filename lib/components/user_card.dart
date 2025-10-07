import 'package:flutter/material.dart';
import '../models/user.model.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onRestore;
  final bool isArchived;

  const UserCard({
    super.key,
    required this.user,
    this.onDelete,
    this.onEdit,
    this.onRestore,
    this.isArchived = false,
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
          title: Text(isArchived ? 'Restore User' : 'Archive User'),
          content: Text(message, textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isArchived ? Colors.green : Colors.red,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                onConfirm();
              },
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          user.email,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isArchived) ...[
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isActive ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: user.isActive ? Colors.green.shade300 : Colors.red.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  user.isActive ? "Active" : "Inactive",
                  style: TextStyle(
                    color: user.isActive ? Colors.green[700] : Colors.red[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Delete Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    _showConfirmationDialog(
                      context,
                      message: "Are you sure you want to move this user to archive?",
                      onConfirm: onDelete ?? () {},
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.delete, color: Colors.red, size: 20),
                  ),
                ),
              ),
              // Edit Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.edit, color: Colors.green, size: 20),
                  ),
                ),
              ),
            ] else ...[
              // Restore Button for archived users
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    _showConfirmationDialog(
                      context,
                      message: "Are you sure you want to restore this user back to the User List?",
                      onConfirm: onRestore ?? () {},
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.restore, color: Colors.green, size: 20),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}