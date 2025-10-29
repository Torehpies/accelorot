import 'package:flutter/material.dart';
import 'dart:math';
import 'invitation_code_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebAcceptOperatorsScreen extends StatefulWidget {
	const WebAcceptOperatorsScreen({super.key});

	@override
	State<WebAcceptOperatorsScreen> createState() => _WebAcceptOperatorsScreenState();
}


class _WebAcceptOperatorsScreenState extends State<WebAcceptOperatorsScreen> {
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

	String _generateCode() {
		const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
		final rnd = Random.secure();
		return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
	}

	Future<void> _onGenerateCode() async {
		final user = FirebaseAuth.instance.currentUser;
		if (user == null) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Error: No user logged in')),
			);
			return;
		}

		final teamId = user.uid;
		try {
			final teamDocRef = _firestore.collection('teams').doc(teamId);
			final teamDoc = await teamDocRef.get();

			String code;
			DateTime expiry;

			if (teamDoc.exists) {
				final data = teamDoc.data();
				final existingCode = data?['joinCode'] as String?;
				final expiresAt = data?['joinCodeExpiresAt'] as Timestamp?;

				if (existingCode != null && expiresAt != null) {
					final expiryDate = expiresAt.toDate();
					if (expiryDate.isAfter(DateTime.now())) {
						final expiryStr =
							'${expiryDate.year}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}';
						if (!mounted) return;
						showInvitationOverlay(context, existingCode, expiryStr);
						return;
					}
				}

				code = _generateCode();
				expiry = DateTime.now().add(const Duration(hours: 24));

				await teamDocRef.set({
					'ownerId': teamId,
					'joinCode': code,
					'joinCodeExpiresAt': expiry,
					'createdAt': data?['createdAt'] ?? FieldValue.serverTimestamp(),
					'updatedAt': FieldValue.serverTimestamp(),
				}, SetOptions(merge: true));
			} else {
				code = _generateCode();
				expiry = DateTime.now().add(const Duration(hours: 24));

				await teamDocRef.set({
					'ownerId': teamId,
					'joinCode': code,
					'joinCodeExpiresAt': expiry,
					'createdAt': FieldValue.serverTimestamp(),
					'updatedAt': FieldValue.serverTimestamp(),
				});
			}

			final expiryStr =
					'${expiry.year}-${expiry.month.toString().padLeft(2, '0')}-${expiry.day.toString().padLeft(2, '0')}';
			if (!mounted) return;
			showInvitationOverlay(context, code, expiryStr);
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Error: $e')),
			);
		}
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

			final userRef = _firestore.collection('users').doc(requestorId);
			batch.update(userRef, {
				'teamId': teamId,
				'pendingTeamId': FieldValue.delete(),
			});

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

			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('✅ Accepted $name to the team'),
					backgroundColor: Colors.green,
				),
			);
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Error accepting invitation: $e')),
			);
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

			final userRef = _firestore.collection('users').doc(requestorId);
			batch.update(userRef, {
				'pendingTeamId': FieldValue.delete(),
			});

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

			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(
					content: Text('Declined invitation from $name'),
					backgroundColor: Colors.orange,
				),
			);
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(
				SnackBar(content: Text('Error declining invitation: $e')),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Dialog(
			backgroundColor: Colors.grey[300],
			insetPadding: const EdgeInsets.all(24),
			child: Center(
				child: Container(
					constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(24),
					),
					child: Column(
						children: [
							// Header
							Padding(
								padding: const EdgeInsets.all(24),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: [
												Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														const Text(
															'Accept Operators',
															style: TextStyle(
																fontSize: 20,
																fontWeight: FontWeight.bold,
																color: Colors.black87,
															),
														),
														const SizedBox(height: 4),
														Text(
															'Review and manage pending operator invitations',
															style: TextStyle(
																fontSize: 13,
																color: Colors.grey[600],
															),
														),
													],
												),
												IconButton(
													icon: const Icon(Icons.close),
													onPressed: () => Navigator.pop(context),
													style: IconButton.styleFrom(
														backgroundColor: Colors.grey[100],
													),
												),
											],
										),
										const SizedBox(height: 16),
										// Generate Code Button
										SizedBox(
											width: double.infinity,
											child: ElevatedButton.icon(
												onPressed: _onGenerateCode,
												icon: const Icon(Icons.qr_code, size: 18),
												label: const Text('Generate Invitation Code'),
												style: ElevatedButton.styleFrom(
													backgroundColor: Colors.teal.shade600,
													foregroundColor: Colors.white,
													padding: const EdgeInsets.symmetric(vertical: 12),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(12),
													),
												),
											),
										),
									],
								),
							),
							const Divider(height: 1),
							// Content
							Expanded(
								child: _buildContent(),
							),
						],
					),
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
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							Icons.error_outline,
							size: 48,
							color: Colors.red.shade300,
						),
						const SizedBox(height: 16),
						const Text(
							'Error loading pending members',
							style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.bold,
								color: Colors.black87,
							),
						),
						const SizedBox(height: 8),
						Text(
							_error ?? '',
							textAlign: TextAlign.center,
							style: TextStyle(
								fontSize: 13,
								color: Colors.grey[600],
							),
						),
						const SizedBox(height: 16),
						ElevatedButton.icon(
							onPressed: _loadPendingMembers,
							icon: const Icon(Icons.refresh, size: 16),
							label: const Text('Retry'),
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.teal.shade600,
								foregroundColor: Colors.white,
							),
						),
					],
				),
			);
		}

		if (_pendingMembers.isEmpty) {
			return Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							Icons.inbox_outlined,
							size: 64,
							color: Colors.grey[300],
						),
						const SizedBox(height: 16),
						Text(
							'No pending invitations',
							style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.bold,
								color: Colors.grey[600],
							),
						),
						const SizedBox(height: 8),
						Text(
							'All operators have been accepted or declined',
							style: TextStyle(
								fontSize: 13,
								color: Colors.grey[500],
							),
						),
					],
				),
			);
		}

		return ListView.separated(
			padding: const EdgeInsets.all(20),
			itemCount: _pendingMembers.length,
			separatorBuilder: (context, index) => const SizedBox(height: 12),
			itemBuilder: (context, index) {
				final member = _pendingMembers[index];
				return Container(
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(16),
						border: Border.all(
							color: Colors.grey,
							width: 1,
						),
					),
					child: Padding(
						padding: const EdgeInsets.all(16),
						child: Row(
							children: [
								// Avatar
								Container(
									width: 48,
									height: 48,
									decoration: BoxDecoration(
										color: Colors.teal.shade100,
										borderRadius: BorderRadius.circular(12),
									),
									child: Icon(
										Icons.person,
										color: Colors.teal.shade700,
										size: 24,
									),
								),
								const SizedBox(width: 16),
								// User Info
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												member['name'] ?? 'Unknown',
												style: const TextStyle(
													fontWeight: FontWeight.w600,
													fontSize: 14,
													color: Colors.black87,
												),
											),
											const SizedBox(height: 4),
											Text(
												member['email'] ?? '',
												style: TextStyle(
													fontSize: 12,
													color: Colors.grey[600],
												),
											),
											const SizedBox(height: 4),
											Text(
												'Requested: ${member['date']}',
												style: TextStyle(
													fontSize: 11,
													color: Colors.grey[500],
												),
											),
										],
									),
								),
								const SizedBox(width: 12),
								// Action Buttons
								Column(
									mainAxisSize: MainAxisSize.min,
									children: [
										SizedBox(
											width: 100,
											child: ElevatedButton(
												onPressed: () => _acceptInvitation(index),
												style: ElevatedButton.styleFrom(
													backgroundColor: Colors.teal.shade600,
													foregroundColor: Colors.white,
													padding: const EdgeInsets.symmetric(
														horizontal: 12,
														vertical: 8,
													),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(10),
													),
												),
												child: const Text(
													'Accept',
													style: TextStyle(fontSize: 12),
												),
											),
										),
										const SizedBox(height: 8),
										SizedBox(
											width: 100,
											child: OutlinedButton(
												onPressed: () => _declineInvitation(index),
												style: OutlinedButton.styleFrom(
													foregroundColor: Colors.grey[700],
													side: BorderSide(
														color: Colors.grey[300]!,
													),
													padding: const EdgeInsets.symmetric(
														horizontal: 12,
														vertical: 8,
													),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(10),
													),
												),
												child: const Text(
													'Decline',
													style: TextStyle(fontSize: 12),
												),
											),
										),
									],
								),
							],
						),
					),
				);
			},
		);
	}
}