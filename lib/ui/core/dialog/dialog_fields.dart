// lib/ui/core/dialog/dialog_fields.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/web_text_styles.dart';
import '../themes/web_colors.dart';
import '../toast/toast_service.dart';

// ==================== READ ONLY ====================

/// Single read-only field displaying label-value pair (side-by-side)
class ReadOnlyField extends StatefulWidget {
  final String label;
  final String value;
  final String emptyText;

  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.emptyText = "—",
  });

  @override
  State<ReadOnlyField> createState() => _ReadOnlyFieldState();
}

class _ReadOnlyFieldState extends State<ReadOnlyField> {
  bool _isHovered = false;
  bool _showCopyIcon = false;

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    // Delay before showing copy icon
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isHovered && mounted) {
        setState(() => _showCopyIcon = true);
      }
    });
  }

  void _onHoverExit() {
    setState(() {
      _isHovered = false;
      _showCopyIcon = false;
    });
  }

  void _copyToClipboard() {
    if (widget.value.isEmpty) return;

    Clipboard.setData(ClipboardData(text: widget.value));
    ToastService.show(context, message: 'Copied!');
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = widget.value.isEmpty ? widget.emptyText : widget.value;
    final isEmptyValue = widget.value.isEmpty;

    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: GestureDetector(
        onTap: !isEmptyValue ? _copyToClipboard : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: _isHovered ? WebColors.badgeBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label (left-aligned)
              Flexible(
                flex: 2,
                child: Text(widget.label, style: WebTextStyles.bodyMediumGray),
              ),
              const SizedBox(width: 16),
              // Value (right-aligned) with optional copy indicator
              Flexible(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        displayValue,
                        style: WebTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isEmptyValue
                              ? WebColors.textMuted
                              : WebColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    if (_showCopyIcon && !isEmptyValue) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.content_copy,
                        size: 14,
                        color: WebColors.textLabel,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Read-only field with label on top and value below (for long text like descriptions)
class ReadOnlyMultilineField extends StatefulWidget {
  final String label;
  final String value;
  final String emptyText;

  const ReadOnlyMultilineField({
    super.key,
    required this.label,
    required this.value,
    this.emptyText = "—",
  });

  @override
  State<ReadOnlyMultilineField> createState() => _ReadOnlyMultilineFieldState();
}

class _ReadOnlyMultilineFieldState extends State<ReadOnlyMultilineField> {
  bool _isHovered = false;
  bool _showCopyIcon = false;

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    // Delay before showing copy icon
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isHovered && mounted) {
        setState(() => _showCopyIcon = true);
      }
    });
  }

  void _onHoverExit() {
    setState(() {
      _isHovered = false;
      _showCopyIcon = false;
    });
  }

  void _copyToClipboard() {
    if (widget.value.isEmpty) return;

    Clipboard.setData(ClipboardData(text: widget.value));
    ToastService.show(context, message: 'Copied!');
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = widget.value.isEmpty ? widget.emptyText : widget.value;
    final isEmptyValue = widget.value.isEmpty;

    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: GestureDetector(
        onTap: !isEmptyValue ? _copyToClipboard : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: _isHovered ? WebColors.badgeBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.label, style: WebTextStyles.bodyMediumGray),
                  if (_showCopyIcon && !isEmptyValue) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.content_copy,
                      size: 14,
                      color: WebColors.textLabel,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Value
              Text(
                displayValue,
                style: WebTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isEmptyValue
                      ? WebColors.textMuted
                      : WebColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gray container section for displaying multiple read-only fields
class ReadOnlySection extends StatelessWidget {
  final List<Widget> fields;
  final String? sectionTitle;

  const ReadOnlySection({super.key, required this.fields, this.sectionTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebColors.badgeBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sectionTitle != null) ...[
            Text(
              sectionTitle!,
              style: WebTextStyles.label.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...fields,
        ],
      ),
    );
  }
}

// ==================== INPUT FIELDS ====================

/// Reusable input field for dialogs - matches mobile design
class InputField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool required;
  final int maxLines;
  final int? maxLength;
  final bool showCounter;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final String? suffix;
  final ValueChanged<String>? onChanged;

  const InputField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.required = false,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = true,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: WebTextStyles.body,
      decoration: InputDecoration(
        // Floating label with required indicator
        label: RichText(
          text: TextSpan(
            text: label,
            style: WebTextStyles.label.copyWith(color: WebColors.textLabel),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: WebColors.error),
                ),
            ],
          ),
        ),
        hintText: hintText,
        hintStyle: WebTextStyles.bodyMediumGray,
        errorText: errorText,
        helperText: helperText,
        helperStyle: WebTextStyles.caption.copyWith(
          color: WebColors.textLabel,
        ),
        prefixIcon: prefixIcon,
        suffixText: suffix,
        suffixStyle: WebTextStyles.body.copyWith(
          color: WebColors.textLabel,
        ),
        // Disabled state fill
        filled: !enabled,
        fillColor: enabled ? null : WebColors.inputBackground,
        counterText: (maxLength != null && showCounter) ? null : '',
        counterStyle: WebTextStyles.caption.copyWith(
          color: WebColors.textMuted,
        ),
        // Rounded borders (matching mobile design)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: WebColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: WebColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.greens, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

