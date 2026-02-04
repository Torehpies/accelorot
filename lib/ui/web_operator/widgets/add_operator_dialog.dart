import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/add_operator_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddOperatorDialog extends ConsumerWidget {
  AddOperatorDialog({super.key});

  final _formKey = GlobalKey<FormState>();

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
    return null; // Valid
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
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch notifier state
    final state = ref.watch(addOperatorProvider);
    // Controllers
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final firstnameController = TextEditingController();
    final lastnameController = TextEditingController();
    return AlertDialog(
      title: const Text(
        'Add Operator',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: firstnameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) =>
                    value!.isEmpty ? 'First Name is required' : null,
              ),
              TextFormField(
                controller: lastnameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Last Name is required' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => validateEmail(value!),
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => validatePassword(value!),
              ),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: state.isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    await ref
                        .read(addOperatorProvider.notifier)
                        .addOperator(
                          email: emailController.text,
                          password: passwordController.text,
                          firstname: firstnameController.text,
                          lastname: lastnameController.text,
                        );
                    // Ensure the widget is still in the tree
                    if (context.mounted) {
                      if (state.operator != null) {
                        Navigator.of(context).pop();
                        AppSnackbar.success(
                          context,
                          'Operator added successfully!',
                        );
                      } else if (state.error != null) {
                        AppSnackbar.error(context, state.error!);
                      }
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
