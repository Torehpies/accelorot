// lib/ui/machine_management/new_widgets/web_admin_add_dialog.dart

import 'package:flutter/material.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/constants/spacing.dart';

class WebAdminAddDialog extends StatefulWidget {
  final Future<void> Function({
    required String machineId,
    required String machineName,
  }) onCreate;

  const WebAdminAddDialog({
    super.key,
    required this.onCreate,
  });

  @override
  State<WebAdminAddDialog> createState() => _WebAdminAddDialogState();
}

class _WebAdminAddDialogState extends State<WebAdminAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: WebColors.textLabel),
      floatingLabelStyle: const TextStyle(color: WebColors.tealAccent),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: WebColors.tealAccent, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: WebColors.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onCreate(
        machineId: _idController.text.trim(),
        machineName: _nameController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Machine added successfully'),
          backgroundColor: WebColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: WebColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      decoration: BoxDecoration(
        color: WebColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration('Machine Name *'),
                    enabled: !_isSubmitting,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Machine Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _idController,
                    decoration: _buildInputDecoration('Machine ID *'),
                    enabled: !_isSubmitting,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Machine ID is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: TextEditingController(text: 'All Team Members'),
                    decoration: _buildInputDecoration('Assigned Users').copyWith(
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    enabled: false,
                    readOnly: true,
                  ),
                ],
              ),
            ),
            
            _buildFooter(context),
          ],
        ),
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
              Icons.add,
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
                  'Add Machine',
                  style: WebTextStyles.label.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: WebColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add a new machine to your collection',
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
                  : const Text('Add Machine'),
            ),
          ),
        ],
      ),
    );
  }
}