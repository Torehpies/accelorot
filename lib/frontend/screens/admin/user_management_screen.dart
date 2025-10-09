import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/components/user_card.dart';
import 'package:flutter_application_1/frontend/models/user_model.dart';
import 'package:flutter_application_1/frontend/screens/admin/add_user/archive_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> users = [
    UserModel(
      id: '1',
      name: 'Joy Merk',
      email: 'joymerk@gmail.com',
      isActive: true,
    ),
    UserModel(
      id: '2',
      name: 'Test User',
      email: 'test@gmail.com',
      isActive: false,
    ),
    UserModel(
      id: '3',
      name: 'John DoeDoe',
      email: 'johndoe@example.com',
      isActive: true,
    ),
  ];

  List<UserModel> archivedUsers = [];

  void _deleteUser(UserModel user) {
    setState(() {
      users.remove(user);
      archivedUsers.add(user);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User moved to archive')),
    );
  }

  void _editUser(UserModel user) {
    // TODO: Navigate to edit user screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit user ${user.name}')),
    );
  }

  void restoreFromArchive(UserModel user) {
    setState(() {
      archivedUsers.remove(user);
      users.add(user);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User restored successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 77, 68, 68),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              // Navigate to Archive and wait for possible restore
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArchiveScreen(
                    archivedUsers: archivedUsers,
                    onRestore: restoreFromArchive,
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: const Text(
              'Archive List',
              style: TextStyle(color: Color.fromARGB(255, 77, 68, 68)),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add user screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add user')),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Add User', style: TextStyle(color: Colors.white, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: users.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No users found',
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
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return UserCard(
                  user: user,
                  onDelete: () => _deleteUser(user),
                  onEdit: () => _editUser(user),
                );
              },
            ),
    );
  }
}