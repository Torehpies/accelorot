// lib/screens/web_admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../ui/core/ui/admin_app_bar.dart'; // ✅ ADD THIS IMPORT
import '../../../frontend/screens/admin/operator_management/operator_management_screen.dart';
import '../../../ui/web_machine/widgets/admin/web_admin_machine_view.dart';

class WebAdminHomeScreen extends StatelessWidget {
  const WebAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _WebAdminHomeScreenContent();
  }
}

class _WebAdminHomeScreenContent extends StatefulWidget {
  const _WebAdminHomeScreenContent();
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

  // 🎨 Border color for containers (stat cards, tables) – light grey (#E6E6E6)
  final Color borderColor = const Color.fromARGB(255, 230, 229, 229); // #E6E6E6

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
          _operators = operators.take(7).toList();
          _machines = machines.take(7).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // ✅ UPDATED APPBAR
      appBar: AdminAppBar(
        title: 'Dashboard',
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === STAT CARDS ===
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.people_outline,
                          label: 'Active Operators',
                          count: _activeOperators,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.archive_outlined,
                          label: 'Archived Operators',
                          count: _archivedOperators,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.devices_other_outlined,
                          label: 'Active Machines',
                          count: _activeMachines,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.archive_rounded,
                          label: 'Archived Machines',
                          count: _archivedMachines,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // === EXPANDED TABLES: Fill remaining space ===
                  Expanded(
                    child: Row(
                      children: [
                        // === OPERATOR MANAGEMENT ===
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  'Operator Management',
                                  onTapManage: () {
                                    final teamId =
                                        FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.uid ??
                                        '';
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OperatorManagementScreen(
                                              teamId: teamId,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                // === TABLE HEADER ===
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Name',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color.fromARGB(
                                              255,
                                              73,
                                              73,
                                              73,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Email',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color.fromARGB(
                                              255,
                                              73,
                                              73,
                                              73,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Status',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color.fromARGB(
                                              255,
                                              73,
                                              73,
                                              73,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Actions',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color.fromARGB(
                                              255,
                                              73,
                                              73,
                                              73,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 16, color: Colors.grey),
                                // === TABLE BODY ===
                                Expanded(
                                  child: ListView.separated(
                                    separatorBuilder: (_, _) => const Divider(
                                      height: 16,
                                      color: Colors.grey,
                                    ),
                                    itemCount: _operators.length,
                                    itemBuilder: (context, index) {
                                      final operator = _operators[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                operator['name'],
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                operator['email'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                    255,
                                                    73,
                                                    73,
                                                    73,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Center(
                                                child: Container(
                                                  width: 7,
                                                  height: 7,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        operator['isArchived']
                                                        ? Colors.red
                                                        : Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      size: 14,
                                                    ),
                                                    onPressed: () {},
                                                    color: Colors.blue,
                                                    padding: EdgeInsets.zero,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    constraints:
                                                        BoxConstraints(),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      size: 14,
                                                    ),
                                                    onPressed: () {},
                                                    color: Colors.red,
                                                    padding: EdgeInsets.zero,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    constraints:
                                                        BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                            ),
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

                        const SizedBox(width: 12),

                        // === MACHINE MANAGEMENT ===
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                  'Machine Management',
                                  onTapManage: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WebAdminMachineView(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Machine',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color.fromARGB(
                                              255,
                                              73,
                                              73,
                                              73,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'ID',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color.fromARGB(
                                              255,
                                              73,
                                              73,
                                              73,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          'Actions',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color.fromARGB(
                                              255,
                                              73,
                                              73,
                                              73,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 16, color: Colors.grey),
                                Expanded(
                                  child: ListView.separated(
                                    separatorBuilder: (_, _) => const Divider(
                                      height: 16,
                                      color: Colors.grey,
                                    ),
                                    itemCount: _machines.length,
                                    itemBuilder: (context, index) {
                                      final machine = _machines[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                machine['name'],
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                machine['machineId'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                    255,
                                                    73,
                                                    73,
                                                    73,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      size: 14,
                                                    ),
                                                    onPressed: () {},
                                                    color: Colors.blue,
                                                    padding: EdgeInsets.zero,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    constraints:
                                                        BoxConstraints(),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      size: 14,
                                                    ),
                                                    onPressed: () {},
                                                    color: Colors.red,
                                                    padding: EdgeInsets.zero,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    constraints:
                                                        BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                            ),
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
    );
  }

  // ✅ Stat card with BORDER (no shadow)
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required int? count,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        // 🔲 Border instead of shadow – uses labeled borderColor
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.teal),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 168, 168, 168),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count?.toString() ?? '—',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    required VoidCallback onTapManage,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        TextButton(
          onPressed: onTapManage,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: const Row(
            children: [
              Text(
                'Manage',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 13, color: Colors.teal),
            ],
          ),
        ),
      ],
    );
  }
}
