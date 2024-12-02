// lib/features/device_control/widgets/connection_indicator.dart

import 'package:flutter/material.dart';

class ConnectionIndicator extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;

  const ConnectionIndicator({
    super.key,
    required this.isConnected,
    required this.isConnecting,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color iconColor;
    IconData iconData;
    String? message;

    if (isConnecting) {
      bgColor = Colors.orange.shade50;
      iconColor = Colors.orange.shade600;
      iconData = Icons.bluetooth_searching;
      message = "Connecting...";
    } else if (isConnected) {
      bgColor = Colors.blue.shade50;
      iconColor = Colors.blue.shade600;
      iconData = Icons.bluetooth_connected;
    } else {
      bgColor = Colors.grey.shade100;
      iconColor = Colors.grey.shade400;
      iconData = Icons.bluetooth_disabled;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            iconData,
            color: iconColor,
            size: 24,
          ),
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}