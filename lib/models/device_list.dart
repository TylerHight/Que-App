/// device_list.dart

import 'package:flutter/foundation.dart';
import 'device.dart';

class DeviceList extends ChangeNotifier {
  List<Device> _devices = [];

  List<Device> get devices => _devices;

  void add(Device device) {
    _devices.add(device);
    notifyListeners();
  }

  void remove(Device device) {
    _devices.remove(device);
    notifyListeners();
  }
}
