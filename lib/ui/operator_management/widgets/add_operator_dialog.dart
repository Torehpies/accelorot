import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog_shell.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/team_members_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/ui/operator_management/view_model/add_operator_notifier.dart';
import 'package:flutter_application_1/ui/core/ui/outline_app_button.dart';
import 'package:flutter_application_1/ui/core/ui/primary_button.dart';

class AddOperatorDialog extends ConsumerStatefulWidget {
  const AddOperatorDialog({super.key});
  @override
  ConsumerState<AddOperatorDialog> createState() => _AddOperatorDialogState();
}

class _AddOperatorDialogState extends ConsumerState<AddOperatorDialog> {
  final _formKey = GlobalKey<FormState>();
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  // Password visibility state
  bool _isPasswordVisible = false;
  // Tracks whether form fields have been modified
  bool isDirty = false;
  // Validators
  final emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Invalid email address';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    } else if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    super.dispose();
  }

  Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          OutlineAppButton(
            text: cancelText,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          PrimaryButton(
            onPressed: () => Navigator.of(context).pop(true),
            text: confirmText,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addOperatorProvider);
    // Listen for state updates
    ref.listen(addOperatorProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        if (next.operator != null) {
          if (context.mounted) {
            Navigator.of(context).pop();
            AppSnackbar.success(context, 'Operator added successfully!');
          }
        } else if (next.error != null) {
          AppSnackbar.error(context, next.error!);
        }
      }
    });
    return DialogShell(
      title: const Text(
        'Add Operator',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Fill in the details below to add a new operator."),
            const Divider(thickness: 1, height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // First Name Field
                  TextFormField(
                    controller: firstnameController,
                    decoration: InputDecoration(labelText: 'First Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'First Name is required' : null,
                    onChanged: (value) {
                      setState(() {
                        isDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Last Name Field
                  TextFormField(
                    controller: lastnameController,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Last Name is required' : null,
                    onChanged: (value) {
                      setState(() {
                        isDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Email Field
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => validateEmail(value ?? ''),
                    onChanged: (value) {
                      setState(() {
                        isDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password Field with Reveal Password
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) => validatePassword(value ?? ''),
                    onChanged: (value) {
                      setState(() {
                        isDirty = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (isDirty ||
                firstnameController.text.isNotEmpty ||
                lastnameController.text.isNotEmpty ||
                emailController.text.isNotEmpty ||
                passwordController.text.isNotEmpty) {
              final confirm = await showConfirmDialog(
                context: context,
                title: 'Unsaved Changes',
                message: 'Are you sure you want to discard your changes?',
              );
              if (confirm == true) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            } else {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: state.isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    final confirm = await showConfirmDialog(
                      context: context,
                      title: 'Submit Changes',
                      message: 'Are you sure you want to submit these changes?',
                    );
                    if (confirm == true) {
                      await ref
                          .read(addOperatorProvider.notifier)
                          .addOperator(
                            email: emailController.text,
                            password: passwordController.text,
                            firstname: firstnameController.text,
                            lastname: lastnameController.text,
                          )
                          .then((_) {
                            // Refresh Tabs
                            ref.read(teamMembersProvider.notifier).refresh();
                            // Refresh Summary Header
                            ref.invalidate(currentTeamProvider);
                          });
                    }
                  }
                },
          child: state.isLoading
              ? const CircularProgressIndicator(strokeWidth: 2)
              : const Text('Submit'),
        ),
      ],
    );
  }
}
