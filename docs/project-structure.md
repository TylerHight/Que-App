# Project Structure Documentation
[Last Updated: 2024-11-26]

## LLM INSTRUCTIONS
When updating this document:
- Always maintain the full path structure
- Use consistent status indicators (✓, 🔄, 📋, ❌)
- Preserve and update comments about implementation status
- Preserve and update comments about file and directory purposes
- Keep the hierarchy and indentation consistent
- Update the File Status Overview counts
- Add dates to Recent Changes
- Include parent directories in file paths
- Document any new dependencies
- Keep Critical Files section updated
- Note any security-sensitive files
- Maintain alphabetical ordering within directories
- Document any new Flutter/Dart package dependencies
- Always ensure that the project directory structure is complete

## Status Legend
✓ - Implemented and tested  
🔄 - In Progress  
📋 - Planned  
❌ - Deprecated/Removed

## File Status Overview
Total Files: 57
- ✓ Implemented: 30
- 🔄 In Progress: 9
- 📋 - Planned: 18
- ❌ Deprecated/Removed: 0

```
que_app/
│
├── lib/                           # Source code
│   ├── core/                     # Core functionality
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # 📋 App constants
│   │   │   └── ble_constants.dart    # ✓ BLE constants
│   │   │
│   │   ├── models/
│   │   │   ├── device/              # ✓ Device model directory
│   │   │   │   ├── device.dart          # ✓ Main device class
│   │   │   │   ├── device_state.dart    # ✓ Device state management
│   │   │   │   ├── device_ble.dart      # ✓ BLE functionality
│   │   │   │   ├── device_utils.dart    # ✓ Utility functions
│   │   │   │   ├── device_persistence.dart # ✓ Persistence logic
│   │   │   │   └── index.dart           # ✓ Barrel file
│   │   │   ├── device_list.dart     # ✓ Device list
│   │   │   ├── note.dart            # ✓ Note model
│   │   │   └── notes_list.dart      # ✓ Notes list
│   │   │
│   │   ├── services/
│   │   │   ├── analytics_service.dart # 📋 Analytics
│   │   │   ├── ble_service.dart      # 🔄 BLE operations
│   │   │   ├── database_service.dart  # 🔄 Data persistence
│   │   │   └── logging_service.dart   # 📋 Logging
│   │   │
│   │   ├── utils/
│   │   │   └── ble/
│   │   │       ├── ble_permissions.dart # ✓ BLE permissions
│   │   │       └── ble_utils.dart      # 🔄 BLE helpers
│   │   │
│   │   ├── widgets/
│   │   │   ├── buttons/              # 🔄 Common buttons
│   │   │   └── cards/               # 🔄 Common cards
│   │   │
│   │   └── themes/
│   │       └── app_theme.dart       # 📋 Theme configuration
│   │
│   ├── features/
│   │   ├── device_control/         # Device control feature
│   │   │   └── [...]
│   │   │
│   │   ├── device_settings/       # Settings feature
│   │   │   ├── bloc/             # State management
│   │   │   │   ├── device_settings_bloc.dart    # ✓ Settings logic
│   │   │   │   ├── device_settings_event.dart   # ✓ Events
│   │   │   │   └── device_settings_state.dart   # ✓ States
│   │   │   │
│   │   │   ├── models/           # Feature-specific models
│   │   │   │   └── settings_config.dart        # ✓ Settings configuration
│   │   │   │
│   │   │   ├── repositories/     # Data layer
│   │   │   │   └── device_settings_repository.dart # ✓ Settings repository
│   │   │   │
│   │   │   ├── services/         # Business logic
│   │   │   │   └── settings_service.dart       # ✓ Settings operations
│   │   │   │
│   │   │   ├── utils/            # Feature utilities
│   │   │   │   └── settings_helpers.dart       # ✓ Helper functions
│   │   │   │
│   │   │   ├── widgets/          # UI components
│   │   │   │   ├── base/        # Base components
│   │   │   │   │   ├── settings_group.dart     # ✓ Base group widget
│   │   │   │   │   ├── settings_list_tile.dart # ✓ Base list tile
│   │   │   │   │   ├── settings_switch_tile.dart # ✓ Base switch tile
│   │   │   │   │   ├── settings_value_tile.dart # ✓ Value display tile
│   │   │   │   │   └── settings_info_tile.dart  # ✓ Info display tile
│   │   │   │   │
│   │   │   │   ├── settings_groups/          # Group components
│   │   │   │   │   ├── scent_one_settings.dart # ✓ Scent one group
│   │   │   │   │   ├── scent_two_settings.dart # ✓ Scent two group
│   │   │   │   │   ├── heart_rate_settings.dart # ✓ Heart rate group
│   │   │   │   │   └── device_settings.dart    # ✓ Device settings group
│   │   │   │   │
│   │   │   │   └── tiles/                    # Specific tiles
│   │   │   │       ├── bluetooth_settings_tile.dart # ✓ Bluetooth tile
│   │   │   │       ├── device_info_tile.dart      # ✓ Device info tile
│   │   │   │       ├── duration_settings_tile.dart # ✓ Duration tile
│   │   │   │       └── heart_rate_settings_tile.dart # ✓ Heart rate tile
│   │   │   │
│   │   │   ├── dialogs/          # Modal dialogs
│   │   │   │   ├── delete_device_dialog.dart     # ✓ Delete device
│   │   │   │   ├── duration_selection_dialog.dart # ✓ Duration picker
│   │   │   │   ├── device_info_dialog.dart       # ✓ Device info
│   │   │   │   └── heart_rate_threshold_dialog.dart # ✓ Heart rate
│   │   │   │
│   │   │   └── views/            # Screen implementations
│   │   │       ├── settings_screen.dart      # ✓ Container component
│   │   │       └── settings_content.dart     # ✓ Presentation component
│   │   │
│   │   └── notes/                # Notes feature
│   │       └── [...]
│   │
│   ├── tools/
│   │   └── ble_development_tool.dart  # 🔄 BLE testing
│   │
│   ├── app.dart                  # ✓ App configuration
│   ├── main.dart                 # ✓ Entry point
│   └── routes.dart               # 🔄 App navigation
│
└── test/                         # Test directory
    ├── core/                    # Core tests
    │   └── [same as original]
    │
    ├── features/               # Feature tests
    │   ├── device_settings/   # Settings feature tests
    │   │   ├── bloc/
    │   │   │   └── device_settings_bloc_test.dart # 📋 BLoC tests
    │   │   ├── repositories/
    │   │   │   └── device_settings_repository_test.dart # 📋 Repo tests
    │   │   ├── services/
    │   │   │   └── settings_service_test.dart # 📋 Service tests
    │   │   └── widgets/
    │   │       ├── base/
    │   │       │   └── settings_widgets_test.dart # 📋 Base widget tests
    │   │       ├── settings_groups/
    │   │       │   └── settings_groups_test.dart # 📋 Group tests
    │   │       └── tiles/
    │   │           └── settings_tiles_test.dart # 📋 Tile tests
    │   │
    │   └── [...]
    │
    └── widget_test.dart        # 🔄 Widget tests
```

## Recent Changes
1. [2024-11-26] Refactored Device model into modular structure
2. [2024-11-24] Updated Device model with new methods and compatibility fixes
3. [2024-11-23] Completed device settings feature implementation
4. [2024-11-23] Added settings BLoC pattern implementation
5. [2024-11-23] Added settings repository and service layers

## Platform Requirements
- Android compileSdkVersion: 34
- Android targetSdkVersion: 34
- Android minSdkVersion: 21
- Bluetooth Low Energy (BLE) capability
- Location services for BLE scanning
- Runtime permissions handling

## Security-Sensitive Components
- BLE communication (lib/core/services/ble_service.dart)
- Local data storage (lib/core/services/database_service.dart)
- BLE permissions (lib/core/utils/ble/ble_permissions.dart)
- Device model (lib/core/models/device/device.dart)
- Device BLE operations (lib/core/models/device/device_ble.dart)
- Device state management (lib/core/models/device/device_state.dart)
- Settings persistence (lib/features/device_settings/repositories/device_settings_repository.dart)
- Runtime permissions handling
- BLE device scanning
- Device connection security
- State persistence
- Heart rate monitor integration
- Device configuration management

[End of Document]