import 'package:flutter/material.dart';
import '../models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onDelete;
  final VoidCallback onConfirm;

  const UserCard({
    super.key,
    required this.user,
    required this.onDelete,
    required this.onConfirm,
  });

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
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onConfirm,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.edit, color: Colors.green, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}