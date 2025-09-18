// lib/widgets/role_dropdown.dart
import 'package:flutter/material.dart';

class RoleDropdown extends StatelessWidget {
  final ValueChanged<String?>? onChanged;
  final String? value;

  const RoleDropdown({Key? key, this.onChanged, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          labelText: 'Select Role',
          prefixIcon: Icon(Icons.account_circle, color: Colors.grey),
          border: OutlineInputBorder(),
        ),
        items: ['User', 'Admin'].map((String role) {
          return DropdownMenuItem<String>(
            value: role,
            child: Text(role),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select a role' : null,
      ),
    );
  }
}