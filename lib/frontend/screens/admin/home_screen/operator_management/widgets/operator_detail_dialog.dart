import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/operator_model.dart';
import '../../widgets/status_indicator.dart';

/// Dialog showing detailed operator information
class OperatorDetailDialog extends StatelessWidget {
  final OperatorModel operator;

  const OperatorDetailDialog({
    super.key,
    required this.operator,
  });

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 32),
            _buildDetailRow('Name', operator.name),
            const SizedBox(height: 16),
            _buildDetailRow('Email', operator.email),
            const SizedBox(height: 16),
            _buildDetailRow('Date Added', _formatDate(operator.addedAt)),
            const SizedBox(height: 24),
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Operator Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        StatusIndicator(
          isArchived: operator.isArchived,
          showText: true,
          size: 12,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Close'),
      ),
    );
  }
}