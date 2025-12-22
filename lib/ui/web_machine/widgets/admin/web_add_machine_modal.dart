import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../machine_management/view_model/admin_machine_notifier.dart';

class WebAddMachineModal extends ConsumerStatefulWidget {
  final String teamId;

  const WebAddMachineModal({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<WebAddMachineModal> createState() => _WebAddMachineModalState();
}

class _WebAddMachineModalState extends ConsumerState<WebAddMachineModal> {
  final _formKey = GlobalKey<FormState>();
  final _machineNameController = TextEditingController();
  final _machineIdController = TextEditingController();
  final _usersController = TextEditingController(text: 'All Team Members');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _machineNameController.dispose();
    _machineIdController.dispose();
    _usersController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(
    String labelText, {
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: readOnly ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
      ),
      floatingLabelStyle: TextStyle(
        color: readOnly ? const Color(0xFF9CA3AF) : const Color(0xFF10B981),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: readOnly ? const Color(0xFFE5E7EB) : const Color(0xFF10B981),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: readOnly ? const Color(0xFFE5E7EB) : const Color(0xFFD1D5DB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: readOnly,
      fillColor: readOnly ? const Color(0xFFF9FAFB) : null,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(adminMachineProvider.notifier).addMachine(
            teamId: widget.teamId,
            machineId: _machineIdController.text.trim(),
            machineName: _machineNameController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => const _SuccessDialog(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Machine',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              'Add a new machine to your collection',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Machine Name
                TextFormField(
                  controller: _machineNameController,
                  style: const TextStyle(color: Color(0xFF111827)),
                  cursorColor: const Color(0xFF10B981),
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

                // Machine ID
                TextFormField(
                  controller: _machineIdController,
                  style: const TextStyle(color: Color(0xFF111827)),
                  cursorColor: const Color(0xFF10B981),
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

                // Assigned Users
                TextFormField(
                  controller: _usersController,
                  decoration: _buildInputDecoration('Assigned Users', readOnly: true),
                  enabled: false,
                  readOnly: true,
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Add Machine',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF10B981),
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your changes has been made successfully.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}