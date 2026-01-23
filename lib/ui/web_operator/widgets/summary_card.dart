import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconForegroundColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.of(context).size.width >= kTabletBreakpoint &&
        MediaQuery.of(context).size.width < kDesktopBreakpoint;
    return Expanded(
      child: Tooltip(
        message: "$title: $value",
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.background2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WebColors.cardBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: WebColors.cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isTablet) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildTitle(), _buildIcon()],
                ),
              ],
              const SizedBox(height: 4),
              !isTablet
                  ? _buildValue()
                  : Row(
                      children: [
                        _buildTitle(),
                        SizedBox(width: 10),
                        _buildValue(),
                      ],
                    ),
              const SizedBox(height: 5),
              // const Divider(height: 1, color: WebColors.dividerLight),
              // const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: iconForegroundColor),
    );
  }

  Widget _buildValue() {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: WebColors.textHeading,
        height: 1.1,
      ),
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Text(
        title,
        style: TextStyle(
          color: WebColors.textLabel,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
