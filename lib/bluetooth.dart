// bluetooth.dart
///
/// Bluetooth Operations
///
/// This file contains the implementation of Bluetooth operations for the app.
/// It includes functionalities such as connecting to devices, sending and
/// receiving data over Bluetooth, and managing Bluetooth-related tasks.
///
/// Author: Tyler Hight
///

import 'dart:async';

class BluetoothOperations {
  StreamController<int> _heartRateController = StreamController<int>();
  int _currentHeartRate = 60;

  // Other Bluetooth-related functions and variables...

  // Function to emulate heart rate data
  void emulateHeartRate() {
    int initialHeartRate = 60;
    int targetHeartRate = 100;

    // Start the initial increase
    increaseHeartRate(initialHeartRate, targetHeartRate);
  }

  void increaseHeartRate(int initialHeartRate, int targetHeartRate) {
    Timer.periodic(Duration(seconds: 1), (innerTimer) {
      if (initialHeartRate < targetHeartRate) {
        _currentHeartRate = initialHeartRate + 40 ~/ 12; // Increase by 40 bpm over 12 seconds
        _heartRateController.add(_currentHeartRate);
        initialHeartRate += 40 ~/ 12;
      } else {
        innerTimer.cancel();
        decreaseHeartRate(initialHeartRate); // Start decreasing heart rate
      }
    });
  }

  void decreaseHeartRate(int initialHeartRate) {
    Timer.periodic(Duration(seconds: 1), (innerTimer) {
      if (initialHeartRate > 60) {
        _currentHeartRate = initialHeartRate - 40 ~/ 12; // Decrease by 40 bpm over 12 seconds
        _heartRateController.add(_currentHeartRate);
        initialHeartRate -= 40 ~/ 12;
      } else {
        innerTimer.cancel();
        increaseHeartRate(initialHeartRate, initialHeartRate + 40); // Start increasing heart rate again
      }
    });
  }

  // Getter method to retrieve the current heart rate as a stream
  Stream<int> get heartRateStream => _heartRateController.stream;

  // Getter method to retrieve the current heart rate
  int getCurrentHeartRate() {
    return _currentHeartRate;
  }
}

void main() {
  BluetoothOperations bluetooth = BluetoothOperations();
  bluetooth.emulateHeartRate();

  // Outside operation sampling heart rate every 3 seconds
  Timer.periodic(Duration(seconds: 3), (timer) {
    int currentHeartRate = bluetooth.getCurrentHeartRate();
    print('Sampled Heart Rate: $currentHeartRate');
  });
}

