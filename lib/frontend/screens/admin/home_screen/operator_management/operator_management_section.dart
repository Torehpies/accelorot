// operator_management_section.dart
import 'package:flutter/material.dart';
import '../models/operator_model.dart';
import 'widgets/operator_card.dart';
import 'widgets/operator_detail_dialog.dart';

/// Section widget for displaying and managing operators with unlimited scroll
class OperatorManagementSection extends StatelessWidget {
  final List<OperatorModel> operators;
  final VoidCallback? onManageTap;

  const OperatorManagementSection({
    super.key,
    required this.operators,
    this.onManageTap,
  });

  /// Show operator detail dialog on card tap
  void _showOperatorDetails(BuildContext context, OperatorModel operator) {
    showDialog(
      context: context,
      builder: (context) => OperatorDetailDialog(operator: operator),
    );
  }

  /// Build main card container
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildOperatorList(context),
          ],
        ),
      ),
    );
  }

  /// Build header with small icon, title, and manage link
  Widget _buildHeader() {
    return Row(
      children: [
        // Small teal person icon (same size as text)
        Icon(
          Icons.person,
          color: Colors.teal.shade600,
          size: 20,
        ),
        const SizedBox(width: 8),
        // Section title
        const Text(
          'Operator Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        // Manage link
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

  /// Build horizontal scrolling list of operator cards (unlimited scroll)
  Widget _buildOperatorList(BuildContext context) {
    if (operators.isEmpty) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No operators available',
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
        itemCount: operators.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < operators.length - 1 ? 12 : 0,
            ),
            child: OperatorCard(
              operator: operators[index],
              onTap: () => _showOperatorDetails(context, operators[index]),
            ),
          );
        },
      ),
    );
  }
}