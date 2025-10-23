// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'add_operator_screen.dart';

class OperatorManagementScreen extends StatefulWidget {
  const OperatorManagementScreen({super.key});

  @override
  State<OperatorManagementScreen> createState() =>
      _OperatorManagementScreenState();
}

class _OperatorManagementScreenState extends State<OperatorManagementScreen> {
  // Fixed mock data: every operator now has a valid role
  final List<Map<String, dynamic>> _operators = List.generate(6, (index) {
    return {
      'name': 'Operator ${index + 1}',
      'email': 'operator${index + 1}@company.com',
      'role': index % 2 == 0 ? 'Admin' : 'Operator', // ✅ No empty roles
      'isArchived': index >= 4,
      'dateAdded': 'Aug-${20 + index}-2025',
    };
  }).toList();

  bool _showArchived = false;

  // Navigate to AddOperatorScreen in "Add" mode
  void _navigateToAddOperator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddOperatorScreen(), // No args = Add mode
      ),
    ).then((result) {
      // Optional: Refresh or show feedback if needed
      // For now, AddOperatorScreen handles its own success message
    });
  }

  // Restore an archived operator
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

  // Helper getters
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
                    onPressed: _navigateToAddOperator, // ✅ Now uses full screen
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
                                            builder: (context) => AddOperatorScreen(
                                              operatorName: operator['name'],
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