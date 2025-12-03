import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String labelText;
  final bool autoFocus;
	final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    required this.controller,
    this.keyboardType,
    this.validator,
    required this.labelText,
    this.autoFocus = false,
    this.textInputAction, this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
			onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
      autofocus: autoFocus,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      validator: validator,
      style: TextStyle(color: AppColors.textPrimary),
    );
  }
}
