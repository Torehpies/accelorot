// lib/widgets/operator_error_state.dart

import 'package:flutter/material.dart';
import '../../utils/theme_constants.dart';

class OperatorErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const OperatorErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacing16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: ThemeConstants.spacing16),
            const Text(
              'Error loading operators:',
              style: TextStyle(
                fontSize: ThemeConstants.fontSize16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacing8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: ThemeConstants.fontSize12,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacing16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.tealShade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
