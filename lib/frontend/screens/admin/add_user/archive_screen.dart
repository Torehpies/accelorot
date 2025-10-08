import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/components/user_card.dart';
import 'package:flutter_application_1/frontend/models/user_model.dart';


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
      appBar: AppBar(
        title: const Text('Archive'),
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 77, 68, 68),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 77, 68, 68)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.archivedUsers.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.archive_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No archived users',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              itemCount: widget.archivedUsers.length,
              itemBuilder: (context, index) {
                final user = widget.archivedUsers[index];
                return UserCard(
                  user: user,
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
    );
  }
}