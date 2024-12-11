// lib/features/device_control/dialogs/add_device/components/bluetooth_status.dart

import 'package:flutter/material.dart';

class BluetoothStatus extends StatelessWidget {
  final bool isScanning;
  final bool isConnecting;
  final String statusMessage;
  final VoidCallback onScanPressed;

  const BluetoothStatus({
    super.key,
    required this.isScanning,
    required this.isConnecting,
    required this.statusMessage,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: isScanning || isConnecting ? null : onScanPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isScanning)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                Text(isScanning ? 'Scanning...' : 'Scan for Devices'),
              ],
            ),
          ),
          if (statusMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                statusMessage,
                style: TextStyle(
                  color: _getStatusColor(statusMessage),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Color _getStatusColor(String message) {
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('error') ||
        lowerMessage.contains('failed') ||
        lowerMessage.contains('timeout')) {
      return Colors.red;
    }
    if (lowerMessage.contains('connecting')) {
      return Colors.blue;
    }
    if (lowerMessage.contains('connected')) {
      return Colors.green;
    }
    return Colors.grey.shade700;
  }
}