import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/primary_button.dart';
import 'package:flutter_application_1/ui/waiting_approval/view_model/waiting_approval_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaitingApprovalScreen extends ConsumerStatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  ConsumerState<WaitingApprovalScreen> createState() =>
      _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends ConsumerState<WaitingApprovalScreen> {
  void _cancelRequest() {
    ref.read(waitingApprovalProvider.notifier).cancelRequest();
  }

  void _signOut() {
    ref.read(waitingApprovalProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final state = ref.watch(waitingApprovalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    Icon(
                      Icons.hourglass_top,
                      size: isDesktop ? 50 : 40,
                      color: AppColors.green100,
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

                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Cancel Request',
                        isLoading: state.isLoading,
                        onPressed: _cancelRequest,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 16 : 12),

                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Sign Out',
                        isLoading: state.isLoading,
                        onPressed: _signOut,
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
