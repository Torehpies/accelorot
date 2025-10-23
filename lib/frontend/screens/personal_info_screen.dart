import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/components/edit_profile_modal.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Info"),
        backgroundColor: Colors.green.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const EditProfileModal(
                  firstName: "Miguel Andres",
                  lastName: "Reyes",
                  username: "MiguelReyes",
                  role: "User",
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + Name + Email
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150/2E7D32/FFFFFF?text=M',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Miguel Andres Reyes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "miguelreyes@email.com",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 👇 Use Text + Divider instead of TextField for read-only data
              _buildInfoRow("Username", "MiguelReyes"),
              const SizedBox(height: 16),
              _buildInfoRow("Full Name", "Miguel Andres Reyes"),
              const SizedBox(height: 16),
              _buildInfoRow("Email Address", "miguelreyes@email.com"),
              const SizedBox(height: 16),
              _buildInfoRow("Role", "User"),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const Divider(height: 24), // Optional: adds subtle line
      ],
    );
  }
}