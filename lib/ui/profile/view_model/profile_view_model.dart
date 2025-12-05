import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileViewModel {
  bool isLoading = true;

  String username = '';
  String fullName = '';
  String email = '';
  String role = '';

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      final data = doc.data();
      username = data?['username'] ?? user.displayName?.split(' ').first ?? '';
      fullName = data?['fullname'] ?? user.displayName ?? '';
      email = data?['email'] ?? user.email ?? '';
      role = data?['role'] ?? 'User';
    } catch (e) {
      debugPrint('Error loading user: $e');
    }

    isLoading = false;
  }
}
