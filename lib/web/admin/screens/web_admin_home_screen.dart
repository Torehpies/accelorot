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

  @override
  void initState() {
    super.initState();
    _loadStats();
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

      final membersSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .get();

      final activeCount = membersSnapshot.docs
          .where((doc) => doc.data()['isArchived'] != true)
          .length;

      final archivedCount = membersSnapshot.docs
          .where((doc) => doc.data()['isArchived'] == true)
          .length;

      final machinesSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('machines')
          .get();

      final activeMachines = machinesSnapshot.docs
          .where((doc) => doc.data()['isArchived'] != true)
          .length;

      final archivedMachines = machinesSnapshot.docs
          .where((doc) => doc.data()['isArchived'] == true)
          .length;

      if (mounted) {
        setState(() {
          _activeOperators = activeCount;
          _archivedOperators = archivedCount;
          _activeMachines = activeMachines;
          _archivedMachines = archivedMachines;
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
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
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: screenHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === STAT CARDS ===
                    SizedBox(
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

                    // === USER MANAGEMENT CONTAINER ===
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(100, 0, 0, 0),
                              blurRadius: 8,
                              offset: Offset(2, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Operator Management',
                                onTapManage: widget.onManageOperators),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: usersList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: _buildUserCard(usersList[index], borderColor),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // === MACHINE MANAGEMENT CONTAINER ===
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(100, 0, 0, 0),
                              blurRadius: 8,
                              offset: Offset(2, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Machine Management',
                                onTapManage: widget.onManageMachines),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: machinesList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child:
                                        _buildMachineCard(machinesList[index], borderColor),
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
            ),
    );
  }

  final List<String> usersList = [
    'Elijah Reyes',
    'Zoe Jop',
    'Aurélie Ford',
    'Troy Kim',
  ];

  final List<String> machinesList = [
    'Machine A',
    'Machine B',
    'Machine C',
    'Machine D',
  ];

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
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(100, 0, 0, 0),
            blurRadius: 8,
            offset: Offset(2, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
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
                fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        TextButton(
          onPressed: onTapManage,
          child: const Row(
            children: [
              Text('Manage',
                  style: TextStyle(
                      color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF2E7D32)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(String name, Color borderColor) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(80, 0, 0, 0),
            blurRadius: 6,
            offset: Offset(2, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildMachineCard(String name, Color borderColor) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(80, 0, 0, 0),
            blurRadius: 6,
            offset: Offset(2, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
