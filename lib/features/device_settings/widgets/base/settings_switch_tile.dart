// lib/features/device_settings/widgets/base/settings_switch_tile.dart

import 'package:flutter/material.dart';

class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final Color iconColor;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const SettingsSwitchTile({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.iconColor,
    this.onChanged,
    this.enabled = true,
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
            color: enabled
                ? (value ? iconColor : Colors.grey)
                : Colors.grey.shade300,
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
        trailing: Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: iconColor,
        ),
      ),
    );
  }
}