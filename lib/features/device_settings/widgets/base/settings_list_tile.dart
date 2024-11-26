// lib/features/device_settings/widgets/base/settings_list_tile.dart

import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? trailing;
  final Color? textColor;
  final bool showChevron;

  const SettingsListTile({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.enabled = true,
    this.trailing,
    this.textColor,
    this.showChevron = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            icon,
            color: enabled ? iconColor : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: textColor ?? (enabled ? Colors.black : Colors.grey),
            fontWeight: FontWeight.w400,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle!,
          style: TextStyle(
            color: enabled ? Colors.grey : Colors.grey.shade400,
          ),
        )
            : null,
        trailing: trailing ??
            (showChevron && onTap != null
                ? Icon(
              Icons.chevron_right,
              color: enabled ? Colors.grey : Colors.grey.shade300,
            )
                : null),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}