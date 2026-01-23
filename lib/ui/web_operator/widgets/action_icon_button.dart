import 'package:flutter/material.dart';

Widget actionIconButton({
  required IconData icon,
  required String tooltip,
  required VoidCallback onPressed,
}) {
  return Tooltip(
    message: tooltip,
    child: SizedBox.square(
      dimension: 32,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 24,
            color: Colors.grey[700],
          ),
        ),
      ),
    ),
  );
}
