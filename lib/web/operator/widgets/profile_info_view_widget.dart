// lib/frontend/operator/web/widgets/profile_info_view_widget.dart
import 'package:flutter/material.dart';

class ProfileInfoViewWidget extends StatelessWidget {
  final String displayName;
  final String fullName;
  final String email;
  final String role;

  const ProfileInfoViewWidget({
    super.key,
    required this.displayName,
    required this.fullName,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoField('Username', displayName)),
            const SizedBox(width: 24),
            Expanded(child: _buildInfoField('Full Name', fullName)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildInfoField('Email Address', email)),
            const SizedBox(width: 24),
            Expanded(child: _buildInfoField('Role', role)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
