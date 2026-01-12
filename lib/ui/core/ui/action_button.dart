
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isAccept;

  const ActionButton.accept({super.key, required this.onPressed}) : isAccept = true;
  const ActionButton.decline({super.key, required this.onPressed}) : isAccept = false;

  @override
  Widget build(BuildContext context) {
    return isAccept
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onPressed,
            child: const Text('Accept', style: TextStyle(fontSize: 13)),
          )
        : OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade100),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onPressed,
            child: const Text('Decline', style: TextStyle(fontSize: 13)),
          );
  }
}
