// lib/ui/core/widgets/search_bar_widget.dart
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../themes/app_text_styles.dart';

/// Improved search bar widget with consistent sizing and theming
/// 
/// Features:
/// - Configurable height (default 40px)
/// - Clear button with proper callbacks
/// - Focus management with visual feedback
/// - External state synchronization via initialValue
/// - Uses AppTextStyles for consistent typography
/// - Aligned with app design system
class SearchBarWidget extends StatefulWidget {
  /// Callback fired when search text changes
  final ValueChanged<String> onSearchChanged;
  
  /// Callback fired when clear button is pressed
  final VoidCallback onClear;
  
  /// Focus node for keyboard and focus management
  final FocusNode focusNode;
  
  /// Initial value to populate the search field
  /// Used for syncing with external state
  final String? initialValue;
  
  // Styling parameters (aligned with AppColors)
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? iconColor;
  final Color? hintColor;
  final Color? textColor;
  
  // Size parameters (configurable with defaults)
  final double height;
  final double borderRadius;
  final double iconSize;
  final EdgeInsetsGeometry? contentPadding;
  
  // Text parameters
  final String hintText;
  
  // Behavior parameters
  final bool enabled;
  final bool autofocus;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final int? maxLength;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    required this.onClear,
    required this.focusNode,
    this.initialValue,
    // Styling - defaults use AppColors
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.iconColor,
    this.hintColor,
    this.textColor,
    // Sizes (with defaults matching design system)
    this.height = 40,
    this.borderRadius = 12,
    this.iconSize = 20,
    this.contentPadding,
    // Text
    this.hintText = 'Search....',
    // Behavior
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
    this.onSubmitted,
    this.maxLength,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Sync external state changes
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Rebuild to show/hide clear button
    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear();
    widget.onSearchChanged('');
    widget.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = widget.focusNode.hasFocus;
    
    // Default colors aligned with AppColors
    final bgColor = widget.backgroundColor ?? AppColors.background2;
    final defaultBorderColor = widget.borderColor ?? AppColors.grey;
    final defaultFocusedBorderColor = widget.focusedBorderColor ?? AppColors.green100;
    final defaultIconColor = widget.iconColor ?? AppColors.textSecondary;
    final defaultHintColor = widget.hintColor ?? AppColors.textSecondary;
    final defaultTextColor = widget.textColor ?? AppColors.textPrimary;
    
    // Dynamic border color based on focus
    final currentBorderColor = hasFocus ? defaultFocusedBorderColor : defaultBorderColor;
    final borderWidth = hasFocus ? 2.0 : 1.0;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: currentBorderColor,
          width: borderWidth,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        maxLength: widget.maxLength,
        textInputAction: widget.textInputAction,
        // Use AppTextStyles.searchText with color override if needed
        style: AppTextStyles.searchText.copyWith(
          color: defaultTextColor,
        ),
        onChanged: widget.onSearchChanged,
        onSubmitted: widget.onSubmitted != null 
            ? (_) => widget.onSubmitted!() 
            : null,
        decoration: InputDecoration(
          hintText: widget.hintText,
          // Use AppTextStyles.hintText with color override if needed
          hintStyle: AppTextStyles.hintText.copyWith(
            color: defaultHintColor,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: hasFocus ? defaultFocusedBorderColor : defaultIconColor,
            size: widget.iconSize,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: defaultIconColor,
                    size: widget.iconSize,
                  ),
                  onPressed: _clearSearch,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                )
              : null,
          border: InputBorder.none,
          counterText: '', // Hide character counter if maxLength is set
          contentPadding: widget.contentPadding ?? 
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
        ),
      ),
    );
  }
}