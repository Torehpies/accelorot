// lib/frontend/operator/machine_management/admin_machine/widgets/add_machine_modal.dart

import 'package:flutter/material.dart';
import '../view_model/machine_management_view_model.dart';

class AddMachineModal extends StatefulWidget {
  final AdminMachineController controller;

  const AddMachineModal({super.key, required this.controller});

  @override
  State<AddMachineModal> createState() => _AddMachineModalState();
}

class _AddMachineModalState extends State<AddMachineModal> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  bool _isSubmitting = false;
  bool _idAlreadyExists = false;
  bool _isCheckingId = false;

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
      labelStyle: TextStyle(color: readOnly ? Colors.grey[400] : Colors.grey),
      floatingLabelStyle: TextStyle(
        color: readOnly ? Colors.grey[400] : Colors.teal,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: readOnly ? Colors.grey[300]! : Colors.teal,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: readOnly ? Colors.grey[300]! : Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: readOnly,
      fillColor: readOnly ? Colors.grey[100] : null,
    );
  }

  Future<void> _validateMachineId() async {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      setState(() => _idAlreadyExists = false);
      return;
    }

    setState(() => _isCheckingId = true);

    try {
      final exists = await widget.controller.machineExists(id);
      if (mounted) {
        setState(() {
          _idAlreadyExists = exists;
          _isCheckingId = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _idAlreadyExists = false;
          _isCheckingId = false;
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!widget.controller.isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to add machines'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final id = _idController.text.trim();

    if (id.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Machine ID is required')));
      return;
    }

    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Machine Name is required')));
      return;
    }

    await _validateMachineId();
    if (_idAlreadyExists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Machine ID already exists. Please use a different ID.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.controller.addMachine(machineName: name, machineId: id);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Machine "$name" added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().contains('logged in')
          ? 'You must be logged in to add machines'
          : 'Failed to add machine: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = widget.controller.isAuthenticated;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Machine',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Text(
            isAuthenticated
                ? 'Fill in the details to register a new machine'
                : 'You can preview the form, but must be logged in to submit',
            style: TextStyle(
              color: isAuthenticated ? Colors.grey : Colors.orange.shade700,
              fontWeight: isAuthenticated ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.teal),
            cursorColor: Colors.teal,
            decoration: _buildInputDecoration('Machine Name *'),
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _idController,
            style: const TextStyle(color: Colors.teal),
            cursorColor: Colors.teal,
            onEditingComplete: _validateMachineId,
            decoration: _buildInputDecoration('Machine ID *').copyWith(
              errorText: _idAlreadyExists ? 'Machine ID already exists' : null,
              suffixIcon: _isCheckingId
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _idAlreadyExists
                  ? const Icon(Icons.error, color: Colors.red)
                  : _idController.text.isNotEmpty && !_isCheckingId
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),

          // Assigned Users - Read-only field showing "All Team Members"
          TextField(
            controller: TextEditingController(text: 'All Team Members'),
            decoration: _buildInputDecoration('Assigned Users', readOnly: true),
            enabled: false,
            readOnly: true,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                    backgroundColor: isAuthenticated
                        ? Colors.teal
                        : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isAuthenticated)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(Icons.lock_outline, size: 16),
                              ),
                            Text(
                              isAuthenticated
                                  ? 'Add Machine'
                                  : 'Login Required',
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
