// lib/web/admin/screens/web_operator_management.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/web_add_operator_screen.dart';
import '../widgets/web_admin_search_bar.dart';
import '../widgets/web_accept_operators_card.dart';


class WebOperatorManagement extends StatefulWidget {
  const WebOperatorManagement({super.key});

  @override
  State<WebOperatorManagement> createState() => _WebOperatorManagementState();
}

class _WebOperatorManagementState extends State<WebOperatorManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _operators = [];
  bool _loading = true;
  String? _error;
  bool _showArchived = false;
  String _searchQuery = '';
  Map<String, dynamic>? _selectedOperator;

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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        title: const Text(
          'Operator Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action Cards Row - Shrink when details panel is open
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _selectedOperator == null
                  ? SizedBox(
                      height: 120,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.archive,
                              label: 'Archive',
                              count: _operators.where((o) => o['isArchived'] == true || o['hasLeft'] == true).length,
                              onPressed: () => setState(() => _showArchived = true),
                              showCountNext: true,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 450, maxHeight: 800),
                                      child: const WebAddOperatorCard(),
                                    ),
                                  ),
                                ).then((_) => _loadOperators());
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
                                      child: const WebAcceptOperatorsScreen(),
                                    ),
                                  ),
                                ).then((_) => _loadOperators());
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.people,
                              label: 'Active Operators',
                              count: _operators.where((o) => o['isArchived'] == false && o['hasLeft'] == false).length,
                              onPressed: () => setState(() => _showArchived = false),
                              showCountNext: true,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 0,
                      child: Container(),
                    ),
            ),
            const SizedBox(height: 12),

            // Main Content Area
            Expanded(
              child: Row(
                children: [
                  // Left Side - Operator List (Shrinks when details open)
                  Expanded(
                    flex: _selectedOperator == null ? 2 : 1,
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!, width: 1.0),
                        ),
                        child: Column(
                          children: [
                            // Search Bar Header
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title Row - Show for both active and archived
                                  if (_showArchived)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.arrow_back, color: Colors.teal, size: 20),
                                              onPressed: () => setState(() => _showArchived = false),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Archived Operators',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  if (!_showArchived)
                                    const Text(
                                      'Active Operators',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  // Search Bar
                                  WebOperatorSearchBar(
                                    searchQuery: _searchQuery,
                                    onSearchChanged: (value) => setState(() => _searchQuery = value),
                                    onRefresh: _loadOperators,
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // Content - takes remaining space
                            Expanded(
                              child: _buildContent(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Spacing between list and details
                  if (_selectedOperator != null) const SizedBox(width: 12),
                  // Right Side - Operator Details Panel
                  if (_selectedOperator != null)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: _buildOperatorDetailPanel(),
                    ),
                ],
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: displayList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final operator = displayList[index];
        final isSelected = _selectedOperator?['id'] == operator['id'];

        return GestureDetector(
          onTap: () => setState(() => _selectedOperator = operator),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.teal.shade300 : Colors.transparent,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operator['name'] ?? 'Unnamed',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        operator['email'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOperatorDetailPanel() {
    final operator = _selectedOperator!;
    final hasLeft = operator['hasLeft'] == true;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedOperator = null),
                padding: const EdgeInsets.all(8),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 28,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              operator['name'] ?? 'Unnamed',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.teal.shade200),
                              ),
                              child: Text(
                                operator['role'] ?? '',
                                style: TextStyle(
                                  color: Colors.teal.shade800,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Info Rows
                  _buildDetailRow(Icons.email_outlined, 'Email', operator['email'] ?? '', fontSize: 11),
                  const SizedBox(height: 10),
                  _buildDetailRow(Icons.calendar_today_outlined, 'Date Added', operator['dateAdded'] ?? '', fontSize: 11),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const Divider(height: 1),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_showArchived && !hasLeft) ...[
                    ElevatedButton.icon(
                      onPressed: () => _archiveOperatorFromDetail(operator),
                      icon: const Icon(Icons.archive, size: 15),
                      label: const Text('Archive', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                  if (_showArchived && !hasLeft) ...[
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _restoreOperator(operator);
                        setState(() => _selectedOperator = null);
                      },
                      icon: const Icon(Icons.restore, size: 15),
                      label: const Text('Restore', style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {double fontSize = 14}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.grey[700], size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _archiveOperatorFromDetail(Map<String, dynamic> operator) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Archive Operator'),
        content: Text('Are you sure you want to archive ${operator['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final teamId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (teamId.isEmpty) return;

      await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(operator['uid'])
          .update({
        'isArchived': true,
        'archivedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      await _loadOperators();
      if (mounted) {
        setState(() => _selectedOperator = null);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error archiving operator: $e')),
      );
    }
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required int? count,
    required VoidCallback? onPressed,
    bool showCountNext = false,
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
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (showCountNext && count != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
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
}