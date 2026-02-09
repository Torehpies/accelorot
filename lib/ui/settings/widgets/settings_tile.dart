import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final TextStyle? subtitleStyle;
  final TextStyle? titleStyle;
  final double? iconSize;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.subtitleStyle,
    this.titleStyle,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = onTap != null;
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF4CAF50),
        size: iconSize,
      ),
      title: Text(title, style: titleStyle),
      subtitle: subtitle != null
          ? Text(subtitle!, style: subtitleStyle)
          : null,
      trailing: trailing ??
          (isInteractive
              ? IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: onTap,
                  splashRadius: 18,
                )
              : null),
      onTap: null,
      mouseCursor: SystemMouseCursors.basic,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF4CAF50),
      ),
    );
  }
}
