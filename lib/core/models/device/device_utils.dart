// lib/core/models/device/device_utils.dart
import 'dart:math';

class DeviceUtils {
  static String generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    const idLength = 10;
    return String.fromCharCodes(
      Iterable.generate(
        idLength,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}