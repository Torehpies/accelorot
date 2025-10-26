import 'package:flutter/material.dart';
import '../models/operator_model.dart';
import 'widgets/operator_card.dart';
import 'widgets/operator_detail_dialog.dart';

/// Section widget for displaying and managing operators
class OperatorManagementSection extends StatelessWidget {
  final List<OperatorModel> operators;
  final VoidCallback? onManageTap;

  const OperatorManagementSection({
    super.key,
    required this.operators,
    this.onManageTap,
  });

  void _showOperatorDetails(BuildContext context, OperatorModel operator) {
    showDialog(
      context: context,
      builder: (context) => OperatorDetailDialog(operator: operator),
    );
  }

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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Operator Management',
          style: TextStyle(
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