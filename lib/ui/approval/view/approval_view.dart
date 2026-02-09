import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/ui/approval/view_model/approval_notifier.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_application_1/ui/core/ui/outline_app_button.dart';
import 'package:flutter_application_1/ui/core/ui/primary_button.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApprovalView extends ConsumerWidget {
  const ApprovalView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(approvalProvider);
    final notifier = ref.read(approvalProvider.notifier);
    final teamAsync = ref.watch(requestTeamProvider);
    final isAccepting = state.isAccepting;

    ref.listen(approvalProvider, (previous, next) {
      final message = next.message;
      if (message == null) return;
      message.when(
        success: (text) => AppSnackbar.success(context, text),
        error: (text) => AppSnackbar.error(context, text),
      );
    });

    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    final cardPadding = isDesktop
        ? const EdgeInsets.all(40.0)
        : const EdgeInsets.all(24.0);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: isDesktop ? 12 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: cardPadding,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 80,
                      color: AppColors.green100,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You have been added to this team:',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    teamAsync.when(
                      data: (team) => Text(
                        team.teamName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.green100,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      error: (error, stack) => Text(
                        'Unable to load team',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      loading: () => const CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 40),
                    PrimaryButton(
                      text: isAccepting ? 'Loading...' : 'Accept Invite',
                      onPressed: isAccepting ? null : notifier.accept,
                      isLoading: isAccepting,
                      enabled: !isAccepting,
                    ),
                    const SizedBox(height: 16),
                    OutlineAppButton(
                      onPressed: notifier.signOutAndNavigate,
                      text: 'Logout',
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
