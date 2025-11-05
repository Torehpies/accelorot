import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onClear;
  final FocusNode? focusNode;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    required this.onClear,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      onChanged: onSearchChanged,
      style: const TextStyle(
        fontSize: 13, // 🟢 smaller text
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.search_rounded, // 🟢 visible rounded search icon
          size: 18,
          color: Colors.teal, // 🟢 clearly visible teal icon
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.close_rounded, // 🟢 visible rounded close icon
            size: 18,
            color: Colors.teal,
          ),
          onPressed: onClear,
        ),
        hintText: 'Search here...',
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
        isDense: true, // 🟢 compact height
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 1.2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
