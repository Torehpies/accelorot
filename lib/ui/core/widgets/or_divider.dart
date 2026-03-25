import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(thickness: 1, color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text('or continue with', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider(thickness: 1, color: Colors.grey)),
      ],
    );
  }
}
