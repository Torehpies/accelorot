import 'package:flutter/material.dart';
import '../models/admin_user_model.dart';
import 'user_card.dart';

class UserManagementSection extends StatelessWidget {
  final String title;
  final List<AdminUserModel> users;
  final VoidCallback? onManageTap;
  final Function(AdminUserModel)? onUserTap;

  const UserManagementSection({
    super.key,
    this.title = 'User Management',
    required this.users,
    this.onManageTap,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildUserList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: onManageTap,
          child: const Text(
            'Manage >',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserList() {
    if (users.isEmpty) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No users available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < users.length - 1 ? 12 : 0,
            ),
            child: UserCard(
              user: users[index],
              onTap: onUserTap != null ? () => onUserTap!(users[index]) : null,
            ),
          );
        },
      ),
    );
  }
}