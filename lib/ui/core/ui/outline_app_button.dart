import 'package:flutter/material.dart';

class OutlineAppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const OutlineAppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  bool get _isDisabled => isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _isDisabled ? null : onPressed,
      style: ButtonStyle(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: Colors.black26, width: 1.5);
          }
          if (states.contains(WidgetState.hovered)) {
            return const BorderSide(color: Colors.black12, width: 1.5);
          }
          return const BorderSide(color: Colors.black54, width: 1.5);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.black26;
          }
          if (states.contains(WidgetState.hovered)) {
            return Colors.white;
          }
          return Colors.black54;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.black54;
          }
          return Colors.transparent;
        }),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
