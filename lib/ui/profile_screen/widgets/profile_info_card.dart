import 'package:flutter/material.dart';
import '../../../data/models/profile_model.dart';

class ProfileInfoCard extends StatelessWidget {
  final ProfileModel profile;
  final bool isSmallScreen;
  final double verticalSpacing;

  const ProfileInfoCard({
    super.key,
    required this.profile,
    required this.isSmallScreen,
    required this.verticalSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoField('Username', profile.displayName),
        SizedBox(height: verticalSpacing),
        _buildInfoField('Full Name', '${profile.firstName} ${profile.lastName}'.trim()),
        SizedBox(height: verticalSpacing),
        _buildInfoField('Email Address', profile.email),
        SizedBox(height: verticalSpacing),
        _buildInfoField('Role', profile.role),
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 10 : 12,
          horizontal: isSmallScreen ? 12 : 16,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}