import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../operator_management/view_model/add_operator_view_model.dart';

class AddOperatorView extends StatelessWidget {
  const AddOperatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddOperatorViewModel(),
      child: Consumer<AddOperatorViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Operator',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Fill in the details to register a new operator',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                hint: 'Enter First Name',
                                label: 'First Name *',
                                onChanged: vm.updateFirstName,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                hint: 'Enter Last Name',
                                label: 'Last Name *',
                                onChanged: vm.updateLastName,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          hint: 'Enter Username',
                          label: 'Username *',
                          onChanged: vm.updateUsername,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          hint: 'Enter Email Address',
                          label: 'Email Address *',
                          onChanged: vm.updateEmail,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          hint: 'Enter Password',
                          label: 'Password *',
                          obscure: true,
                          onChanged: vm.updatePassword,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          hint: 'Confirm Password',
                          label: 'Confirm Password *',
                          obscure: true,
                          onChanged: vm.updateConfirmPassword,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: vm.isValid && !vm.loading
                                ? () async {
                                    await vm.addOperator();
                                    if (context.mounted && vm.error == null) {
                                      Navigator.pop(context);
                                    }
                                  }
                                : null,
                            child: vm.loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Add Operator'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required Function(String) onChanged,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 13,
            ),
            children: [
              TextSpan(text: label.replaceAll(' *', '')),
              if (label.contains('*'))
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          onChanged: onChanged,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}