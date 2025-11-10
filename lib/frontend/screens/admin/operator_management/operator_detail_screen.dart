// lib/frontend/screens/admin/operator_management/operator_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OperatorDetailScreen extends StatefulWidget {
  final String operatorId;
  final String operatorName;
  final String role;
  final String email;
  final String dateAdded;

  const OperatorDetailScreen({
    super.key,
    required this.operatorId,
    required this.operatorName,
    this.role = 'Operator',
    this.email = 'operator@example.com',
    this.dateAdded = 'Aug-25-2025',
  });

  @override
  State<OperatorDetailScreen> createState() => _OperatorDetailScreenState();
}

class _OperatorDetailScreenState extends State<OperatorDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isProcessing = false;

  Future<void> _archiveOperator() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Operator'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Archive ${widget.operatorName}?'),
            const SizedBox(height: 12),
            const Text(
              '• Operator will be temporarily restricted',
              style: TextStyle(fontSize: 13),
            ),
            const Text(
              '• Can be restored later',
              style: TextStyle(fontSize: 13),
            ),
            const Text(
              '• Operator cannot login while archived',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final teamId = currentUser.uid;
      final batch = _firestore.batch();

      // Update member document
      final memberRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(widget.operatorId);

      batch.update(memberRef, {
        'isArchived': true,
        'archivedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.operatorName} has been archived'),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error archiving operator: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removeOperator() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Remove ${widget.operatorName} from this team?'),
            const SizedBox(height: 12),
            const Text(
              '⚠️ This action is permanent:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Operator will be marked as "Left Team"',
              style: TextStyle(fontSize: 13),
            ),
            const Text(
              '• Cannot be restored (must rejoin via invite)',
              style: TextStyle(fontSize: 13),
            ),
            const Text(
              '• Operator can join other teams',
              style: TextStyle(fontSize: 13),
            ),
            const Text(
              '• Data retained in archive for records',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      final teamId = currentUser.uid;
      final batch = _firestore.batch();

      // Update member document - mark as left
      final memberRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(widget.operatorId);

      batch.update(memberRef, {
        'hasLeft': true,
        'leftAt': FieldValue.serverTimestamp(),
        'isArchived': false, // Clear archived status
        'archivedAt': FieldValue.delete(),
      });

      // Clear teamId from user document
      final userRef = _firestore.collection('users').doc(widget.operatorId);
      batch.update(userRef, {'teamId': FieldValue.delete()});

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.operatorName} has been removed from the team',
          ),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing operator: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.teal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Operator Details',
          style: TextStyle(color: Colors.teal),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Operator Info Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.teal.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.operatorName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Role:', widget.role),
                    const SizedBox(height: 12),
                    _buildDetailRow('Email:', widget.email),
                    const SizedBox(height: 12),
                    _buildDetailRow('Date Added:', widget.dateAdded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 12),

            // Archive button (temporary restriction)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _archiveOperator,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.archive),
                label: Text(
                  _isProcessing ? 'Processing...' : 'Archive (Temporary)',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Remove button (permanent)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _removeOperator,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.exit_to_app),
                label: Text(
                  _isProcessing
                      ? 'Processing...'
                      : 'Remove from Team (Permanent)',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Archive: Temporary restriction, can be restored.\nRemove: Permanent, operator must rejoin via invite.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.teal,
            ),
          ),
        ),
      ],
    );
  }
}
