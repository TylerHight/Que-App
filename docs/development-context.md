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
- Active Task: "Fixing Android build configuration and MainActivity"
- Last Change: "Updated Gradle configurations and fixed package names"
- Next Task: "Implement BLE permission handling"

Recent Code Changes (Last 3 conversations):
1. Updated app/build.gradle to SDK 34 (2024-11-20)
2. Fixed package name consistency to com.example.que_app (2024-11-20)
3. Updated AndroidManifest.xml structure (2024-11-20)
4. Updated Kotlin dependencies to resolve conflicts (2024-11-20)

Known Context Gaps:
- Runtime permission handling needed
- BLE connection stability needs improvement
- Permission request workflow required
- BLE service implementation needs completion
- Device settings persistence required
- Analytics service implementation pending
- Test coverage needs expansion

## IMPLEMENTATION STATUS

### Currently Working Features ✓
- Device model implementation
- Note creation and management
- Device control interface
- Device remote card UI
- Timed binary button
- Device deletion confirmation
- Duration selection dialog
- Heart rate threshold dialog
- Note creation dialog
- Main application entry point
- Android build configuration
- MainActivity implementation

### In Progress 🔄
- BLE permission handling
- BLE connection management
- Device scanning functionality
- BLE development tool
- Permission request workflow
- Add device dialog
- Device settings screen
- BLE operations
- Data persistence
- BLE utilities
- Global state management
- Basic widget tests

### Blocking Issues 🚫
1. BLE permissions not properly handled
2. Runtime permissions missing
3. BLE service implementation incomplete

### Planned Features 📋
- API documentation
- Documentation assets
- Analytics service
- Logging service
- Test coverage:
  - Device bloc tests
  - Device model tests
  - BLE service tests

## TECHNICAL SPECIFICATIONS

### Required Permissions
```xml
<!-- Android Permissions -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
```

### Core Data Types
```dart
// lib/models/device.dart
class Device {
  final String id;
  final String name;
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

## DEVELOPMENT NOTES

### Project Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_blue_plus: ^1.31.8
  permission_handler: ^11.0.1
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
```

### Known Issues
1. ✓ MainActivity class and package resolution
2. 🚫 BLE permissions not granted
3. ✓ Package name consistency
4. 🔄 Runtime permission handling
5. ✓ Device control card implementation
6. ✓ Note dialog creation
7. 🔄 BLE service implementation
8. 🔄 Device settings screen
9. 📋 Analytics implementation
10. 📋 Test coverage

### Required Fixes
1. Implement runtime permission requests
2. Add proper error handling for permission denials
3. Add proper BLE initialization checks
4. Complete BLE service implementation
5. Add comprehensive error handling

### Architecture Decisions
1. Screen-specific component organization
2. Dialog-specific directory structure
3. Shared services architecture
4. Core model separation

### Security-Sensitive Components
- BLE communication (ble_service.dart)
- Local data storage (database_service.dart)
- Application state (app_data.dart)
- Runtime permissions handling
- BLE device scanning
- Device connection security

### Android Configuration
- compileSdkVersion: 34
- minSdkVersion: 21
- targetSdkVersion: 34
- Kotlin version: 1.8.10
- Gradle plugin version: 7.3.0
- Package name: com.example.que_app

## VERSION CONTROL
Document Version: 1.3
Last Editor: Assistant
Last Edit Date: 2024-11-20

[End of Document]