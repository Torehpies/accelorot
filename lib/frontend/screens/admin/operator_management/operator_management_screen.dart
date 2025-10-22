// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'operator_detail_screen.dart'; // ✅ Now used for navigation

class OperatorManagementScreen extends StatefulWidget {
  const OperatorManagementScreen({super.key});

  @override
  State<OperatorManagementScreen> createState() =>
      _OperatorManagementScreenState();
}

class _OperatorManagementScreenState extends State<OperatorManagementScreen> {
  // Sample operators — no 'isExpanded' needed anymore
  final List<Map<String, dynamic>> _operators = List.generate(6, (index) {
    return {
      'name': 'Operator ${index + 1}',
      'email': 'operator${index + 1}@company.com',
      'role': index % 2 == 0 ? '' : 'Operator',
      'isArchived': index >= 4,
      'dateAdded': 'Aug-${20 + index}-2025',
    };
  }).toList();

  bool _showArchived = false;
  int _nextOperatorNumber = 7;

  void _restoreOperator(int globalIndex) {
    setState(() {
      _operators[globalIndex]['isArchived'] = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_operators[globalIndex]['name']} restored'),
      ),
    );
  }

  void _addOperator({
    required String name,
    required String email,
    required String role,
    String dateAdded = 'Aug-25-2025',
  }) {
    final actualName = name.trim().isNotEmpty
        ? name.trim()
        : 'Operator $_nextOperatorNumber';

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    setState(() {
      _operators.add({
        'name': actualName,
        'email': email.trim(),
        'role': role,
        'isArchived': false,
        'dateAdded': dateAdded,
      });
      _nextOperatorNumber++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Added: $actualName')),
    );
  }

  void _showAddOperatorModal() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final dateController = TextEditingController();
    String selectedRole = 'Operator';

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
                  'Add Operator',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: Navigator.of(context).pop,
                ),
              ],
            ),
            const Text(
              'Fill in the details to register a new operator',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.teal),
              cursorColor: Colors.teal,
              decoration: buildInputDecoration('Full Name *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.teal),
              cursorColor: Colors.teal,
              keyboardType: TextInputType.emailAddress,
              decoration: buildInputDecoration('Email *'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: buildInputDecoration('Role'),
              items: ['Operator', 'Senior Operator', 'Supervisor']
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
              decoration: buildInputDecoration('Date Added (e.g. Aug-25-2025)'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: Navigator.of(context).pop,
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
                    onPressed: () {
                      final name = nameController.text.trim();
                      final email = emailController.text.trim();
                      if (name.isEmpty || email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Name and Email are required')),
                        );
                        return;
                      }
                      _addOperator(
                        name: name,
                        email: email,
                        role: selectedRole,
                        dateAdded: dateController.text.isEmpty
                            ? 'Aug-25-2025'
                            : dateController.text,
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
                    child: const Text('Add Operator'),
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

  List<Map<String, dynamic>> get _activeOperators =>
      _operators.where((o) => o['isArchived'] == false).toList();

  List<Map<String, dynamic>> get _archivedOperators =>
      _operators.where((o) => o['isArchived'] == true).toList();

  @override
  Widget build(BuildContext context) {
    final currentList = _showArchived ? _archivedOperators : _activeOperators;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Operator Management',
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
            // Action Cards
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
                    icon: Icons.person_add_alt_1,
                    label: 'Add Operator',
                    onPressed: _showAddOperatorModal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section Title or Back Button
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
                    label: const Text('Back to Active Operators'),
                    style: TextButton.styleFrom(foregroundColor: Colors.teal),
                  )
                else
                  Text(
                    'Lists of Operators',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Operator List
            Expanded(
              child: currentList.isEmpty
                  ? Center(
                      child: Text(
                        _showArchived
                            ? 'No archived operators'
                            : 'No operators available',
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
                          itemCount: currentList.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final operator = currentList[index];
                            final globalIndex = _operators.indexWhere((o) =>
                                o['name'] == operator['name'] &&
                                o['email'] == operator['email']);

                            return Card(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 0.5,
                                ),
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
                                    Icons.person,
                                    color: Colors.teal.shade700,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  operator['name'],
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  operator['email'],
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
                                        onPressed: () => _restoreOperator(globalIndex),
                                        child: const Text(
                                          'Restore',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.chevron_right,
                                        color: Colors.teal,
                                      ),
                                onTap: _showArchived
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OperatorDetailScreen(
                                              operatorName: operator['name'],
                                              role: operator['role'],
                                              email: operator['email'],
                                              dateAdded: operator['dateAdded'],
                                            ),
                                          ),
                                        );
                                      },
                              ),
                            );
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