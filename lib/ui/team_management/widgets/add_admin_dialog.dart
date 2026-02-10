import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog_shell.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_application_1/ui/team_management/view_model/add_admin_notifier.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_detail_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddAdminDialog extends ConsumerStatefulWidget {
  final String teamId;

  const AddAdminDialog({super.key, required this.teamId});

  @override
  ConsumerState<AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends ConsumerState<AddAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  // final passwordController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  // bool _isPasswordVisible = false;
  bool isDirty = false;

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
    // passwordController.dispose();
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
          TextButton(
            child: Text(cancelText),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text(confirmText),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addAdminProvider);
    ref.listen(addAdminProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        if (next.admin != null) {
          if (context.mounted) {
            Navigator.of(context).pop();
            AppSnackbar.success(context, 'Admin added successfully!');
          }
        } else if (next.error != null) {
          AppSnackbar.error(context, next.error!);
        }
      }
    });
    return DialogShell(
      title: const Text(
        'Add Admin',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Fill in the details below to add a new admin."),
            const Divider(thickness: 1, height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: firstnameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'First Name is required'
                        : null,
                    onChanged: (_) => setState(() {
                      isDirty = true;
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: lastnameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Last Name is required'
                        : null,
                    onChanged: (_) => setState(() {
                      isDirty = true;
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => validateEmail(value ?? ''),
                    onChanged: (_) => setState(() {
                      isDirty = true;
                    }),
                  ),
                  // const SizedBox(height: 16),
                  // TextFormField(
                  //   controller: passwordController,
                  //   decoration: InputDecoration(
                  //     labelText: 'Password',
                  //     suffixIcon: IconButton(
                  //       onPressed: () => setState(() {
                  //         _isPasswordVisible = !_isPasswordVisible;
                  //       }),
                  //       icon: Icon(
                  //         _isPasswordVisible
                  //             ? Icons.visibility
                  //             : Icons.visibility_off,
                  //         color: Colors.grey,
                  //       ),
                  //     ),
                  //   ),
                  //   obscureText: !_isPasswordVisible,
                  //   validator: (value) => validatePassword(value ?? ''),
                  //   onChanged: (_) => setState(() {
                  //     isDirty = true;
                  //   }),
                  // ),
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
                emailController.text.isNotEmpty
            // passwordController.text.isNotEmpty
            ) {
              final confirm = await showConfirmDialog(
                context: context,
                title: 'Unsaved Changes',
                message: 'Are you sure you want to discard your changes?',
              );
              if (confirm == true && context.mounted) {
                Navigator.of(context).pop();
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
                          .read(addAdminProvider.notifier)
                          .addAdmin(
                            email: emailController.text,
                            // password: passwordController.text,
                            firstname: firstnameController.text,
                            lastname: lastnameController.text,
                            teamId: widget.teamId,
                          )
                          .then((_) {
                            // Refresh admin/member list providers
                            ref
                                .read(
                                  teamDetailProvider(widget.teamId).notifier,
                                )
                                .refresh();
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
