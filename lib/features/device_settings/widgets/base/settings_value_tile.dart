// lib/features/device_settings/widgets/base/settings_value_tile.dart

import 'package:flutter/material.dart';

class SettingsValueTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool enabled;
  final String? subtitle;
  final Widget? customValue;

  const SettingsValueTile({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.enabled = true,
    this.subtitle,
    this.customValue,
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
            color: enabled ? Colors.black : Colors.grey,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            customValue ??
                Text(
                  value,
                  style: TextStyle(
                    color: enabled ? Colors.grey.shade600 : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: enabled ? Colors.grey : Colors.grey.shade300,
              ),
            ],
          ],
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}