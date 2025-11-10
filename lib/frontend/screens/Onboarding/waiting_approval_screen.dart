import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/auth_notifier.dart';
import 'package:flutter_application_1/utils/snackbar_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaitingApprovalScreen extends ConsumerStatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  ConsumerState<WaitingApprovalScreen> createState() =>
      _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends ConsumerState<WaitingApprovalScreen> {
  bool _loading = false;

  Future<void> _cancelRequest(BuildContext context, WidgetRef ref) async {
		setState(() => _loading = true);
    final authNotifier = ref.read(authStateProvider.notifier);
    try {
      await authNotifier.cancelTeam();
    } catch (e) {
      showSnackbar(
        context,
        'Failed to cancel request. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      showSnackbar(
        context,
        'Failed to log out. Please try again.',
        isError: true,
      );
    }
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
              title: const Text('Waiting for Approval'),
              backgroundColor: Colors.teal,
              automaticallyImplyLeading: false,
            ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : double.infinity,
          ),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
            child: Card(
              elevation: isDesktop ? 8 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 20 : 0),
              ),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 48.0 : 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: isDesktop ? 100 : 80,
                      height: isDesktop ? 100 : 80,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.hourglass_top,
                        size: isDesktop ? 50 : 40,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 32 : 24),

                    // Title
                    if (isDesktop) ...[
                      const Text(
                        'Waiting for Approval',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Main message
                    Text(
                      'Your request to join a team is pending approval.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 16 : 12),

                    // Secondary message
                    Text(
                      'An admin will review your request. You will be added to the team once approved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 48 : 32),

                    // Cancel Request Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        //onPressed: _loading ? null : _cancelRequest,
												onPressed: () => _cancelRequest(context, ref),
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
                        child: _loading
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
                                'Cancel Request',
                                style: TextStyle(
                                  fontSize: isDesktop ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 16 : 12),

                    // Back to Login Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _signOut(context),
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
    );
  }
}
