import 'package:flutter/material.dart';

class RegisterFieldBox extends StatelessWidget {
  const RegisterFieldBox({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: child,
    );
  }
}
