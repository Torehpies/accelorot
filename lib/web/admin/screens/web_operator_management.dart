// lib/web/admin/screens/web_operator_management.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/frontend/screens/admin/operator_management/add_operator_screen.dart';
import 'package:flutter_application_1/frontend/screens/admin/operator_management/accept_operator_screen.dart';
import 'web_operator_detail_screen.dart';

class WebUserListScreen extends StatefulWidget {
  const WebUserListScreen({super.key});

  @override
  State<WebUserListScreen> createState() => _WebUserListScreenState();
}

class _WebUserListScreenState extends State<WebUserListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _operators = [];
  bool _loading = true;
  String? _error;
  bool _showArchived = false;
  String _searchQuery = '';

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

  Future<void> _restoreOperator(Map<String, dynamic> operator) async {
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
          .update({
        'isArchived': false,
        'archivedAt': FieldValue.delete(),
      });

      if (!mounted) return;

      await _loadOperators();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${operator['name']} restored successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error restoring operator: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredOperators {
    final currentList = _showArchived
        ? _operators.where((o) => o['isArchived'] == true || o['hasLeft'] == true).toList()
        : _operators.where((o) => o['isArchived'] == false && o['hasLeft'] == false).toList();

    if (_searchQuery.isEmpty) return currentList;

    return currentList.where((operator) {
      final name = (operator['name'] ?? '').toLowerCase();
      final email = (operator['email'] ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Operator Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              if (_showArchived)
                TextButton.icon(
                  onPressed: () => setState(() => _showArchived = false),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back to Active Operators'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Cards Row
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.archive,
                  label: 'Archive',
                  count: _operators.where((o) => o['isArchived'] == true || o['hasLeft'] == true).length,
                  onPressed: () => setState(() => _showArchived = true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.person_add_alt_1,
                  label: 'Add Operator',
                  count: null,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 500, maxHeight: 600),
                          child: AddOperatorScreen(),
                        ),
                      ),
                    ).then((_) => _loadOperators());
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.check_circle,
                  label: 'Accept Operator',
                  count: null,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 500, maxHeight: 600),
                          child: AcceptOperatorScreen(),
                        ),
                      ),
                    ).then((_) => _loadOperators());
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.people,
                  label: 'Active Operators',
                  count: _operators.where((o) => o['isArchived'] == false && o['hasLeft'] == false).length,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Container
          Container(
            constraints: const BoxConstraints(minHeight: 500),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'Search operators...',
                            prefixIcon: const Icon(Icons.search, color: Colors.teal),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => setState(() => _searchQuery = ''),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.teal, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.teal),
                        onPressed: _loadOperators,
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                
                // Content
                SizedBox(
                  height: 500,
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              const Text(
                'Error loading operators:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadOperators,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayList = _filteredOperators;

    if (displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No operators found matching "$_searchQuery"'
                  : _showArchived
                      ? 'No archived operators'
                      : 'No operators available',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: displayList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final operator = displayList[index];
        final hasLeft = operator['hasLeft'] == true;
        final isArchived = operator['isArchived'] == true;

        return Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasLeft
                    ? Colors.red.shade100
                    : isArchived
                        ? Colors.orange.shade100
                        : Colors.teal.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person,
                color: hasLeft
                    ? Colors.red.shade700
                    : isArchived
                        ? Colors.orange.shade700
                        : Colors.teal.shade700,
                size: 24,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    operator['name'] ?? 'Unnamed',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (hasLeft)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'Left Team',
                      style: TextStyle(
                        fontSize: 11,
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
                const SizedBox(height: 4),
                Text(
                  operator['email'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                if (_showArchived) ...[
                  const SizedBox(height: 4),
                  Text(
                    hasLeft
                        ? 'Left: ${_formatTimestamp(operator['leftAt'] as Timestamp?)}'
                        : 'Archived: ${_formatTimestamp(operator['archivedAt'] as Timestamp?)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ],
            ),
            trailing: _showArchived
                ? (hasLeft
                    ? null
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade100,
                          foregroundColor: Colors.teal.shade800,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () => _restoreOperator(operator),
                        icon: const Icon(Icons.restore, size: 16),
                        label: const Text('Restore'),
                      ))
                : const Icon(Icons.chevron_right, color: Colors.teal),
            onTap: (_showArchived && hasLeft)
                ? null
                : _showArchived
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebOperatorDetailScreen(
                              operatorId: operator['uid'] ?? operator['id'] ?? '',
                              operatorName: operator['name'] ?? '',
                              role: operator['role'] ?? '',
                              email: operator['email'] ?? '',
                              dateAdded: operator['dateAdded'] ?? '',
                            ),
                          ),
                        ).then((shouldRefresh) {
                          if (shouldRefresh == true) {
                            _loadOperators();
                          }
                        });
                      },
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required int? count,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (count != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: Colors.teal.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
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
}