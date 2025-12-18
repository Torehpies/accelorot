// lib/ui/core/widgets/table/table_cell.dart

import 'package:flutter/material.dart';

/// A generic wrapper for table cells to maintain flex alignment
class TableCellWidget extends StatelessWidget {
  final int flex;
  final Widget child;
  final Alignment alignment;
  final EdgeInsets? padding;

  const TableCellWidget({
    super.key,
    required this.flex,
    required this.child,
    this.alignment = Alignment.center,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: padding,
        alignment: alignment,
        child: child,
      ),
    );
  }
}
