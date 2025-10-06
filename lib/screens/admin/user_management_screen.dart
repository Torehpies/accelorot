import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/user_card.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/admin/add_user/archive_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> users = [
    UserModel(name: "Joy Merk", email: "joymerk@gmail.com"),
    UserModel(name: "Test User", email: "test@gmail.com"),
  ];

  List<UserModel> archivedUsers = [];

  void moveToArchive(UserModel user) {
    setState(() {
      users.remove(user);
      archivedUsers.add(user);
    });
  }

  void restoreFromArchive(UserModel user) {
    setState(() {
      archivedUsers.remove(user);
      users.add(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header AppBar Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // to balance alignment
                  const Text(
                    "User List",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      // Archive Button
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
                        child: const Text(
                          "Archive",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Add User Button
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
            ),
            const Divider(),

            // 🔹 User List
            Expanded(
              child: users.isEmpty
                  ? const Center(
                      child: Text(
                        "No active users",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return UserCard(
                          name: user.name,
                          email: user.email,
                          onDelete: () => moveToArchive(user),
                          onEdit: () {
                            
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
