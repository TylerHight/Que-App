# Que App: Development Context and Documentation
[Last Updated: 2024-11-20]

## LLM INSTRUCTIONS
- When sharing code snippets, always prefix with a comment containing the full file path
- Use explicit typing in all Dart/Flutter code examples
- Handle all error cases explicitly
- When implementing new features, consider error handling and fallbacks
- Maintain consistent service naming across all files
- Follow established logging patterns with appropriate log levels
- Consider security implications in all code suggestions

Example code comment format:
```dart
// lib/services/ble_service.dart
```

## ASSISTANT CONTEXT SECTION

Current Development Focus:
- Active Task: "Implementing device settings dialogs"
- Last Change: "Reorganized device control components"
- Next Task: "Add heart rate threshold configuration"

Recent Code Changes (Last 3 conversations):
1. Reorganized device_control directory structure (2024-11-20)
2. Renamed device_remote.dart to device_remote_card.dart (2024-11-20)
3. Added components/ and dialogs/ subdirectories (2024-11-20)

Known Context Gaps:
- Heart rate threshold handling needs implementation
- BLE reconnection logic needs improvement
- Device settings persistence required
- Error handling needs enhancement

## IMPLEMENTATION STATUS

### Currently Working Features ✓
- Basic BLE device discovery
- Device connection management
- Note creation and management
- Basic device control interface
- Device remote card
- Database persistence
- Application state management

### In Progress 🔄
- Device settings screens
- Timer duration selection
- Heart rate monitoring
- Device deletion workflow

### Planned Features 📋
- Heart rate threshold configuration
- Advanced device settings
- Data analytics
- User preferences
- Connection resilience
- Automated testing

## TECHNICAL SPECIFICATIONS

### Core Data Types
```dart
// lib/models/device.dart
class Device {
  final String id;
  final String name;
  final BluetoothDevice bleDevice;
  final DeviceSettings settings;
}

// lib/models/note.dart
class Note {
  final String id;
  final String deviceId;
  final String content;
  final DateTime timestamp;
}
```

### BLE Service Integration
```
lib/services/
├── ble_service.dart        # BLE communication handling
└── database_service.dart   # Local data persistence

lib/screens/device_control/
├── components/
│   └── device_remote_card.dart
└── device_control_screen.dart
```

### BLE Configuration
```dart
// lib/services/ble_service.dart
class BleService {
  final FlutterBluePlus flutterBlue;
  final StreamController<BluetoothState> _stateController;

  Future<void> initialize() async {
    // BLE initialization
  }

  Stream<List<BluetoothDevice>> scanForDevices() {
    // Device scanning
  }
}
```

## DEVELOPMENT NOTES

### Project Dependencies
```yaml
dependencies:
  flutter_blue_plus: ^1.31.8
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
```

### Known Issues
1. ✓ Fixed: Basic BLE connection
2. ✓ Fixed: Note persistence
3. 🔄 Active: Device settings implementation
4. 🔄 Active: Heart rate monitoring
5. 📋 Planned: Connection resilience
6. 📋 Planned: Data validation

### Architecture Decisions
1. Using BLoC pattern for state management
2. Implementing local storage with SQLite
3. Using Provider for dependency injection
4. Screen-specific component organization

### Integration Patterns
- BLE Communication
- Local Data Persistence
- State Management
- Event-Driven Architecture

## SECURITY CONSIDERATIONS
- No sensitive data in code
- Secure local storage
- BLE security best practices
- No hardcoded credentials
- Proper error handling
- Data validation

## VERSION CONTROL
Document Version: 1.0
Last Editor: Assistant
Last Edit Date: 2024-11-20

[End of Document]