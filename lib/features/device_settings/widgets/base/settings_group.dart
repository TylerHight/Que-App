// lib/features/device_settings/widgets/base/settings_group.dart

import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final bool enabled;
  final VoidCallback? onTap;
  final Color? accentColor;
  final String? subtitle;

  const SettingsGroup({
    Key? key,
    this.title,
    required this.children,
    this.enabled = true,
    this.onTap,
    this.accentColor,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: accentColor != null
              ? BorderSide(color: accentColor!, width: 1.0)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 18,
                      color: accentColor ?? Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.sync_disabled,
                          size: 14,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8.0),
                ],
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}