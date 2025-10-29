import 'package:flutter/material.dart';

class WebAddOperatorCard extends StatefulWidget {
  const WebAddOperatorCard({super.key});

  @override
  State<WebAddOperatorCard> createState() => _WebAddOperatorCardState();
}

class _WebAddOperatorCardState extends State<WebAddOperatorCard> {
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
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: Colors.teal),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.teal, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
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

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First Name is required')),
      );
      return;
    }

    if (lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Last Name is required')),
      );
      return;
    }

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username is required')),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email Address is required')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password is required')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Add your operator creation logic here
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Operator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Text(
            'Fill in the details to register a new operator',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          
          // First Name and Last Name Row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _firstNameController,
                  style: const TextStyle(color: Colors.teal),
                  cursorColor: Colors.teal,
                  decoration: _buildInputDecoration('First Name *'),
                  enabled: !_isSubmitting,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _lastNameController,
                  style: const TextStyle(color: Colors.teal),
                  cursorColor: Colors.teal,
                  decoration: _buildInputDecoration('Last Name *'),
                  enabled: !_isSubmitting,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _usernameController,
            style: const TextStyle(color: Colors.teal),
            cursorColor: Colors.teal,
            decoration: _buildInputDecoration('Username *'),
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.teal),
            cursorColor: Colors.teal,
            decoration: _buildInputDecoration('Email Address *'),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.teal),
            cursorColor: Colors.teal,
            decoration: _buildInputDecoration('Password *'),
            obscureText: true,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _confirmPasswordController,
            style: const TextStyle(color: Colors.teal),
            cursorColor: Colors.teal,
            decoration: _buildInputDecoration('Confirm Password *'),
            obscureText: true,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Add Operator'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}