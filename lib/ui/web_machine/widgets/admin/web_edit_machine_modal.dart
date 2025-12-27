import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/machine_model.dart';
import '../../../machine_management/view_model/admin_machine_notifier.dart';

class WebEditMachineModal extends ConsumerStatefulWidget {
  final MachineModel machine;
  final String teamId;

  const WebEditMachineModal({
    super.key,
    required this.machine,
    required this.teamId,
  });

  @override
  ConsumerState<WebEditMachineModal> createState() => _WebEditMachineModalState();
}

class _WebEditMachineModalState extends ConsumerState<WebEditMachineModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _idController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.machine.machineName);
    _idController = TextEditingController(text: widget.machine.machineId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
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
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Machine Name is required'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (name == widget.machine.machineName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No changes detected'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(adminMachineProvider.notifier).updateMachine(
            teamId: widget.teamId,
            machineId: widget.machine.machineId,
            machineName: name,
          );

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Machine "$name" updated successfully'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update machine: $e'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
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
                        Icons.edit,
                        color: Color(0xFF92400E),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Machine',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          'Update machine details',
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

            TextField(
              controller: _nameController,
              style: const TextStyle(color: Color(0xFF111827)),
              cursorColor: const Color(0xFF10B981),
              decoration: _buildInputDecoration('Machine Name *'),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _idController,
              style: const TextStyle(color: Color(0xFF6B7280)),
              decoration: _buildInputDecoration(
                'Machine ID (Cannot be changed)',
                readOnly: true,
              ),
              enabled: false,
              readOnly: true,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: TextEditingController(text: 'All Team Members'),
              decoration: _buildInputDecoration('Assigned Users', readOnly: true),
              enabled: false,
              readOnly: true,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),

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
                            'Update Machine',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}