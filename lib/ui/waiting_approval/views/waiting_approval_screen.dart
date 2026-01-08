import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/confirm_dialog.dart';
import 'package:flutter_application_1/ui/core/ui/outline_app_button.dart';
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
    final state = ref.watch(waitingApprovalProvider);

    ref.listen(waitingApprovalProvider, (prev, next) {
      next.whenOrNull(
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString()),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 600;
                final padding = isDesktop ? 48.0 : 24.0;

                return Container(
                  constraints: BoxConstraints(minWidth: 320, maxWidth: 600),
                  padding: EdgeInsets.all(32),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hourglass_top,
                            size: isDesktop ? 60 : 50,
                            color: AppColors.green100,
                          ),
                          SizedBox(height: padding),

                          FittedBox(
                            child: Text(
                              'Waiting for Approval',
                              style: TextStyle(
                                fontSize: isDesktop ? 32 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          Text(
                            'Your request to join a team is pending approval.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: isDesktop ? 18 : 16),
                          ),

                          SizedBox(height: 12),

                          Text(
                            'An admin will review your request...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),

                          SizedBox(height: padding),

                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              text: 'Cancel Request',
                              isLoading: state.isLoading,
                              // onPressed: _cancelRequest,
                              onPressed: () async {
                                final confirmed = await showConfirmDialog(
                                  context: context,
                                  title: 'Cancel request to join',
                                  message:
                                      'This will cancel your pending approval request. You cannot undo this action.',
                                );

                                if (confirmed == true) _cancelRequest();
                              },
                            ),
                          ),

                          SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlineAppButton(
                              text: 'Sign Out',
                              isLoading: state.isLoading,
                              onPressed: _signOut,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
