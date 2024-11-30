// lib/features/device_control/dialogs/add_device/components/bluetooth_status.dart

import 'package:flutter/material.dart';

class BluetoothStatus extends StatelessWidget {
  final bool isScanning;
  final bool isConnecting;
  final String statusMessage;
  final DateTime? lastScanTime;
  final VoidCallback onScanPressed;

  const BluetoothStatus({
    super.key,
    required this.isScanning,
    required this.isConnecting,
    required this.statusMessage,
    required this.onScanPressed,
    this.lastScanTime,
  });

  String _getLastScanText() {
    if (lastScanTime == null) return '';
    final difference = DateTime.now().difference(lastScanTime!);

    if (difference.inSeconds < 60) {
      return 'Last scan: ${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return 'Last scan: ${difference.inMinutes}m ago';
    } else {
      return 'Last scan: ${difference.inHours}h ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: isScanning ? null : onScanPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
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
                        Theme.of(context).primaryColorLight,
                      ),
                    ),
                  ),
                ),
              Text(isScanning ? 'Scanning...' : 'Scan for Devices'),
            ],
          ),
        ),
        if (lastScanTime != null && !isScanning)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _getLastScanText(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (statusMessage.isNotEmpty && !statusMessage.contains('Scanning'))
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
      ],
    );
  }

  Color _getStatusColor(String message) {
    if (message.toLowerCase().contains('error') ||
        message.toLowerCase().contains('failed') ||
        message.toLowerCase().contains('timeout')) {
      return Colors.red;
    } else if (message.toLowerCase().contains('connecting')) {
      return Colors.blue;
    } else if (message.toLowerCase().contains('connected')) {
      return Colors.green;
    } else {
      return Colors.grey.shade700;
    }
  }
}