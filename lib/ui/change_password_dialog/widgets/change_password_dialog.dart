import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'change_password_dialog.g.dart';

@riverpod
class PasswordResetDialogNotifier extends _$PasswordResetDialogNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> sendResetEmail(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(authRepositoryProvider)
          .sendPasswordResetEmail(email);
      if (!result['success']) throw Exception(result['message']);
      return;
    });
  }
}

class ChangePasswordDialog {
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ChangePasswordDialog(),
    );
  }
}

class _ChangePasswordDialog extends ConsumerWidget {
  const _ChangePasswordDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserAsync = ref.watch(authUserProvider);
    final passwordResetAsync = ref.watch(passwordResetDialogProvider);
    final notifier = ref.read(passwordResetDialogProvider.notifier);

    ref.listen(passwordResetDialogProvider, (prev, next) {
      next.whenData((_) {
        if (context.mounted) {
          final userEmail = authUserAsync.value?.email;
          if (userEmail != null && context.mounted) {
            _showSuccessDialog(context, userEmail);
          }
        }
      });
    });

    return authUserAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorDialog(
        error: e.toString(),
        onRetry: () => ref.invalidate(authUserProvider),
      ),
      data: (user) {
        if (user == null || user.email == null) {
          return _NoUserDialog(onClose: () => Navigator.pop(context));
        }

        return passwordResetAsync.when(
          data: (_) => _ChangePasswordConfirmationDialog(
            email: user.email!,
            isLoading: false,
            onConfirm: () => notifier.sendResetEmail(user.email!),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorDialog(error: e.toString()),
        );
      },
    );
  }

  static Future<void> _showSuccessDialog(BuildContext context, String email) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        // Your existing success dialog content
        title: const Text('Email Sent!'),
        content: Text('Reset link sent to $email'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close success
              Navigator.pop(context); // Close main dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Keep your existing _ChangePasswordConfirmationDialog, _ErrorDialog, _NoUserDialog
class _ChangePasswordConfirmationDialog extends StatelessWidget {
  final String email;
  final VoidCallback onConfirm;
  final bool isLoading;

  const _ChangePasswordConfirmationDialog({
    required this.email,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
 title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Send reset link to:', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(email, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Check your inbox for the link.', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: isLoading ? null : onConfirm,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: Text(isLoading ? 'Sending...' : 'Send Email'),
        ),
      ],
    );
  }
}

class _ErrorDialog extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const _ErrorDialog({required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      content: Text(error, style: TextStyle(color: Colors.grey[700])),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
      ],
    );
  }
}

class _NoUserDialog extends StatelessWidget {
  final VoidCallback onClose;

  const _NoUserDialog({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('No User'),
      content: const Text('Please sign in to reset password.'),
      actions: [TextButton(onPressed: onClose, child: const Text('OK'))],
    );
  }
}
