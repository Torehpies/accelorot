// lib/ui/activity_logs/view/substrate_detail_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/activity_log_item.dart';
import '../../core/constants/spacing.dart';

/// Detail view for substrates (matches Image 4 design)
class SubstrateDetailView extends StatelessWidget {
  final ActivityLogItem item;

  const SubstrateDetailView({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'View Substrate',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View in-depth information about this substrate.',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  _buildField('Title', item.title),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField('Category', item.category),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _buildField('Quantity (kg)', item.value),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildField('Machine Name', item.machineName ?? 'N/A'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildField(
                    'Description',
                    item.description,
                    isMultiline: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildField('Submitted By', item.operatorName ?? 'Unknown'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildField(
                    'Date Added',
                    DateFormat('MM/dd/yyyy, hh:mm a').format(item.timestamp),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7280),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value, {bool isMultiline = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
            maxLines: isMultiline ? null : 1,
          ),
        ),
      ],
    );
  }
}