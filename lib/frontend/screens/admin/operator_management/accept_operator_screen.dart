import 'package:flutter/material.dart';
import 'dart:math';
import 'invitation_code_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AcceptOperatorScreen extends StatefulWidget {
	const AcceptOperatorScreen({super.key});

	@override
	State<AcceptOperatorScreen> createState() => _AcceptOperatorScreenState();
}

class _AcceptOperatorScreenState extends State<AcceptOperatorScreen> {
	final FirebaseFirestore _firestore = FirebaseFirestore.instance;
	
	// Mock scanned users (people who scanned or entered the code)
	final List<Map<String, String>> _scannedUsers = [];

	@override
	void initState() {
		super.initState();
		// seed mock users with the current timestamp as entry date
		final now = DateTime.now();
		final formatted = (DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

		_scannedUsers.addAll([
			{'name': 'Lina Alvarez', 'email': 'lina.alvarez@example.com', 'date': formatted(now.subtract(const Duration(minutes: 12)))},
			{'name': 'Marcus Chen', 'email': 'marcus.chen@example.com', 'date': formatted(now.subtract(const Duration(minutes: 46)))},
			{'name': 'Aisha Mohammed', 'email': 'aisha.mohammed@example.com', 'date': formatted(now.subtract(const Duration(hours: 2, minutes: 5)))},
			{'name': 'Ethan Brooks', 'email': 'ethan.brooks@example.com', 'date': formatted(now.subtract(const Duration(days: 1, hours: 1)))},
			{'name': 'Priya Kapoor', 'email': 'priya.kapoor@example.com', 'date': formatted(now.subtract(const Duration(minutes: 3)))},
		]);
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

  final teamId = user.uid; // each admin's team uses their UID as doc ID
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
          // Still valid — just show the QR again
          final expiryStr =
              '${expiryDate.year}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}';
          showInvitationOverlay(context, existingCode, expiryStr);
          return;
        }
      }

      // Otherwise, generate a new one
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
      // New team document
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
    showInvitationOverlay(context, code, expiryStr);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

	void _acceptInvitation(int index) {
		final name = _scannedUsers[index]['name'] ?? 'Applicant';
		setState(() {
			_scannedUsers.removeAt(index);
		});
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text('Accepted invitation from $name')),
		);
	}

	void _declineInvitation(int index) {
		final name = _scannedUsers[index]['name'] ?? 'Applicant';
		setState(() {
			_scannedUsers.removeAt(index);
		});
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text('Declined invitation from $name')),
		);
	}

	@override
	Widget build(BuildContext context) {
		final currentList = _scannedUsers;

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
			),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// Single Action Card: Generate Invitation Code
						Row(
							children: [
								Expanded(
									child: _buildActionCard(
										icon: Icons.qr_code,
										label: 'Generate Invitation Code',
										onPressed: _onGenerateCode,
									),
								),
							],
						),
						const SizedBox(height: 16),

						const Text(
							'Scanned / Entered Invitations',
							style: TextStyle(
								fontSize: 18,
								fontWeight: FontWeight.bold,
								color: Colors.teal,
							),
						),
						const SizedBox(height: 12),

						// List of scanned users
						Expanded(
							child: currentList.isEmpty
									? Center(
											child: Text(
												'No scanned invitations',
												style: const TextStyle(color: Colors.grey),
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
													itemCount: currentList.length,
													separatorBuilder: (_, __) => const SizedBox(height: 12),
													itemBuilder: (context, index) {
														final user = currentList[index];
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
																		horizontal: 16, vertical: 12),
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
																	user['name'] ?? 'Unknown',
																	style: const TextStyle(fontWeight: FontWeight.w600),
																),
																								subtitle: Column(
																									crossAxisAlignment: CrossAxisAlignment.start,
																									children: [
																										Text(
																											user['email'] ?? '',
																											style: const TextStyle(fontSize: 13, color: Colors.grey),
																										),
																										const SizedBox(height: 4),
																										Text(
																											user['date'] ?? '',
																											style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
																						horizontal: 12, vertical: 6),
																				shape: RoundedRectangleBorder(
																					borderRadius: BorderRadius.circular(8),
																				),
																			),
																			onPressed: () => _acceptInvitation(index),
																			child: const Text('Accept', style: TextStyle(fontSize: 13)),
																		),
																		const SizedBox(width: 8),
																		OutlinedButton(
																			style: OutlinedButton.styleFrom(
																				foregroundColor: Colors.red.shade700,
																				side: BorderSide(color: Colors.red.shade100),
																				padding: const EdgeInsets.symmetric(
																						horizontal: 12, vertical: 6),
																				shape: RoundedRectangleBorder(
																					borderRadius: BorderRadius.circular(8),
																				),
																			),
																			onPressed: () => _declineInvitation(index),
																			child: const Text('Decline', style: TextStyle(fontSize: 13)),
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

	Widget _buildActionCard({
		required IconData icon,
		required String label,
		required VoidCallback onPressed,
	}) {
		return Card(
			elevation: 8,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(16),
			),
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
											color: Colors.teal.withOpacity(0.3),
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