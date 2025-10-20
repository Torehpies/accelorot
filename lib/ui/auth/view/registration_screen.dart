import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/input_decoration.dart';
import 'package:flutter_application_1/utils/snackbar_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/ui/auth/view_model/auth_view_model.dart';
import 'package:go_router/go_router.dart';

class RefactoredRegistrationScreen extends ConsumerStatefulWidget {
  const RefactoredRegistrationScreen({super.key});

  @override
  ConsumerState<RefactoredRegistrationScreen> createState() =>
      _RegistrationScreenState();
}

class _RegistrationScreenState
    extends ConsumerState<RefactoredRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final bool _obscurePassword = true;
  final bool _obscureConfirmPassword = true;

  void _onCreateAccountPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    await ref
        .read(authViewModelProvider.notifier)
        .register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          fullName,
        );

    final state = ref.read(authViewModelProvider);

    if (!mounted) return;

    state.when(
      data: (_) => showSnackbar('Registered successfully!'),
      loading: () {},
      error: (error, _) => showSnackbar(error.toString(), isError: true),
    );
  }

  void _onGoogleSignInPressed() async {
    try {
      // await ref.read(authViewModelProvider.notifier).signInWithGoogle();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google Signed In')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(authViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo
                    const SizedBox(height: 16),
                    const Icon(Icons.person_add, size: 80, color: Colors.teal),
                    const SizedBox(height: 16),

                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    Text(
                      'Join us to get started',
                      style: TextStyle(fontSize: 16, color: theme.hintColor),
                    ),
                    const SizedBox(height: 10),

                    // First Name and Last Name Row
                    Row(
                      children: [
                        // First Name Field
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            textInputAction: TextInputAction.next,
                            decoration: inputDecoration('First Name'),
                            validator: (value) => value == null || value.isEmpty
                                ? 'First name is required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Last Name Field
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            textInputAction: TextInputAction.next,
                            decoration: inputDecoration('Last Name'),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Last name is required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: inputDecoration('Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: inputDecoration('Password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: inputDecoration('Confirm Password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Register Button
                    registerState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _onCreateAccountPressed,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text('Create Account'),
                          ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'or continue with',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: () async {
                        try {
                          _onGoogleSignInPressed();
                        } catch (e) {
                          showSnackbar('Error $e', isError: true);
                        }
                      },
                      child: Image.asset(
                        'assets/icons/Google_logo.png',
                        height: 48,
                        width: 48,
                      ),
                    ),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text(
                            "Sign in",
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
