// lib/ui/reports/view/report_detail_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/report.dart';
import '../../core/widgets/shared/detail_field.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/constants/spacing.dart';

class ReportDetailView extends StatefulWidget {
  final Report report;
  final Future<void> Function({
    required String machineId,
    required String reportId,
    String? title,
    String? description,
    String? status,
    String? priority,
  }) onUpdate;

  const ReportDetailView({
    super.key,
    required this.report,
    required this.onUpdate,
  });

  @override
  State<ReportDetailView> createState() => _ReportDetailViewState();
}

class _ReportDetailViewState extends State<ReportDetailView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedStatus;
  late String _selectedPriority;
  bool _isSubmitting = false;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'open', 'label': 'Open'},
    {'value': 'in_progress', 'label': 'In Progress'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'on_hold', 'label': 'On Hold'},
  ];

  final List<Map<String, String>> _priorityOptions = [
    {'value': 'high', 'label': 'High'},
    {'value': 'medium', 'label': 'Medium'},
    {'value': 'low', 'label': 'Low'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _descriptionController = TextEditingController(
      text: widget.report.description,
    );
    _selectedStatus = widget.report.status;
    _selectedPriority = widget.report.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String labelText, {bool readOnly = false}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: readOnly ? Colors.grey[400] : WebColors.textLabel),
      floatingLabelStyle: TextStyle(
        color: readOnly ? Colors.grey[400] : WebColors.tealAccent,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: readOnly ? Colors.grey[300]! : WebColors.tealAccent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: readOnly ? Colors.grey[300]! : WebColors.cardBorder,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: readOnly,
      fillColor: readOnly ? Colors.grey[100] : null,
    );
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      _showSnackBar('Title is required', WebColors.warning);
      return;
    }

    if (description.isEmpty) {
      _showSnackBar('Description is required', WebColors.warning);
      return;
    }

    // Check if anything changed
    if (title == widget.report.title &&
        description == widget.report.description &&
        _selectedStatus == widget.report.status &&
        _selectedPriority == widget.report.priority) {
      _showSnackBar('No changes detected', WebColors.info);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onUpdate(
        machineId: widget.report.machineId,
        reportId: widget.report.id,
        title: title,
        description: description,
        status: _selectedStatus,
        priority: _selectedPriority,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      _showSnackBar('Report updated successfully', WebColors.success);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to update report: $e', WebColors.error);
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: WebColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  // Row 1: Title and Description
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          decoration: _buildInputDecoration('Title *'),
                          enabled: !_isSubmitting,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          decoration: _buildInputDecoration('Description *'),
                          enabled: !_isSubmitting,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Row 2: Category and Submitted By
                  Row(
                    children: [
                      Expanded(
                        child: DetailField(
                          label: 'Category',
                          value: widget.report.reportTypeLabel,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: DetailField(
                          label: 'Submitted By',
                          value: widget.report.userName,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Row 3: Machine Name and Date Added
                  Row(
                    children: [
                      Expanded(
                        child: DetailField(
                          label: 'Machine Name',
                          value: widget.report.machineName,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: DetailField(
                          label: 'Date Added',
                          value: DateFormat('MM/dd/yyyy, hh:mm a')
                              .format(widget.report.createdAt),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Row 4: Status and Priority
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedStatus,
                          decoration: _buildInputDecoration('Status *'),
                          items: _statusOptions.map((option) {
                            return DropdownMenuItem(
                              value: option['value'],
                              child: Text(option['label']!),
                            );
                          }).toList(),
                          onChanged: _isSubmitting
                              ? null
                              : (value) => setState(() => _selectedStatus = value!),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedPriority,
                          decoration: _buildInputDecoration('Priority *'),
                          items: _priorityOptions.map((option) {
                            return DropdownMenuItem(
                              value: option['value'],
                              child: Text(option['label']!),
                            );
                          }).toList(),
                          onChanged: _isSubmitting
                              ? null
                              : (value) => setState(() => _selectedPriority = value!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Footer
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: WebColors.cardBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Report',
                  style: WebTextStyles.label.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: WebColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Update report details',
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

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: WebColors.cardBorder),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: WebColors.buttonSecondary,
              foregroundColor: WebColors.cardBackground,
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
              'Cancel',
              style: WebTextStyles.bodyMedium.copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: WebColors.tealAccent,
              foregroundColor: WebColors.cardBackground,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Confirm',
                    style: WebTextStyles.bodyMedium.copyWith(fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }
}