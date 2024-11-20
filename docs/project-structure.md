# Project Structure Documentation
[Last Updated: 2024-11-20]

## LLM INSTRUCTIONS
When updating this document:
- Always maintain the full path structure
- Use consistent status indicators (✓, 🔄, 📋, ❌)
- Preserve comments about implementation status
- Keep the hierarchy and indentation consistent
- Update the File Status Overview counts
- Add dates to Recent Changes
- Include parent directories in file paths
- Document any new dependencies
- Keep Critical Files section updated
- Note any security-sensitive files
- Maintain alphabetical ordering within directories
- Document any new Flutter/Dart package dependencies

## Status Legend
✓ - Implemented and tested
🔄 - In Progress
📋 - Planned
❌ - Deprecated/Removed

## File Status Overview
Total Files: 30
- ✓ Implemented: 15
- 🔄 In Progress: 8
- 📋 Planned: 7
- ❌ Deprecated/Removed: 0

```
que_app/
├── android/                 # Android platform files
│   └── app/
│       └── src/
│           └── main/
│               ├── AndroidManifest.xml     # 🔄 Platform configuration
│               └── kotlin/
│                   └── com/
│                       └── que/
│                           └── aromatherapy/
│                               └── MainActivity.kt  # 🔄 Main activity
├── docs/                    # Project documentation
│   ├── api/                # 📋 API documentation (empty)
│   ├── assets/             # 📋 Documentation assets (empty)
│   └── project-structure.md # ✓ Project structure documentation
│   └── development-context.md # ✓ Project development state
│
├── lib/                    # Source code
│   ├── models/            # Data models
│   │   ├── device.dart    # ✓ Device model class
│   │   ├── device_list.dart # ✓ List management for devices
│   │   ├── note.dart      # ✓ Note model class
│   │   └── notes_list.dart # ✓ List management for notes
│   │
│   ├── screens/          # UI screens and components
│   │   ├── device_control/
│   │   │   ├── components/           
│   │   │   │   ├── device_remote_card.dart  # ✓ Device control card
│   │   │   │   └── timed_binary_button.dart # ✓ Timed, toggleable button for emissions
│   │   │   ├── dialogs/             
│   │   │   │   ├── add_device_dialog.dart   # 🔄 Add a new device
│   │   │   └── device_control_screen.dart   # ✓ Main device control screen
│   │   │
│   │   ├── device_settings/
│   │   │   ├── dialogs/
│   │   │   │   ├── delete_device_dialog.dart      # ✓ Confirm device deletion
│   │   │   │   ├── duration_selection_dialog.dart  # ✓ Select emission duration
│   │   │   │   └── heart_rate_threshold_dialog.dart # ✓ Select heart rate threshold
│   │   │   └── device_settings_screen.dart  # 🔄 Device-independent settings screen
│   │   │
│   │   └── notes/
│   │       ├── dialogs/
│   │       │   └── add_note_dialog.dart # ✓ Note creation dialog
│   │       └── notes_screen.dart  # ✓ Show all notes and add notes
│   │
│   ├── services/
│   │   ├── analytics_service.dart # 📋 Empty
│   │   ├── ble_service.dart     # 🔄 BLE operations        
│   │   ├── database_service.dart  # 🔄 Data persistence
│   │   └── logging_service.dart # 📋 Empty
│   │
│   ├── tools/              # Development tools
│   │   └── ble_development_tool.dart  # 🔄 BLE testing interface
│   │
│   ├── utils/           
│   │   └── ble_utils.dart      # 🔄 BLE helper functions
│   │
│   ├── widgets/           # Globally shared widgets
│   │   ├── buttons/
│   │   └── cards/
│   │
│   ├── app_data.dart    # 🔄 Globally shared data
│   ├── main.dart        # ✓ Application entry point
│   └── README.md        # ✓ Library documentation
│
└── test/
    ├── bloc
    │   └── device_bloc_test.dart # 📋 Empty
    ├── models
    │   └── device_test.dart # 📋 Empty
    ├── services
    │   └── ble_service_test.dart # 📋 Empty
    └── widget 
        └── widget_test.dart # 🔄 Basic tests implemented
```

