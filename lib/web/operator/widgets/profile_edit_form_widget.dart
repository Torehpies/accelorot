// lib/frontend/operator/web/widgets/profile_edit_form_widget.dart
import 'package:flutter/material.dart';

class ProfileEditFormWidget extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController fullNameController;
  final String email;
  final String role;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const ProfileEditFormWidget({
    super.key,
    required this.usernameController,
    required this.fullNameController,
    required this.email,
    required this.role,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  enabled: false,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: TextFormField(
                  initialValue: role,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  enabled: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: onDiscard,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Discard'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}