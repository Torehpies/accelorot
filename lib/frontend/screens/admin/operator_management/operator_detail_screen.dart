// lib/frontend/screens/admin/operator_management/operator_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'operator_view_navigation.dart';

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
  bool _isArchiving = false;

  Future<void> _archiveOperator() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Operator'),
        content: Text(
          'Are you sure you want to archive ${widget.operatorName}?\n\n'
          'They will be moved to the archived list and can be restored later.',
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
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isArchiving = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final teamId = currentUser.uid;

      // Update the member document to set isArchived = true
      await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(widget.operatorId)
          .update({'isArchived': true});

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.operatorName} has been archived'),
          backgroundColor: Colors.green,
        ),
      );

      // Go back to operator management screen
      Navigator.pop(context, true); // Return true to indicate refresh needed
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isArchiving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error archiving operator: $e'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.archive, color: Colors.red),
            onPressed: _isArchiving ? null : _archiveOperator,
            tooltip: 'Archive Operator',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
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
            
            // View as Operator button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isArchiving
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OperatorViewNavigation(
                              operatorId: widget.operatorId,
                              operatorName: widget.operatorName,
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.visibility),
                label: const Text('View as Operator'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Archive button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isArchiving ? null : _archiveOperator,
                icon: _isArchiving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.archive),
                label: Text(_isArchiving ? 'Archiving...' : 'Archive Operator'),
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