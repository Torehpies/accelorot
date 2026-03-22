// lib/ui/core/widgets/fields/name_email_input_fields.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_fields.dart';

// ── Formatters

// Strips disallowed characters char-by-char without touching the rest of the value.
class _NameCharsFormatter extends TextInputFormatter {
  static final _allowed = RegExp(r"[a-zA-ZÀ-ÖØ-öø-ÿ'\-. ]");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = newValue.text
        .split('')
        .where((c) => _allowed.hasMatch(c))
        .join();

    if (filtered == newValue.text) return newValue;

    final offset = filtered.length;
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

// Capitalizes the first letter of each word, lowercases the rest.
class CapitalizeWordsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final formatted = text.splitMapJoin(
      RegExp(r'\S+'),
      onMatch: (m) {
        final word = m[0]!;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      },
      onNonMatch: (n) => n,
    );

    final offset = newValue.selection.end.clamp(0, formatted.length);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

// ── Name input field

class NameInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  static String? validate(String value, {required String fieldLabel}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '$fieldLabel is required';
    if (!RegExp(r"[a-zA-ZÀ-ÖØ-öø-ÿ]").hasMatch(trimmed)) {
      return '$fieldLabel must contain at least one letter';
    }
    if (RegExp(r"^['\-.]|['\-.]$").hasMatch(trimmed)) {
      return '$fieldLabel cannot start or end with a special character';
    }
    return null;
  }

  const NameInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputField(
      label: label,
      controller: controller,
      hintText: hintText,
      errorText: errorText,
      enabled: enabled,
      required: true,
      inputFormatters: [
        _NameCharsFormatter(),
        CapitalizeWordsFormatter(),
      ],
      onChanged: onChanged,
    );
  }
}

// ── Email input field

class EmailInputField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? submitError;

  const EmailInputField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onChanged,
    this.submitError,
  });

  static final emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  static bool isValid(String value) => emailRegex.hasMatch(value.trim());

  @override
  State<EmailInputField> createState() => _EmailInputFieldState();
}

class _EmailInputFieldState extends State<EmailInputField> {
  bool _touched = false;
  String? _liveHint;

  String? _computeHint(String value) {
    if (value.isEmpty) return null;
    if (!value.contains('@')) return 'Missing @ symbol';
    final parts = value.split('@');
    if (parts[0].isEmpty) return 'Enter the part before @';
    if (parts.length < 2 || parts[1].isEmpty) return 'Enter a domain after @';
    if (!parts[1].contains('.')) return 'Domain needs a dot (e.g. gmail.com)';
    final tld = parts[1].split('.').last;
    if (tld.length < 2) return 'Enter a valid domain ending (e.g. .com)';
    if (!EmailInputField.emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final errorText = _touched ? _liveHint : widget.submitError;

    return InputField(
      label: 'Email',
      controller: widget.controller,
      hintText: 'Enter email address',
      errorText: errorText,
      enabled: widget.enabled,
      required: true,
      keyboardType: TextInputType.emailAddress,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      onChanged: (value) {
        setState(() {
          _touched = true;
          _liveHint = _computeHint(value);
        });
        widget.onChanged?.call(value);
      },
    );
  }
}