import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AcceptOperatorScreen extends StatefulWidget {
  const AcceptOperatorScreen({super.key});

  @override
  State<AcceptOperatorScreen> createState() => _AcceptOperatorScreenState();
}

class _AcceptOperatorScreenState extends State<AcceptOperatorScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _pendingMembers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingMembers();
  }

  Future<void> _loadPendingMembers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'No user logged in';
          _loading = false;
        });
        return;
      }

      final teamId = user.uid;

      // Fetch pending members from teams/{teamId}/pending_members
      final snapshot = await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .orderBy('requestedAt', descending: true)
          .get();

      final List<Map<String, dynamic>> members = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final requestorId = data['requestorId'] as String?;

        if (requestorId != null) {
          // Fetch user details from users collection
          final userDoc = await _firestore
              .collection('users')
              .doc(requestorId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final firstName = userData['firstname'] ?? '';
            final lastName = userData['lastname'] ?? '';
            final name = '$firstName $lastName'.trim();

            members.add({
              'id': doc.id,
              'requestorId': requestorId,
              'name': name.isNotEmpty ? name : 'Unknown',
              'email': data['requestorEmail'] ?? userData['email'] ?? '',
              'date': _formatTimestamp(data['requestedAt'] as Timestamp?),
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _pendingMembers = members;
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
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _acceptInvitation(int index) async {
    final member = _pendingMembers[index];
    final requestorId = member['requestorId'] as String;
    final name = member['name'] ?? 'Applicant';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final teamId = user.uid;
      final batch = _firestore.batch();

      // 1. Add to teams/{teamId}/members collection
      final memberRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('members')
          .doc(requestorId);

      batch.set(memberRef, {
        'userId': requestorId,
        'name': name,
        'email': member['email'],
        'role': 'Operator',
        'addedAt': FieldValue.serverTimestamp(),
        'isArchived': false,
      });

      // 2. Update user document with teamId
      final userRef = _firestore.collection('users').doc(requestorId);
      batch.update(userRef, {
        'teamId': teamId,
        'pendingTeamId': FieldValue.delete(),
      });

      // 3. Delete from pending_members
      final pendingRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .doc(member['id']);
      batch.delete(pendingRef);

      await batch.commit();

      if (!mounted) return;

      setState(() {
        _pendingMembers.removeAt(index);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Accepted $name to the team')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error accepting invitation: $e')));
    }
  }

  Future<void> _declineInvitation(int index) async {
    final member = _pendingMembers[index];
    final requestorId = member['requestorId'] as String;
    final name = member['name'] ?? 'Applicant';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final teamId = user.uid;
      final batch = _firestore.batch();

      // 1. Clear pendingTeamId from user document
      final userRef = _firestore.collection('users').doc(requestorId);
      batch.update(userRef, {'pendingTeamId': FieldValue.delete()});

      // 2. Delete from pending_members
      final pendingRef = _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .doc(member['id']);
      batch.delete(pendingRef);

      await batch.commit();

      if (!mounted) return;

      setState(() {
        _pendingMembers.removeAt(index);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Declined invitation from $name')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error declining invitation: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Accept Operator Invitations',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.teal),
            onPressed: _loadPendingMembers,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Invitations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),

            // List of pending members
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Error loading pending members',
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
                            onPressed: _loadPendingMembers,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _pendingMembers.isEmpty
                  ? const Center(
                      child: Text(
                        'No pending invitations',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
                      constraints: const BoxConstraints(maxWidth: 700),
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
                          itemCount: _pendingMembers.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final member = _pendingMembers[index];
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
                                  member['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member['email'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      member['date'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => _acceptInvitation(index),
                                      child: const Text(
                                        'Accept',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red.shade700,
                                        side: BorderSide(
                                          color: Colors.red.shade100,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          _declineInvitation(index),
                                      child: const Text(
                                        'Decline',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
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
}
