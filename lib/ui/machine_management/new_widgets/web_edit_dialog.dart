// lib/ui/machine_management/new_widgets/web_edit_dialog.dart

import 'package:flutter/material.dart';
import '../../../data/models/machine_model.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/constants/spacing.dart';

class MachineEditDialog extends StatefulWidget {
  final MachineModel machine;
  final Future<void> Function({
    required String machineId,
    required String machineName,
  }) onUpdate;

  const MachineEditDialog({
    super.key,
    required this.machine,
    required this.onUpdate,
  });

  @override
  State<MachineEditDialog> createState() => _MachineEditDialogState();
}

class _MachineEditDialogState extends State<MachineEditDialog> {
  late final TextEditingController _nameController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.machine.machineName);
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Machine Name is required', WebColors.warning);
      return;
    }

    if (name == widget.machine.machineName) {
      _showSnackBar('No changes detected', WebColors.info);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onUpdate(
        machineId: widget.machine.machineId,
        machineName: name,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      _showSnackBar('Machine updated successfully', WebColors.success);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to update machine: $e', WebColors.error);
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
      width: 500,
      decoration: BoxDecoration(
        color: WebColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('Machine Name *'),
                  enabled: !_isSubmitting,
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: TextEditingController(text: widget.machine.machineId),
                  decoration: _buildInputDecoration('Machine ID (Cannot be changed)', readOnly: true),
                  enabled: false,
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: TextEditingController(text: 'All Team Members'),
                  decoration: _buildInputDecoration('Assigned Users', readOnly: true),
                  enabled: false,
                  readOnly: true,
                ),
              ],
            ),
          ),
          
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit,
              color: Color(0xFF92400E),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Machine',
                  style: WebTextStyles.label.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: WebColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Update machine details',
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
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: WebColors.buttonSecondary,
                foregroundColor: WebColors.cardBackground,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: WebColors.tealAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                  : const Text('Update Machine'),
            ),
          ),
        ],
      ),
    );
  }
}
