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
- Active Task: "Fixing BLE implementation and permissions"
- Last Change: "Updated BLE service with flutter_blue_plus"
- Next Task: "Implement proper permission handling"

Recent Code Changes (Last 3 conversations):
1. Switched from flutter_blue to flutter_blue_plus (2024-11-20)
2. Updated Android minSdkVersion to 21 (2024-11-20)
3. Added BLE permissions to AndroidManifest.xml (2024-11-20)
4. Created standalone BLE development tool (2024-11-20)

Known Context Gaps:
- Runtime permission handling needed
- MainActivity package name mismatch
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

### In Progress 🔄
- BLE permission handling
- BLE connection management
- Device scanning functionality
- Package name consistency
- Android platform configuration
- BLE development tool
- MainActivity implementation
- Permission request workflow
- Add device dialog
- Device settings screen
- BLE operations
- Data persistence
- BLE utilities
- Global state management
- Basic widget tests

### Blocking Issues 🚫
1. MainActivity not found error
2. BLE permissions not properly handled
3. Package name inconsistency
4. Runtime permissions missing

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
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
    android:usesPermissionFlags="neverForLocation"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
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
1. 🚫 MainActivity class not found
2. 🚫 BLE permissions not granted
3. 🔄 Package name inconsistency
4. 🔄 Runtime permission handling
5. ✓ Device control card implementation
6. ✓ Note dialog creation
7. 🔄 BLE service implementation
8. 🔄 Device settings screen
9. 📋 Analytics implementation
10. 📋 Test coverage

### Required Fixes
1. Verify MainActivity location and package name
2. Implement runtime permission requests
3. Add proper error handling for permission denials
4. Update package name consistently across project
5. Add proper BLE initialization checks

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

## VERSION CONTROL
Document Version: 1.2
Last Editor: Assistant
Last Edit Date: 2024-11-20

[End of Document]