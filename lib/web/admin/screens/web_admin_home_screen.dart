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
  int _pendingInvitations = 0;
  int _totalMachines = 0;

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
          .where((doc) =>
              doc.data()['isArchived'] != true && doc.data()['hasLeft'] != true)
          .length;

      final pendingSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .get();

      final machinesSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('machines')
          .get();

      if (mounted) {
        setState(() {
          _activeOperators = activeCount;
          _pendingInvitations = pendingSnapshot.docs.length;
          _totalMachines = machinesSnapshot.docs.length;
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
    const borderColor = Color.fromARGB(255, 170, 169, 169); // unified border color

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
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
                height: screenHeight, // Fit screen height
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
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _buildModernStatCard(
                                label: 'Add Operator',
                                value: '',
                                icon: Icons.person_add_outlined,
                                onTap: widget.onManageOperators,
                                borderColor: borderColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: _buildModernStatCard(
                                label: 'Accept Operator',
                                value: _pendingInvitations.toString(),
                                icon: Icons.check_circle_outline,
                                borderColor: borderColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
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
                              padding: const EdgeInsets.only(left: 8.0),
                              child: _buildModernStatCard(
                                label: 'Total Machines',
                                value: _totalMachines.toString(),
                                icon: Icons.devices_outlined,
                                onTap: widget.onManageMachines,
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
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 155, 155, 155),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('User Management',
                                onTapManage: widget.onManageOperators),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: usersList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(right: 16.0),
                                    child:
                                        _buildUserCard(usersList[index], borderColor),
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
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 155, 155, 155),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
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
                                    padding:
                                        const EdgeInsets.only(right: 16.0),
                                    child: _buildMachineCard(
                                        machinesList[index], borderColor),
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
    'Troy Kim',
    'Troy Kim',
    'Troy Kim',
    'Troy Kim',

  ];

  final List<String> machinesList = [
    'Machine A',
    'Machine B',
    'Machine C',
    'Machine D',
    'Machine D',
    'Machine D',
    'Machine D',
    'Machine D',
    'Machine D',
    'Machine D',
  ];

  Widget _buildModernStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1), // unified border
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: const Color(0xFF2E7D32)),
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
                if (value.isNotEmpty)
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
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32))),
        TextButton(
          onPressed: onTapManage,
          child: const Row(
            children: [
              Text('Manage',
                  style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Color(0xFF2E7D32)),
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
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
