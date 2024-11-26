# Que App: Development Context and Documentation
[Last Updated: 2024-11-24]

## LLM INSTRUCTIONS
[Previous instructions remain the same]

## ASSISTANT CONTEXT SECTION

Current Development Focus:
- Active Task: "Implementing BLE service integration and fixing dialog parameters"
- Last Change: "Updated Device model with enhanced state management"
- Next Task: "Complete BLE service integration and dialog fixes"

Recent Code Changes (Last 3 conversations):
1. Enhanced Device model with proper state management (2024-11-24)
2. Added Device model setters and copyWith methods (2024-11-24)
3. Implemented delete functionality in Device model (2024-11-24)
4. Added EquatableMixin to Device model (2024-11-24)
5. Fixed Device model compatibility issues (2024-11-24)
6. Added complete device settings feature architecture (2024-11-23)
7. Implemented settings BLoC and repository pattern (2024-11-23)

Known Context Gaps:
- BLE service integration with new architecture
- Dialog parameter standardization
- DatabaseService method implementation
- Testing strategy for UI components
- Comprehensive testing strategy for BLoCs
- Inter-feature communication patterns
- Analytics service implementation
- E2E test coverage

## IMPLEMENTATION STATUS

### Currently Working Features ✓
- Device model implementation with state management
- Device model ChangeNotifier and Equatable integration
- Device copyWith and state update methods
- Note creation and management
- Device control interface
- Device remote card UI
- Timed binary button
- Device deletion confirmation
- Duration selection dialog
- Heart rate threshold dialog
- Note creation dialog
- Main application entry point
- BLE permissions utility
- Core BLE constants
- Settings feature architecture
- Settings UI components
- Settings BLoC implementation
- Settings repository pattern
- Settings service layer
- Device settings management
- Heart rate monitor integration
- Scent control management

### In Progress 🔄
- BLE service method implementation
- Dialog parameter standardization
- DatabaseService core methods
- Feature-first architecture migration for remaining features
- BLoC implementation for other features
- State management refactoring
- Repository pattern for other features
- Device control BLoC
- Permission handling workflow
- Navigation system
- Widget tests adaptation

### Blocking Issues 🚫
1. BLE service method implementation
2. DatabaseService core methods
3. Dialog parameter standardization
4. Global dependency injection setup

### Planned Features 📋
- Notes feature BLoC implementation
- Analytics service
- Logging service
- Test coverage:
  - BLoC tests for all features
  - Repository tests
  - Integration tests
  - E2E tests

## TECHNICAL SPECIFICATIONS

### Required Permissions
[Previous permissions section remains the same]

### Core Data Types
```dart
// lib/core/models/device.dart
class Device extends ChangeNotifier with EquatableMixin {
  final String id;
  final String deviceName;
  String connectedQueName;
  BluetoothDevice? bluetoothDevice;
  static const Duration defaultEmissionDuration = Duration(seconds: 10);

  // Private fields for state management
  Duration _emission1Duration;
  Duration _emission2Duration;
  Duration _releaseInterval1;
  Duration _releaseInterval2;
  bool _isPeriodicEmissionEnabled;
  bool _isPeriodicEmissionEnabled2;
  bool _isBleConnected;
  int _heartrateThreshold;
  final BleService bleService;
  final Map<String, List<String>> bluetoothServiceCharacteristics;

  // Getters and setters implementation
  Duration get emission1Duration => _emission1Duration;
  Duration get emission2Duration => _emission2Duration;
  Duration get releaseInterval1 => _releaseInterval1;
  Duration get releaseInterval2 => _releaseInterval2;
  bool get isPeriodicEmissionEnabled => _isPeriodicEmissionEnabled;
  bool get isPeriodicEmissionEnabled2 => _isPeriodicEmissionEnabled2;
  bool get isBleConnected => _isBleConnected;
  int get heartrateThreshold => _heartrateThreshold;

  set isBleConnected(bool value) {
    _isBleConnected = value;
    notifyListeners();
  }

  // Constructor and factory implementation
  // Update methods implementation
  // copyWith method implementation
  // State management methods
  // BLE connection handling
  // Device deletion
  // JSON serialization
}

// lib/features/device_settings/models/settings_config.dart
[Previous SettingsConfig implementation remains the same]

// lib/core/models/note.dart
[Previous Note implementation remains the same]
```

### Project Dependencies
[Previous dependencies section remains the same]

### Known Issues
1. ✓ Device model implementation and state management
2. ✓ Settings BLoC implementation
3. ✓ Settings repository pattern
4. ✓ Settings dependency injection
5. ✓ BLE permissions utility
6. ✓ Core BLE constants
7. 🔄 BLE service method implementation
8. 🔄 Dialog parameter standardization
9. 🔄 DatabaseService implementation
10. 🔄 Global state management
11. 📋 Analytics implementation
12. 📋 Test coverage
13. 🔄 Notes feature BLoC
14. 🔄 Global navigation system

### Required Fixes
1. Implement missing BLE service methods
2. Standardize dialog parameters
3. Implement DatabaseService methods
4. Complete migration of remaining features
5. Configure global dependency injection
6. Update tests for new architecture
7. Implement comprehensive error handling
8. Add loading states for all operations
9. Implement proper state persistence
10. Add proper cleanup in BLoCs

### Architecture Decisions
[Previous architecture decisions remain the same]

### Security-Sensitive Components
- BLE communication (lib/core/services/ble_service.dart)
- Local data storage (lib/core/services/database_service.dart)
- BLE permissions (lib/core/utils/ble/ble_permissions.dart)
- Device state management (lib/core/models/device.dart)
- Settings persistence (lib/features/device_settings/repositories/device_settings_repository.dart)
- Runtime permissions handling
- BLE device scanning
- Device connection security
- State persistence
- Heart rate monitor integration
- Device configuration management
- Device state mutations
- BLE connection state handling

## VERSION CONTROL
Document Version: 1.5
Last Editor: Assistant
Last Edit Date: 2024-11-24

[End of Document]