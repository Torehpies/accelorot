// lib/ui/web_operator/widgets/add_operator_screen.dart

import 'package:flutter/material.dart';
import '../../core/ui/theme_constants.dart';

class AddOperatorScreen extends StatefulWidget {
  const AddOperatorScreen({super.key});

  @override
  State<AddOperatorScreen> createState() => _AddOperatorScreenState();
}

class _AddOperatorScreenState extends State<AddOperatorScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: ThemeConstants.greyShade600),
      floatingLabelStyle: TextStyle(color: ThemeConstants.tealShade600),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ThemeConstants.tealShade600, width: 2),
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ThemeConstants.greyShade300, width: 1),
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius8),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (firstName.isEmpty) {
      _showError('First Name is required');
      return;
    }
    if (lastName.isEmpty) {
      _showError('Last Name is required');
      return;
    }
    if (username.isEmpty) {
      _showError('Username is required');
      return;
    }
    if (email.isEmpty) {
      _showError('Email Address is required');
      return;
    }
    if (password.isEmpty) {
      _showError('Password is required');
      return;
    }
    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Operator "$firstName $lastName" added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add operator: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius24),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          ThemeConstants.spacing20,
          ThemeConstants.spacing20,
          ThemeConstants.spacing20,
          MediaQuery.of(context).viewInsets.bottom + ThemeConstants.spacing20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Operator',
              style: TextStyle(
                fontSize: ThemeConstants.fontSize20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Fill in the details to register a new operator',
              style: TextStyle(color: ThemeConstants.greyShade600),
            ),
            const SizedBox(height: ThemeConstants.spacing20),

            // First Name and Last Name Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    style: TextStyle(color: ThemeConstants.tealShade600),
                    cursorColor: ThemeConstants.tealShade600,
                    decoration: _buildInputDecoration('First Name *'),
                    enabled: !_isSubmitting,
                  ),
                ),
                const SizedBox(width: ThemeConstants.spacing12),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    style: TextStyle(color: ThemeConstants.tealShade600),
                    cursorColor: ThemeConstants.tealShade600,
                    decoration: _buildInputDecoration('Last Name *'),
                    enabled: !_isSubmitting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacing16),

            TextField(
              controller: _usernameController,
              style: TextStyle(color: ThemeConstants.tealShade600),
              cursorColor: ThemeConstants.tealShade600,
              decoration: _buildInputDecoration('Username *'),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: ThemeConstants.spacing16),

            TextField(
              controller: _emailController,
              style: TextStyle(color: ThemeConstants.tealShade600),
              cursorColor: ThemeConstants.tealShade600,
              decoration: _buildInputDecoration('Email Address *'),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: ThemeConstants.spacing16),

            TextField(
              controller: _passwordController,
              style: TextStyle(color: ThemeConstants.tealShade600),
              cursorColor: ThemeConstants.tealShade600,
              decoration: _buildInputDecoration('Password *'),
              obscureText: true,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: ThemeConstants.spacing16),

            TextField(
              controller: _confirmPasswordController,
              style: TextStyle(color: ThemeConstants.tealShade600),
              cursorColor: ThemeConstants.tealShade600,
              decoration: _buildInputDecoration('Confirm Password *'),
              obscureText: true,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: ThemeConstants.spacing24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.greyShade300,
                      foregroundColor: ThemeConstants.tealShade600,
                      padding: const EdgeInsets.symmetric(
                        vertical: ThemeConstants.spacing16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ThemeConstants.borderRadius8,
                        ),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: ThemeConstants.spacing12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.tealShade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: ThemeConstants.spacing16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ThemeConstants.borderRadius8,
                        ),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Add Operator'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConstants.spacing16),
          ],
        ),
      ),
    );
  }
}