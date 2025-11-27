// lib/frontend/screens/admin/operator_management/operator_management_screen.dart

// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'operator_detail_screen_old.dart';
import 'add_operator_screen_old.dart';
import 'accept_operator_screen_old.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OperatorManagementScreen extends StatefulWidget {
  const OperatorManagementScreen({super.key});

  @override
  State<OperatorManagementScreen> createState() =>
      _OperatorManagementScreenState();
}

class _OperatorManagementScreenState extends State<OperatorManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _operators = [];
  bool _loading = true;
  String? _error;
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    _loadOperators();
  }

  Future<void> _loadOperators() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _error = 'No user logged in';
          _loading = false;
        });
        return;
      }

      // Get team members from teams/{teamId}/members
      final teamId = currentUser.uid;
      final membersSnapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .orderBy('addedAt', descending: true)
          .get();

      final List<Map<String, dynamic>> operators = [];

      for (var doc in membersSnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String?;

        if (userId != null) {
          // Fetch full user details from users collection
          final userDoc = await _firestore
              .collection('users')
              .doc(userId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final firstName = userData['firstname'] ?? '';
            final lastName = userData['lastname'] ?? '';
            final name = '$firstName $lastName'.trim();

            operators.add({
              'id': userId,
              'uid': userId,
              'name': name.isNotEmpty ? name : data['name'] ?? 'Unknown',
              'email': data['email'] ?? userData['email'] ?? '',
              'role': data['role'] ?? userData['role'] ?? 'Operator',
              'isArchived': data['isArchived'] ?? false,
              'hasLeft': data['hasLeft'] ?? false,
              'leftAt': data['leftAt'] as Timestamp?,
              'archivedAt': data['archivedAt'] as Timestamp?,
              'dateAdded': _formatTimestamp(data['addedAt'] as Timestamp?),
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _operators = operators;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = timestamp.toDate();
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year}';
  }

  void _restoreOperator(int index) async {
    final operator = _operators[index];

    // Cannot restore if operator has left
    if (operator['hasLeft'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot restore operators who have left the team'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final teamId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (teamId.isEmpty) return;

    try {
      await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(operator['uid'])
          .update({'isArchived': false, 'archivedAt': FieldValue.delete()});

      if (!mounted) return;

      setState(() {
        _operators[index]['isArchived'] = false;
        _operators[index]['archivedAt'] = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${operator['name']} restored successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error restoring operator: $e')));
    }
  }

  List<Map<String, dynamic>> get _activeOperators => _operators
      .where((o) => o['isArchived'] == false && o['hasLeft'] == false)
      .toList();

  List<Map<String, dynamic>> get _archivedOperators => _operators
      .where((o) => o['isArchived'] == true || o['hasLeft'] == true)
      .toList();

  @override
  Widget build(BuildContext context) {
    final currentList = _showArchived ? _archivedOperators : _activeOperators;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Operator Management',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.teal),
            onPressed: _loadOperators,
          ),
        ],
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddOperatorScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.check_circle,
                    label: 'Accept Operator',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AcceptOperatorScreen(),
                        ),
                      ).then((_) => _loadOperators());
                    },
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
                  const Text(
                    'Lists of Operators',
                    style: TextStyle(
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Error loading operators:',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadOperators,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : currentList.isEmpty
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
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final operator = currentList[index];
                            final globalIndex = _operators.indexWhere(
                              (o) =>
                                  o['id'] == operator['id'] ||
                                  (o['name'] == operator['name'] &&
                                      o['email'] == operator['email']),
                            );

                            final hasLeft = operator['hasLeft'] == true;
                            final isArchived = operator['isArchived'] == true;

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
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: hasLeft
                                        ? Colors.red.shade100
                                        : isArchived
                                        ? Colors.orange.shade100
                                        : Colors.teal.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: hasLeft
                                        ? Colors.red.shade700
                                        : isArchived
                                        ? Colors.orange.shade700
                                        : Colors.teal.shade700,
                                    size: 20,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        operator['name'] ?? 'Unnamed',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (hasLeft)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.red.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          'Left Team',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      operator['email'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (_showArchived) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        hasLeft
                                            ? 'Left: ${_formatTimestamp(operator['leftAt'] as Timestamp?)}'
                                            : 'Archived: ${_formatTimestamp(operator['archivedAt'] as Timestamp?)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: _showArchived
                                    ? (hasLeft
                                          ? null // No restore button for left operators
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.teal.shade100,
                                                foregroundColor:
                                                    Colors.teal.shade800,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  _restoreOperator(globalIndex),
                                              child: const Text(
                                                'Restore',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ))
                                    : const Icon(
                                        Icons.chevron_right,
                                        color: Colors.teal,
                                      ),
                                onTap: (_showArchived && hasLeft)
                                    ? null // Disable tap for left operators
                                    : _showArchived
                                    ? null // Disable tap for archived view
                                    : () async {
                                        final shouldRefresh =
                                            await Navigator.push<bool>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OperatorDetailScreen(
                                                      operatorId:
                                                          operator['uid'] ??
                                                          operator['id'] ??
                                                          '',
                                                      operatorName:
                                                          operator['name'] ??
                                                          '',
                                                      role:
                                                          operator['role'] ??
                                                          '',
                                                      email:
                                                          operator['email'] ??
                                                          '',
                                                      dateAdded:
                                                          operator['dateAdded'] ??
                                                          '',
                                                    ),
                                              ),
                                            );

                                        if (shouldRefresh == true) {
                                          _loadOperators();
                                        }
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      color: Colors.teal.withValues(alpha: 0.3),
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
