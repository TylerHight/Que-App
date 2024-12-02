// lib/features/device_control/widgets/emission_controls.dart

import 'package:flutter/material.dart';
import 'package:que_app/core/constants/ble_constants.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import 'timed_binary_button.dart';

class EmissionControls extends StatelessWidget {
  final Device device;
  final bool isConnected;
  final Function(int) onCommand;
  final BleService bleService;

  const EmissionControls({
    super.key,
    required this.device,
    required this.isConnected,
    required this.onCommand,
    required this.bleService,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: TimedBinaryButton(
            key: UniqueKey(),
            periodicEmissionEnabled: device.isPeriodicEmissionEnabled,
            periodicEmissionTimerDuration: device.releaseInterval1,
            activeColor: Colors.blue[600]!,
            inactiveColor: Colors.blue[100]!,
            iconData: Icons.air,
            buttonSize: 52.0,
            iconSize: 28.0,
            autoTurnOffDuration: device.emission1Duration,
            autoTurnOffEnabled: true,
            onPressedTurnOn: () => onCommand(BleConstants.CMD_LED_RED),
            onPressedTurnOff: () => onCommand(BleConstants.CMD_LED_OFF),
            isConnected: isConnected,
            device: device,
            bleService: bleService,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          height: 52,
          child: TimedBinaryButton(
            key: UniqueKey(),
            periodicEmissionEnabled: device.isPeriodicEmissionEnabled2,
            periodicEmissionTimerDuration: device.releaseInterval2,
            activeColor: Colors.green[600]!,
            inactiveColor: Colors.green[100]!,
            iconData: Icons.air,
            buttonSize: 52.0,
            iconSize: 28.0,
            autoTurnOffDuration: device.emission2Duration,
            autoTurnOffEnabled: true,
            onPressedTurnOn: () => onCommand(BleConstants.CMD_LED_GREEN),
            onPressedTurnOff: () => onCommand(BleConstants.CMD_LED_OFF),
            isConnected: isConnected,
            device: device,
            bleService: bleService,
          ),
        ),
      ],
    );
  }
}