/// Dropdown field matching InputField design
class DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownItem<T>> items;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool required;
  final ValueChanged<T?>? onChanged;

  const DropdownField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.hintText,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.required = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        // Floating label with required indicator
        label: RichText(
          text: TextSpan(
            text: label,
            style: WebTextStyles.label.copyWith(color: WebColors.textLabel),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: WebColors.error),
                ),
            ],
          ),
        ),
        hintText: hintText,
        hintStyle: WebTextStyles.bodyMediumGray,
        errorText: errorText,
        helperText: helperText,
        helperStyle: WebTextStyles.caption.copyWith(
          color: WebColors.textLabel,
        ),
        // Disabled state fill
        filled: !enabled,
        fillColor: enabled ? null : WebColors.inputBackground,
        // Rounded borders (matching mobile design)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: WebColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: WebColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.greens, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      hint: hintText != null
          ? Text(hintText!, style: WebTextStyles.bodyMediumGray)
          : null,
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item.value,
          child: Text(item.label, style: WebTextStyles.body),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      style: WebTextStyles.body,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: enabled ? WebColors.textLabel : WebColors.iconDisabled,
      ),
    );
  }
}

/// Model for dropdown items
class DropdownItem<T> {
  final T value;
  final String label;

  const DropdownItem({required this.value, required this.label});
}

/// Date picker field matching InputField design
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool required;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?>? onChanged;
  final String dateFormat;

  const DatePickerField({
    super.key,
    required this.label,
    this.selectedDate,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.required = false,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.dateFormat = 'MMM dd, yyyy',
  });

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: WebColors.greens,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: WebColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && onChanged != null) {
      onChanged!(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      enabled: enabled,
      onTap: enabled ? () => _selectDate(context) : null,
      style: WebTextStyles.body,
      decoration: InputDecoration(
        // Floating label with required indicator
        label: RichText(
          text: TextSpan(
            text: label,
            style: WebTextStyles.label.copyWith(color: WebColors.textLabel),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: WebColors.error),
                ),
            ],
          ),
        ),
        hintText: 'Select date',
        hintStyle: WebTextStyles.bodyMediumGray,
        errorText: errorText,
        helperText: helperText,
        helperStyle: WebTextStyles.caption.copyWith(
          color: WebColors.textLabel,
        ),
        suffixIcon: Icon(
          Icons.calendar_today,
          size: 18,
          color: enabled ? WebColors.textLabel : WebColors.iconDisabled,
        ),
        // Disabled state fill
        filled: !enabled,
        fillColor: enabled ? null : WebColors.inputBackground,
        // Rounded borders (matching mobile design)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: WebColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: WebColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.greens, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      controller: TextEditingController(
        text: selectedDate != null ? _formatDate(selectedDate!) : '',
      ),
    );
  }
}

/// Number stepper field for quantities
class NumberStepperField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final int decimalPlaces;
  final String? unit;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool required;
  final ValueChanged<double>? onChanged;

  const NumberStepperField({
    super.key,
    required this.label,
    required this.value,
    this.min = 0,
    this.max = 999999,
    this.step = 1,
    this.decimalPlaces = 0,
    this.unit,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.required = false,
    this.onChanged,
  });

  void _increment() {
    if (value + step <= max && onChanged != null) {
      onChanged!(value + step);
    }
  }

  void _decrement() {
    if (value - step >= min && onChanged != null) {
      onChanged!(value - step);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = value.toStringAsFixed(decimalPlaces);
    final canIncrement = value + step <= max;
    final canDecrement = value - step >= min;
    final labelText = required ? '$label *' : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (label.isNotEmpty) ...[
          Text(
            labelText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
        ],

        // Stepper field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: enabled ? Colors.white : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: errorText != null 
                      ? Theme.of(context).colorScheme.error
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  // Decrement button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: enabled && canDecrement ? _decrement : null,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.remove,
                          size: 18,
                          color: enabled && canDecrement
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),

                  // Value display
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        unit != null ? '$displayValue $unit' : displayValue,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Increment button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: enabled && canIncrement ? _increment : null,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: enabled && canIncrement
                              ? Colors.grey.shade700
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  errorText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            if (helperText != null && errorText == null)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Text(
                  helperText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Toggle/Switch field for boolean values
class ToggleField extends StatelessWidget {
  final String label;
  final bool value;
  final String? description;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  const ToggleField({
    super.key,
    required this.label,
    required this.value,
    this.description,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Switch
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ],
    );
  }
}