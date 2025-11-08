// lib/services/invitation_service.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Generate invitation code
  String generateCode() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  // Get or create invitation code
  Future<Map<String, String>> getOrCreateInvitationCode() async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    final teamDocRef = _firestore.collection('teams').doc(currentUserId);
    final teamDoc = await teamDocRef.get();

    String code;
    DateTime expiry;

    if (teamDoc.exists) {
      final data = teamDoc.data();
      final existingCode = data?['joinCode'] as String?;
      final expiresAt = data?['joinCodeExpiresAt'] as Timestamp?;

      // Check if existing code is still valid
      if (existingCode != null && expiresAt != null) {
        final expiryDate = expiresAt.toDate();
        if (expiryDate.isAfter(DateTime.now())) {
          return {
            'code': existingCode,
            'expiry': _formatDate(expiryDate),
          };
        }
      }

      // Generate new code
      code = generateCode();
      expiry = DateTime.now().add(const Duration(hours: 24));

      await teamDocRef.set({
        'ownerId': currentUserId,
        'joinCode': code,
        'joinCodeExpiresAt': expiry,
        'createdAt': data?['createdAt'] ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      // Create new team document
      code = generateCode();
      expiry = DateTime.now().add(const Duration(hours: 24));

      await teamDocRef.set({
        'ownerId': currentUserId,
        'joinCode': code,
        'joinCodeExpiresAt': expiry,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return {
      'code': code,
      'expiry': _formatDate(expiry),
    };
  }

  // Generate new invitation code (force new)
  Future<Map<String, String>> generateNewInvitationCode() async {
    if (currentUserId == null) {
      throw Exception('No user logged in');
    }

    final code = generateCode();
    final expiry = DateTime.now().add(const Duration(hours: 24));

    await _firestore.collection('teams').doc(currentUserId).update({
      'joinCode': code,
      'joinCodeExpiresAt': expiry,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return {
      'code': code,
      'expiry': _formatDate(expiry),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
