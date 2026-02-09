import 'package:flutter/material.dart';

class SecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final double? width;
  final double? height;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
    this.icon,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _isHovered = false;

  bool get _isDisabled => !widget.enabled || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    // Standardized dimensions matching PrimaryButton
    final buttonHeight = widget.height ?? (isMobile ? 48.0 : 56.0);
    final buttonWidth = widget.width;

    return MouseRegion(
      cursor: _isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) {
        if (!_isDisabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (!_isDisabled) setState(() => _isHovered = false);
      },
      child: AnimatedScale(
        scale: _isHovered && !_isDisabled ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isDisabled
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isHovered ? 0.3 : 0.25),
                      blurRadius: _isHovered ? 12 : 8,
                      offset: Offset(0, _isHovered ? 3 : 2),
                    ),
                  ],
          ),
          child: OutlinedButton(
            onPressed: _isDisabled ? null : widget.onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              side: BorderSide(
                color: _isDisabled 
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.white,
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : widget.icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(widget.icon, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}