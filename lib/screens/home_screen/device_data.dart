// device_data.dart

import 'package:flutter/foundation.dart';

class DeviceData extends ChangeNotifier {
  List<String> _deviceTitles = List.generate(3, (index) => 'Device $index');

  List<String> get deviceTitles => _deviceTitles;

  void addDeviceTitle(String title) {
    _deviceTitles.add(title);
    notifyListeners();
  }

  void deleteDeviceTitle(int index) {
    _deviceTitles.removeAt(index);
    notifyListeners();
  }
}
