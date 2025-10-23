// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class MachineManagementScreen extends StatefulWidget {
  const MachineManagementScreen({super.key});

  @override
  State<MachineManagementScreen> createState() => _MachineManagementScreenState();
}

class _MachineManagementScreenState extends State<MachineManagementScreen> {
  // Generate machines named "Machine 1", "Machine 2", etc.
  final List<Map<String, dynamic>> _machines = List.generate(8, (index) {
    return {
      'name': 'Machine ${index + 1}',
      'code': 'MACH${(index + 1).toString().padLeft(4, '0')}',
      'isArchived': index >= 5,
      'isExpanded': false, // 👈 Track expansion state
    };
  }).toList();

  bool _showArchived = false;

  void _toggleExpand(int globalIndex) {
    setState(() {
      _machines[globalIndex]['isExpanded'] = !_machines[globalIndex]['isExpanded'];
    });
  }

  void _restoreMachine(int globalIndex) {
    setState(() {
      _machines[globalIndex]['isArchived'] = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_machines[globalIndex]['name']} restored')),
    );
  }

  int _nextMachineNumber = 9; // Start after Machine 1–8

  void _addMachine({
    required String name,
    required String code,
    String role = 'Admin',
    String date = 'Aug-25-2025',
  }) {
    final actualName = name.trim().isNotEmpty
        ? name.trim()
        : 'Machine $_nextMachineNumber';

    setState(() {
      _machines.add({
        'name': actualName,
        'code': code.trim(),
        'isArchived': false,
        'isExpanded': false,
      });
      _nextMachineNumber++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Added: $actualName')),
    );
  }

 void _showAddMachineModal() {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final dateController = TextEditingController();
  String selectedRole = 'Admin';

  // 🔹 Consistent input decoration with teal theming
  InputDecoration buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: Colors.teal),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
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
                onPressed: Navigator.of(context).pop,
              ),
            ],
          ),
          const Text('Fill in the details to register a new machine',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.teal),
            cursorColor: Colors.teal,
            decoration: buildInputDecoration('Machine Name (optional)'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codeController,
                  style: const TextStyle(color: Colors.teal),
                  cursorColor: Colors.teal,
                  decoration: buildInputDecoration('Product Code *'),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.teal,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: selectedRole,
            decoration: buildInputDecoration('User Role'),
            items: ['Admin', 'User']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => selectedRole = val!),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
            style: const TextStyle(color: Colors.teal),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: dateController,
            style: const TextStyle(color: Colors.teal),
            cursorColor: Colors.teal,
            decoration: buildInputDecoration('Date (e.g. Aug-25-2025)'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: Navigator.of(context).pop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.teal, // ✅ Teal text
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
                  onPressed: () {
                    final code = codeController.text.trim();
                    if (code.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product Code is required')),
                      );
                      return;
                    }
                    _addMachine(
                      name: nameController.text,
                      code: code,
                      role: selectedRole,
                      date: dateController.text.isEmpty ? 'Aug-25-2025' : dateController.text,
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add Machine'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

  List<Map<String, dynamic>> get _activeMachines =>
      _machines.where((m) => m['isArchived'] == false).toList();

  List<Map<String, dynamic>> get _archivedMachines =>
      _machines.where((m) => m['isArchived'] == true).toList();

  @override
  Widget build(BuildContext context) {
    final currentList = _showArchived ? _archivedMachines : _activeMachines;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Machine Management',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Action Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.archive,
                    label: 'Archive',
                    onPressed: () {
                      setState(() {
                        _showArchived = true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.add_circle_outline,
                    label: 'Add Machine',
                    onPressed: _showAddMachineModal, // 👈 Opens modal
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Back to Active / Section Title
            Row(
              children: [
                if (_showArchived)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showArchived = false;
                      });
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back to Active Machines'),
                    style: TextButton.styleFrom(foregroundColor: Colors.teal),
                  )
                else
                  Text(
                    'Lists of Machines',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 🔹 Machine List Container
            Expanded(
              child: currentList.isEmpty
                  ? Center(
                      child: Text(
                        _showArchived ? 'No archived machines' : 'No machines available',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: currentList.length * 2, // Double count for expanded details
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            // Even indices = machine item
                            if (index % 2 == 0) {
                              final machineIndex = index ~/ 2;
                              final machine = currentList[machineIndex];
                              final globalIndex = _machines.indexWhere((m) =>
                                  m['name'] == machine['name'] &&
                                  m['code'] == machine['code']);

                              return Card(
                                elevation: 0,
                                margin: EdgeInsets.zero,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: Colors.grey[200]!, width: 0.5),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.devices,
                                      color: Colors.teal.shade700,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    machine['name'],
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'Product Code/ID: ${machine['code']}',
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                  trailing: _showArchived
                                      ? ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal.shade100,
                                            foregroundColor: Colors.teal.shade800,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () => _restoreMachine(globalIndex),
                                          child: const Text('Restore', style: TextStyle(fontSize: 12)),
                                        )
                                      : Icon(
                                          Icons.chevron_right,
                                          color: Colors.teal.shade600,
                                          size: 24,
                                        ),
                                  onTap: _showArchived
                                      ? null
                                      : () => _toggleExpand(globalIndex),
                                ),
                              );
                            } else {
                              // Odd indices = detail card (if expanded)
                              final machineIndex = (index - 1) ~/ 2;
                              final machine = currentList[machineIndex];
                              final globalIndex = _machines.indexWhere((m) =>
                                  m['name'] == machine['name'] &&
                                  m['code'] == machine['code']);

                              if (!_machines[globalIndex]['isExpanded']) {
                                return SizedBox(height: 0); // Hide if not expanded
                              }

                              return Container(
                                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade100,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.devices,
                                            color: Colors.teal.shade700,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            machine['name'],
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDetailRow('Product Code/ID:', machine['code']),
                                    const SizedBox(height: 8),
                                    _buildDetailRow('User Role:', 'Admin'),
                                    const SizedBox(height: 8),
                                    _buildDetailRow('Date:', 'Aug-25-2025'),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal), // ✅ Teal value
          ),
        ),
      ],
    );
  }

  // 🔹 Reusable Action Card Widget
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}