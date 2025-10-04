import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/user_card.dart';
import 'package:flutter_application_1/models/user_model.dart';

class ArchiveScreen extends StatefulWidget {
  final List<UserModel> archivedUsers;
  final Function(UserModel) onRestore;

  const ArchiveScreen({
    super.key,
    required this.archivedUsers,
    required this.onRestore,
  });

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Archive",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),

            // 🔹 Archived List
            Expanded(
              child: widget.archivedUsers.isEmpty
                  ? const Center(
                      child: Text(
                        "No archived users",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.archivedUsers.length,
                      itemBuilder: (context, index) {
                        final user = widget.archivedUsers[index];
                        return UserCard(
                          name: user.name,
                          email: user.email,
                          isArchived: true,
                          onRestore: () {
                            setState(() {
                              widget.archivedUsers.remove(user);
                            });
                            widget.onRestore(user);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
