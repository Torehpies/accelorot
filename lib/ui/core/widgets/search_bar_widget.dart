// lib/ui/core/widgets/search_bar_widget.dart
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../themes/app_text_styles.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;
  final FocusNode focusNode;
  final String hintText;
  final double height;
  final double borderRadius;
  final double iconSize;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    required this.onClear,
    required this.focusNode,
    this.hintText = 'Search....',
    this.height = 40,
    this.borderRadius = 12,
    this.iconSize = 20,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild for clear button
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear();
    widget.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.focusNode,
      builder: (context, child) {
        final hasFocus = widget.focusNode.hasFocus;
        final borderColor = hasFocus ? AppColors.green100 : AppColors.grey;
        final borderWidth = hasFocus ? 2.0 : 1.5;
        
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.background2,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: TextField(
            controller: _controller,
            focusNode: widget.focusNode,
            onChanged: widget.onSearchChanged,
            style: AppTextStyles.input,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTextStyles.hint,
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: widget.iconSize,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppColors.textSecondary,
                        size: widget.iconSize,
                      ),
                      onPressed: _clearSearch,
                      padding: EdgeInsets.zero,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              isDense: true,
            ),
          ),
        );
      },
    );
  }
}