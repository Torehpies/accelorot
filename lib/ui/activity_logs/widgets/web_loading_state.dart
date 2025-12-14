// lib/ui/activity_logs/widgets/web_loading_state.dart

import 'package:flutter/material.dart';

/// A centered loading spinner widget
class WebLoadingState extends StatelessWidget {
  const WebLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.teal,
      ),
    );
  }
}