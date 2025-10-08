import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/user_card.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/screens/admin/add_user/archive_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> users = [
    User(id: '1', name: 'Joy Merk', email: 'joymerk@gmail.com', isActive: true),
    User(id: '2', name: 'Test User', email: 'test@gmail.com', isActive: false),
    User(id: '3', name: 'John DoeDoe', email: 'johndoe@example.com', isActive: true),
  ];

  List<User> archivedUsers = [];

  void _deleteUser(User user) {
    setState(() {
      users.remove(user);
      archivedUsers.add(user);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User moved to archive')),
    );
  }

  void _editUser(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit user ${user.name}')),
    );
  }

  void _restoreFromArchive(User user) {
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
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArchiveScreen(
                    archivedUsers: archivedUsers,
                    onRestore: _restoreFromArchive,
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(elevation: 0),
            child: const Text(
              'Archive List',
              style: TextStyle(color: Color.fromARGB(255, 77, 68, 68)),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add user')),
                );
              
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Add User', style: TextStyle(color: Colors.white, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No users found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  // Action buttons when empty
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArchiveScreen(
                                archivedUsers: archivedUsers,
                                onRestore: _restoreFromArchive,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Archive", style: TextStyle(color: Colors.black)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Add User"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
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