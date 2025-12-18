// lib/ui/activity_logs/view/base_detail_view.dart

import 'package:flutter/material.dart';
import '../../../data/models/activity_log_item.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/widgets/shared/detail_field.dart';
import 'detail_view_config.dart';

/// Universal detail view for all activity types
/// Replaces ReportDetailView, AlertDetailView, SubstrateDetailView, CycleDetailView
class BaseDetailView extends StatelessWidget {
  final ActivityLogItem item;

  const BaseDetailView({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final config = DetailViewConfig.getConfig(item);

    return Container(
      height: MediaQuery.of(context).size.height * config.heightRatio,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context, config),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: _buildFields(config),
            ),
          ),

          // Footer
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ViewConfig config) {
    return Container(
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
                Text(
                  config.title,
                  style: WebTextStyles.label.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF111827)),
                ),
                const SizedBox(height: 4),
                Text(
                  config.subtitle,
                  style: WebTextStyles.bodyMediumGray,
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
    );
  }

  Widget _buildFields(ViewConfig config) {
    return Column(
      children: config.fields.map((field) {
        if (field is RowFields) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DetailField(
                    label: field.field1.label,
                    value: field.field1.getValue(item),
                    isMultiline: field.field1.isMultiline,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: DetailField(
                    label: field.field2.label,
                    value: field.field2.getValue(item),
                    isMultiline: field.field2.isMultiline,
                  ),
                ),
              ],
            ),
          );
        } else if (field is SingleField) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: DetailField(
              label: field.label,
              value: field.getValue(item),
              isMultiline: field.isMultiline,
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
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
            child: Text(
              'Close',
              style: WebTextStyles.bodyMedium.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}