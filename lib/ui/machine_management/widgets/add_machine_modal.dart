import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/admin_machine_notifier.dart';

class AddMachineModal extends ConsumerStatefulWidget {
  final String teamId;

  const AddMachineModal({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<AddMachineModal> createState() => _AddMachineModalState();
}

class _AddMachineModalState extends ConsumerState<AddMachineModal> {
  final _formKey = GlobalKey<FormState>();
  final _machineIdController = TextEditingController();
  final _machineNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _machineIdController.dispose();
    _machineNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(adminMachineProvider.notifier); // ✅ CHANGED
      
      await notifier.addMachine(
        teamId: widget.teamId,
        machineId: _machineIdController.text.trim(),
        machineName: _machineNameController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Machine added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.precision_manufacturing,
                    color: Colors.teal.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add New Machine',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _machineIdController,
              decoration: InputDecoration(
                labelText: 'Machine ID',
                hintText: 'e.g., MACH001',
                prefixIcon: const Icon(Icons.tag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a machine ID';
                }
                if (value.trim().length < 3) {
                  return 'Machine ID must be at least 3 characters';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _machineNameController,
              decoration: InputDecoration(
                labelText: 'Machine Name',
                hintText: 'e.g., Composter Unit A',
                prefixIcon: const Icon(Icons.label),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a machine name';
                }
                if (value.trim().length < 3) {
                  return 'Machine name must be at least 3 characters';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
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
                  : const Text(
                      'Add Machine',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}