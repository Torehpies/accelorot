// lib/frontend/operator/machine_management/admin_machine/widgets/edit_machine_modal.dart

import 'package:flutter/material.dart';
import '../controllers/admin_machine_controller.dart';
import '../models/admin_machine_model.dart';

class EditMachineModal extends StatefulWidget {
  final AdminMachineController controller;
  final MachineModel machine;

  const EditMachineModal({
    super.key,
    required this.controller,
    required this.machine,
  });

  @override
  State<EditMachineModal> createState() => _EditMachineModalState();
}

class _EditMachineModalState extends State<EditMachineModal> {
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

  InputDecoration _buildInputDecoration(String labelText, {bool readOnly = false}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: readOnly ? Colors.grey[400] : Colors.grey),
      floatingLabelStyle: TextStyle(color: readOnly ? Colors.grey[400] : Colors.teal),
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
      filled: readOnly,
      fillColor: readOnly ? Colors.grey[100] : null,
    );
  }

  Future<void> _handleSubmit() async {
    // Check authentication first
    if (!widget.controller.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ You must be logged in to edit machines'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Machine Name is required')),
      );
      return;
    }

    // Check if anything changed
    if (name == widget.machine.machineName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes detected')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.controller.updateMachine(
        machineId: widget.machine.machineId,
        machineName: name,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close modal
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Machine "$name" updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Delay handled in controller's updateMachine method
    } catch (e) {
      if (!mounted) return;
      
      // Show user-friendly error message
      final errorMessage = e.toString().contains('logged in')
          ? 'You must be logged in to edit machines'
          : 'Failed to update machine: $e';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      
      // Stay in modal on error
      setState(() => _isSubmitting = false);
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
                'Edit Machine',
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
                ? 'Update machine details'
                : 'You can preview the form, but must be logged in to save changes',
            style: TextStyle(
              color: isAuthenticated ? Colors.grey : Colors.orange.shade700,
              fontWeight: isAuthenticated ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          
          // Machine Name (Editable)
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.teal),
            cursorColor: Colors.teal,
            decoration: _buildInputDecoration('Machine Name *'),
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          
          // Machine ID (Read-only, grayed out)
          TextField(
            controller: _idController,
            style: TextStyle(color: Colors.grey[600]),
            decoration: _buildInputDecoration('Machine ID (Cannot be changed)', readOnly: true),
            enabled: false,
            readOnly: true,
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
          
          // Buttons
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
                    backgroundColor: isAuthenticated ? Colors.teal : Colors.orange,
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
                            Text(isAuthenticated ? 'Update Machine' : 'Login Required'),
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