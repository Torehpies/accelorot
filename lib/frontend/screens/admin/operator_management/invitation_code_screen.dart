import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showInvitationOverlay(BuildContext context, String initialCode, String initialExpiryDate) {
  // ignore: no_leading_underscores_for_local_identifiers
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // local generator used for "Generate New"
  String generateCode() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      String currentCode = initialCode;
      String currentExpiry = initialExpiryDate;
      bool isGenerating = false;

      String formatExpiry(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                width: 320,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Invitation Code",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 2,
                      color: const Color(0xFF2E4F2F),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Expiry Date: $currentExpiry",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: currentCode,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF2E4F2F),
                      ),
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF2E4F2F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Code: $currentCode",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: isGenerating ? null : () async {
                            setState(() => isGenerating = true);
                            
                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                throw Exception('No user logged in');
                              }

                              final teamId = user.uid;
                              final newCode = generateCode();
                              final newExpiry = DateTime.now().add(const Duration(hours: 24));

                              // Save new code to Firestore
                              await _firestore.collection('teams').doc(teamId).update({
                                'joinCode': newCode,
                                'joinCodeExpiresAt': newExpiry,
                                'updatedAt': FieldValue.serverTimestamp(),
                              });

                              setState(() {
                                currentCode = newCode;
                                currentExpiry = formatExpiry(newExpiry);
                                isGenerating = false;
                              });

                              // Show success message
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ New invitation code generated'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() => isGenerating = false);
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error generating code: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E4F2F),
                            minimumSize: const Size(140, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isGenerating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text("Generate New"),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: isGenerating ? null : () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(90, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}