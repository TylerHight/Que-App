// lib/features/device_control/dialogs/add_device/components/device_name_field.dart

import 'package:flutter/material.dart';

class DeviceNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const DeviceNameField({
    super.key,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: const InputDecoration(
          labelText: 'Device Name',
          helperText: 'Enter a name for your device',
          helperMaxLines: 2,
          border: OutlineInputBorder(),
          filled: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a device name';
          }
          if (value.length > 50) {
            return 'Name must be 50 characters or less';
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}