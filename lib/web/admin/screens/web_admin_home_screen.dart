// lib/screens/web_admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebAdminHomeScreen extends StatelessWidget {
  final VoidCallback onManageOperators;
  final VoidCallback onManageMachines;

  const WebAdminHomeScreen({
    super.key,
    required this.onManageOperators,
    required this.onManageMachines,
  });

  @override
  Widget build(BuildContext context) {
    return _WebAdminHomeScreenContent(
      onManageOperators: onManageOperators,
      onManageMachines: onManageMachines,
    );
  }
}

class _WebAdminHomeScreenContent extends StatefulWidget {
  final VoidCallback onManageOperators;
  final VoidCallback onManageMachines;

  const _WebAdminHomeScreenContent({
    required this.onManageOperators,
    required this.onManageMachines,
  });

  @override
  State<_WebAdminHomeScreenContent> createState() => _WebAdminHomeScreenState();
}

class _WebAdminHomeScreenState extends State<_WebAdminHomeScreenContent> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = true;
  int _activeOperators = 0;
  int _archivedOperators = 0;
  int _activeMachines = 0;
  int _archivedMachines = 0;

  List<Map<String, dynamic>> _operators = [];
  List<Map<String, dynamic>> _machines = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // Helper: Extract surname (last word)
  String _getSurname(String fullName) {
    if (fullName == '—' || fullName.trim().isEmpty) return '—';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.last;
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final teamId = user.uid;

      // === Load Operators ===
      final membersSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .get();

      final activeOperators = membersSnapshot.docs
          .where((doc) => doc.data()['isArchived'] != true)
          .length;
      final archivedOperators = membersSnapshot.docs.length - activeOperators;

      final operators = membersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '—',
          'email': data['email'] ?? '—',
          'isArchived': data['isArchived'] == true,
        };
      }).toList();

      // === Load Machines ===
      final machinesSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('machines')
          .get();

      final activeMachines = machinesSnapshot.docs
          .where((doc) => doc.data()['isArchived'] != true)
          .length;
      final archivedMachines = machinesSnapshot.docs.length - activeMachines;

      final machines = machinesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '—',
          'machineId': data['machineId'] ?? '—',
          'isArchived': data['isArchived'] == true,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _activeOperators = activeOperators;
          _archivedOperators = archivedOperators;
          _activeMachines = activeMachines;
          _archivedMachines = archivedMachines;
          _operators = operators;
          _machines = machines;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const borderColor = Color.fromARGB(255, 170, 169, 169);


    return Scaffold(    
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        title: const Text('Dashboard', style: TextStyle (color: Colors.teal, fontWeight: FontWeight.bold),),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                height: screenHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === STAT CARDS ===
                    SizedBox(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: _buildModernStatCard(
                                label: 'Active Operators',
                                value: _activeOperators.toString(),
                                icon: Icons.people_outline,
                                borderColor: borderColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: _buildModernStatCard(
                                label: 'Archived Operators',
                                value: _archivedOperators.toString(),
                                icon: Icons.archive_outlined,
                                borderColor: borderColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: _buildModernStatCard(
                                label: 'Active Machines',
                                value: _activeMachines.toString(),
                                icon: Icons.devices_other_outlined,
                                borderColor: borderColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: _buildModernStatCard(
                                label: 'Archived Machines',
                                value: _archivedMachines.toString(),
                                icon: Icons.archive_rounded,
                                borderColor: borderColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // === OPERATOR & MACHINE MANAGEMENT SIDE BY SIDE ===
                    Expanded(
                      child: Row(
                        children: [
                          // === OPERATOR MANAGEMENT ===
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader('Operator Management', onTapManage: widget.onManageOperators),
                                  const SizedBox(height: 4),
                                  // === TABLE HEADER ===
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.grey[100],
    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
  ),
  child: Row(
    children: [
      Expanded(flex: 1, child: Text('ID', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      Expanded(flex: 3, child: Text('Surname', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      Expanded(flex: 4, child: Text('Email', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      Expanded(
        flex: 3,
        child: Align(
          alignment: Alignment.topCenter,
          child: Text('Status', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      Expanded(flex: 1, child: Text('Action', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
    ],
  ),
),
                                  // === TABLE BODY ===
                                  Expanded(
                                    child: ListView.separated(
                                      separatorBuilder: (_,_) => const Divider(height: 0.5, thickness: 0.5, color: Colors.grey),
                                      itemCount: _operators.length,
                                      itemBuilder: (context, index) {
                                        final operator = _operators[index];
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Row(
                                            children: [
                                              Expanded(flex: 1, child: Text('${index + 1}', style: const TextStyle(fontSize: 12))),
                                              Expanded(flex: 3, child: Text(_getSurname(operator['name']), style: const TextStyle(fontSize: 12))),
                                              Expanded(flex: 4, child: Text(operator['email'], style: const TextStyle(fontSize: 12))),
                                              Expanded(flex: 2, child: Align( // ✅ TOP-ALIGNED CIRCLE
                                                alignment: Alignment.topCenter,
                                                child: Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: operator['isArchived'] ? Colors.red : Colors.green,
                                                  ),
                                                ),
                                              )),
                                              Expanded(flex: 1, child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit, size: 12),
                                                    onPressed: () { /*  */ },
                                                    color: Colors.blue,
                                                    padding: EdgeInsets.zero,
                                                    visualDensity: VisualDensity.compact,
                                                    constraints: BoxConstraints(),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, size: 12),
                                                    onPressed: () { /* */ },
                                                    color: Colors.red,
                                                    padding: EdgeInsets.zero,
                                                    visualDensity: VisualDensity.compact,
                                                    constraints: BoxConstraints(),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // === MACHINE MANAGEMENT ===
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader('Machine Management', onTapManage: widget.onManageMachines),
                                  const SizedBox(height: 4),
                                  // === TABLE HEADER ===
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 1, child: Text('ID', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                        Expanded(flex: 3, child: Text('Machine', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                        Expanded(flex: 3, child: Text('ID', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                        Expanded(flex: 1, child: Text('Action', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 0.5, thickness: 0.5, color: Colors.grey),
                                  // === TABLE BODY ===
                                  Expanded(
                                    child: ListView.separated(
                                      separatorBuilder: (_, _) => const Divider(height: 0.5, thickness: 0.5, color: Colors.grey),
                                      itemCount: _machines.length,
                                      itemBuilder: (context, index) {
                                        final machine = _machines[index];
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Row(
                                            children: [
                                              Expanded(flex: 1, child: Text('${index + 1}', style: const TextStyle(fontSize: 12))),
                                              Expanded(flex: 3, child: Text(_getSurname(machine['name']), style: const TextStyle(fontSize: 12))),
                                              Expanded(flex: 3, child: Text(machine['machineId'], style: const TextStyle(fontSize: 12))),
                                              Expanded(flex: 1, child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit, size: 12),
                                                    onPressed: () { /*  */ },
                                                    color: Colors.blue,
                                                    padding: EdgeInsets.zero,
                                                    visualDensity: VisualDensity.compact,
                                                    constraints: BoxConstraints(),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, size: 12),
                                                    onPressed: () { /*  */ },
                                                    color: Colors.red,
                                                    padding: EdgeInsets.zero,
                                                    visualDensity: VisualDensity.compact,
                                                    constraints: BoxConstraints(),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildModernStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: Color(0xFF2E7D32)),
          const SizedBox(width: 6),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title,
      {required VoidCallback onTapManage}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32))),
        TextButton(
          onPressed: onTapManage,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: const Row(
            children: [
              Text('Manage',
                  style: TextStyle(
                      color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13)),
              Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF2E7D32)),
            ],
          ),
        ),
      ],
    );
  }
}