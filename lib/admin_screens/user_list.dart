import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/user_card.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<User> users = [
    User(
      id: '1',
      name: 'USER1',
      email: 'User1@accelorot.com',
      isActive: true,
    ),
    User(
      id: '2',
      name: 'User2',
      email: 'User2@gmail.com',
      isActive: false,
    ),
    User(
      id: '3',
      name: 'User3',
      email: 'User3@gmail.com',
      isActive: false,
    ),
    User(
      id: '4',
      name: 'TheRock',
      email: 'SenBato@example.com',
      isActive: true,
    ),
    User(
      id: '5',
      name: 'Sheesh',
      email: 'shheeesh@ex.com',
      isActive: false,
    ),
  ];

  void _deleteUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  users.removeWhere((user) => user.id == userId);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _editUser(String userId) {
    // TODO: Navigate to edit user screen - will be added later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit user ')),
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
            onPressed: () {
              // TODO: Navigate to archive list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Archive list')),
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
                  onDelete: () => _deleteUser(user.id),
                  onConfirm: () => _editUser(user.id),
                );
              },
            ),
    );
  }
}