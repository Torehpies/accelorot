import 'package:flutter/material.dart';

/// OperatorDialogShell provides a reusable dialog scaffold for operator dialogs (add/edit/view/etc.)
///
/// Usage:
/// OperatorDialogShell(
///   title: Text('Dialog Title'),
///   content: Column(
///     children: [Text('Body')],
///   ),
///   actions: [TextButton(onPressed: ..., child: Text('Cancel'))],
/// )
class OperatorDialogShell extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final double width;
  final EdgeInsetsGeometry contentPadding;
  final Color? backgroundColor;

  const OperatorDialogShell({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.width = 400,
    this.contentPadding = const EdgeInsets.all(0),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor ?? Theme.of(context).dialogBackgroundColor,
      title: title,
      content: SizedBox(
        width: width,
        child: Padding(
          padding: contentPadding,
          child: content,
        ),
      ),
      actions: actions,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
