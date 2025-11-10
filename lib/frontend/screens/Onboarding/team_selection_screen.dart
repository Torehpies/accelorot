import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/utils/snackbar_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';

class TeamSelectionScreen extends ConsumerStatefulWidget {
  const TeamSelectionScreen({super.key});

  @override
  ConsumerState<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends ConsumerState<TeamSelectionScreen> {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  bool _submitting = false;
  String? _selectedTeamId;
  List<Map<String, dynamic>> _teams = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final teamsSnapshot = await _firestore.collection('teams').get();
      final teams = teamsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, 'name': data['teamName'] ?? 'Unnamed Team'};
      }).toList();

      if (mounted) {
        setState(() {
          _teams = teams;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load teams: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _submitTeamRequest() async {
    if (_selectedTeamId == null) {
      showSnackbar(context, 'Please select a team first.');
      return;
    }

    final user = _auth.getCurrentUser();
    if (user == null) return;

    setState(() => _submitting = true);

    try {
      final batch = _firestore.batch();

      // Add to pending_members subcollection
      final pendingRef = _firestore
          .collection('teams')
          .doc(_selectedTeamId!)
          .collection('pending_members')
          .doc(user.uid);

      batch.set(pendingRef, {
        'requestorId': user.uid,
        'requestorEmail': user.email ?? '',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      // Set pendingTeamId in user document
      final userRef = _firestore.collection('users').doc(user.uid);
      batch.update(userRef, {'pendingTeamSelection': _selectedTeamId});

      await batch.commit();
      _onSuccessRequest();

      if (!mounted) return;

      showSnackbar(context, 'Request submitted! Waiting for approval.');

      // Navigate to waiting approval screen
      //context.go('/pending');
    } catch (e) {
      if (mounted) {
        showSnackbar(context, 'Failed to submit request: $e');
      }
    } finally {
      setState(() => _submitting = false);
    }
  }

  Future<void> _onSuccessRequest() async {
//    final authListenable = ref.read(authListenableProvider.notifier);
//    await authListenable.refreshIsPending();
  }

  Future<void> _handleBackToLogin() async {
    if (!mounted) return;
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDesktop ? Colors.grey[50] : null,
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Join a Team'),
              backgroundColor: Colors.teal,
              automaticallyImplyLeading: false,
            ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : double.infinity,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
              child: Card(
                elevation: isDesktop ? 8 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isDesktop ? 20 : 0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 40.0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      if (isDesktop) ...[
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade400,
                                  Colors.teal.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.trending_up,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else
                        const SizedBox(height: 24),

                      Text(
                        'Join a Team',
                        style: TextStyle(
                          fontSize: isDesktop ? 32 : 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isDesktop ? 16 : 12),
                      Text(
                        'Select a team to request joining. The team admin will review your request.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 32 : 24),

                      // Loading or Error State
                      if (_loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_error != null)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadTeams,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_teams.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No teams available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        // Team Dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _selectedTeamId,
                          decoration: InputDecoration(
                            labelText: 'Select Team',
                            hintText: 'Choose a team to join',
                            prefixIcon: const Icon(Icons.groups),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _teams.map((team) {
                            return DropdownMenuItem<String>(
                              value: team['id'] as String,
                              child: Text(team['name'] as String),
                            );
                          }).toList(),
                          onChanged: _submitting
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedTeamId = value;
                                  });
                                },
                        ),
                        SizedBox(height: isDesktop ? 32 : 24),

                        // Info message
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your request will be sent to the team admin for approval.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade900,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isDesktop ? 32 : 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitting || _selectedTeamId == null
                                ? null
                                : _submitTeamRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isDesktop ? 18 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Submit Request',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 16 : 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 16 : 12),
                      ],

                      // Back to Login Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _submitting ? null : _handleBackToLogin,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.teal,
                            side: const BorderSide(color: Colors.teal),
                            padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 18 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Back to Login',
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
