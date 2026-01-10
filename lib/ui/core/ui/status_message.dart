import 'package:flutter/material.dart';

class StatusMessage extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback? onRetry;

  const StatusMessage({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.onRetry,
  });

  factory StatusMessage.empty({
    String title = 'Nothing here yet.',
    String? description,
  }) {
    return StatusMessage(
      title: title,
      icon: Icons.inbox,
      description: description,
    );
  }

  factory StatusMessage.error({
    String title = 'Something went wrong',
    String? description,
    VoidCallback? onRetry,
  }) {
    return StatusMessage(
      title: title,
      icon: Icons.error_outline,
      description: description,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