## Dependencies
Key dependencies:
- flutter_blue_plus: ^1.31.8
- permission_handler: ^11.0.1
- provider: ^6.1.1
- shared_preferences: ^2.2.2
- sqflite: ^2.3.0

## Required Permissions
```xml
<!-- Android BLE Permissions -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
    android:usesPermissionFlags="neverForLocation"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

## Security-Sensitive Files
- lib/services/ble_service.dart - BLE communication
- lib/services/database_service.dart - Local data storage
- lib/app_data.dart - Application state and user preferences
- android/app/src/main/AndroidManifest.xml - Permission declarations

## Recent Changes
1. [2024-11-20] Moved ble_test.dart to tools/ble_development_tool.dart
2. [2024-11-20] Updated BLE implementation to use flutter_blue_plus
3. [2024-11-20] Added Android BLE permissions
4. [2024-11-20] Updated minSdkVersion for BLE compatibility

## Critical Files
1. lib/services/ble_service.dart - Core BLE communication
2. lib/services/database_service.dart - Data persistence
3. lib/screens/device_control/device_control_screen.dart - Main interface
4. lib/app_data.dart - Application state management
5. lib/models/device.dart - Core device functionality
6. android/app/src/main/AndroidManifest.xml - Platform configuration

## Directory Details

### `lib/screens/`
UI screens and their associated components:

#### `device_control/`
Main device control interfaces:
- **components/**
  - `device_remote_card.dart`: Card widget for device control
  - `timed_binary_button.dart`: Screen-specific button component
- **dialogs/**
  - `add_device_dialog.dart`: Dialog for discovering and pairing new Que devices
  - `add_note_dialog.dart`: Dialog for creating notes within device control
- `device_control_screen.dart`: Primary device control interface

#### `device_settings/`
Device configuration interfaces:
- **dialogs/**
  - `delete_device_dialog.dart`: Device removal confirmation
  - `duration_selection_dialog.dart`: Timer configuration
  - `heart_rate_threshold_dialog.dart`: Heart rate settings
- `device_settings_screen.dart`: Settings management interface

#### `notes/`
Note management interfaces:
- `note_editor.dart`: Note creation/editing interface
- `notes_screen.dart`: List view of all notes

### `lib/models/`
Contains data model classes that represent the core entities of the application:
- `device.dart`: Represents a Que device with its properties and states
- `device_list.dart`: Manages collections of Que devices
- `note.dart`: Represents user notes and observations
- `notes_list.dart`: Manages collections of notes

### `lib/services/`
Core service implementations:
- `ble_service.dart`: Handles all BLE communication
- `database_service.dart`: Manages data persistence

### `lib/utils/`
Helper classes and utilities:
- `ble_utils.dart`: BLE-specific helper functions
- `date_time_utils.dart`: Date and time manipulation utilities

### Key Files
- `app_data.dart`: Manages application-wide state
- `ble_test.dart`: Testing utilities for BLE functionality
- `main.dart`: Application entry point and initialization

## File Organization Principles
1. **Screen-Specific Components**: Components used only within a specific screen are placed in that screen's `components/` directory
2. **Screen-Specific Dialogs**: Dialogs are placed in a `dialogs/` directory within their respective screen directory
3. **Shared Components**: If a component begins to be used across multiple screens, it should be moved to a shared `widgets/` directory
4. **Development Tools**: Standalone tools and testing utilities are placed in the `tools/` directory


## Platform Requirements
- Android minSdkVersion: 21 (required for flutter_blue_plus)
- Bluetooth Low Energy (BLE) capability
- Location services for BLE scanning
- Runtime permissions handling

## Future Structure Considerations
- Add `bloc/` directory for state management
- Add `widgets/` for truly shared components
- Add `constants/` for app-wide constants
- Add `themes/` for styling
- Add integration tests directory
- Expand documentation with API specs
- Add architecture diagrams

[End of Document]

