import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/machine_model.dart';
import '../view_model/admin_machine_notifier.dart';

class EditMachineModal extends ConsumerStatefulWidget {
  final MachineModel machine;
  final String teamId;

  const EditMachineModal({
    super.key,
    required this.machine,
    required this.teamId,
  });

  @override
  ConsumerState<EditMachineModal> createState() => _EditMachineModalState();
}

class _EditMachineModalState extends ConsumerState<EditMachineModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _machineNameController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _machineNameController = TextEditingController(
      text: widget.machine.machineName,
    );
  }

  @override
  void dispose() {
    _machineNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(adminMachineProvider.notifier); // ✅ CHANGED
      
      await notifier.updateMachine(
        teamId: widget.teamId,
        machineId: widget.machine.machineId,
        machineName: _machineNameController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Machine updated successfully'),
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
    // ...rest of the build method stays the same...
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
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Edit Machine',
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
              initialValue: widget.machine.machineId,
              decoration: InputDecoration(
                labelText: 'Machine ID',
                prefixIcon: const Icon(Icons.tag),
                suffixIcon: const Icon(Icons.lock, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              enabled: false,
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
                backgroundColor: Colors.orange,
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
                      'Update Machine',
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