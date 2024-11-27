# Project Structure Documentation
[Last Updated: 2024-11-27]

## LLM INSTRUCTIONS
When updating this document:
- Always maintain the full path structure
- Use consistent status indicators (✓, 🔄, 📋, ❌)
- Preserve and update comments about implementation status
- Preserve and update comments about file and directory purposes
- Update the File Status Overview counts
- Include parent directories in file paths
- Always ensure that the project directory structure is complete
- The information provided in this document should be aimed at facilitating easy understanding of the project by the LLM.

## Status Legend
✓ - Implemented and tested  
🔄 - In Progress  
📋 - Planned  
❌ - Deprecated/Removed

## File Status Overview
Total Files: 57
- ✓ Implemented: 35
- 🔄 In Progress: 4
- 📋 - Planned: 18
- ❌ Deprecated/Removed: 0

```
que_app/                          # Root project directory - Flutter mobile application
│
├── lib/                          # Source code - Main application code directory
│   ├── core/                     # Core functionality - Shared base implementations
│   │   ├── constants/            # Application-wide constants and configurations
│   │   │   ├── app_constants.dart    # 📋 App constants
│   │   │   └── ble_constants.dart    # ✓ BLE constants and UUIDs
│   │   │
│   │   ├── models/              # Data models - Core business logic structures
│   │   │   ├── device/          # Device management - BLE device functionality
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
│   │   ├── services/            # Core services - Application-wide functionality
│   │   │   ├── analytics_service.dart # 📋 Analytics
│   │   │   ├── ble_service.dart      # ✓ BLE operations and connection management
│   │   │   ├── database_service.dart  # ✓ Data persistence with singleton pattern
│   │   │   └── logging_service.dart   # 📋 Logging
│   │   │
│   │   ├── utils/               # Utilities - Helper functions and tools
│   │   │   └── ble/            # BLE specific utilities
│   │   │       ├── ble_permissions.dart # ✓ BLE permissions
│   │   │       └── ble_utils.dart      # ✓ BLE helpers
│   │   │
│   │   ├── widgets/            # Common widgets - Reusable UI components
│   │   │   ├── buttons/        # Custom button implementations
│   │   │   └── cards/         # Card layout components
│   │   │
│   │   └── themes/            # Theme configuration - App-wide styling
│   │       └── app_theme.dart # 📋 Theme configuration
│   │
│   ├── features/              # Features - Main application features
│   │   ├── device_control/    # Device control - Necklace interaction
│   │   │   └── [...]
│   │   │
│   │   ├── device_settings/   # Settings feature - Device configuration
│   │   │   ├── bloc/          # State management - Settings state handling
│   │   │   │   ├── device_settings_bloc.dart    # ✓ Settings logic
│   │   │   │   ├── device_settings_event.dart   # ✓ Events
│   │   │   │   └── device_settings_state.dart   # ✓ States
│   │   │   │
│   │   │   ├── models/        # Feature models - Settings data structures
│   │   │   │   └── settings_config.dart        # ✓ Settings configuration
│   │   │   │
│   │   │   ├── repositories/  # Data layer - Settings persistence
│   │   │   │   └── device_settings_repository.dart # ✓ Settings repository
│   │   │   │
│   │   │   ├── services/      # Business logic - Settings operations
│   │   │   │   └── settings_service.dart       # ✓ Settings operations
│   │   │   │
│   │   │   ├── utils/         # Feature utilities - Settings helpers
│   │   │   │   └── settings_helpers.dart       # ✓ Helper functions
│   │   │   │
│   │   │   ├── widgets/       # UI components - Settings interface
│   │   │   │   ├── base/      # Base components - Common settings widgets
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
│   │   │   │   └── tiles/                    # Individual setting tiles
│   │   │   │       ├── bluetooth_settings_tile.dart # ✓ Bluetooth tile
│   │   │   │       ├── device_info_tile.dart      # ✓ Device info tile
│   │   │   │       ├── duration_settings_tile.dart # ✓ Duration tile
│   │   │   │       └── heart_rate_settings_tile.dart # ✓ Heart rate tile
│   │   │   │
│   │   │   ├── dialogs/       # Modal dialogs - User interactions
│   │   │   │   ├── delete_device_dialog.dart     # ✓ Delete device
│   │   │   │   ├── duration_selection_dialog.dart # 🔄 Duration picker
│   │   │   │   ├── device_info_dialog.dart       # ✓ Device info
│   │   │   │   └── heart_rate_threshold_dialog.dart # 🔄 Heart rate
│   │   │   │
│   │   │   └── views/         # Screen implementations
│   │   │       ├── settings_screen.dart      # ✓ Container component
│   │   │       └── settings_content.dart     # ✓ Presentation component
│   │   │
│   │   └── notes/             # Notes feature - User annotations
│   │       └── [...]
│   │
│   ├── tools/                 # Development tools
│   │   └── ble_development_tool.dart  # 🔄 BLE testing
│   │
│   ├── app.dart              # App configuration - Root widget
│   ├── main.dart             # Entry point - App initialization
│   └── routes.dart           # App navigation - Route definitions
│
└── test/                     # Test directory - Application tests
    ├── core/                 # Core tests - Base functionality testing
    │   └── [same as original]
    │
    ├── features/            # Feature tests - Feature-specific testing
    │   ├── device_settings/ # Settings feature tests
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
    │   ├── device_control/  # Device control tests
    │   │
    │   └── notes/          # Notes feature tests
    │
    └── widget_test.dart    # 🔄 Widget tests
```

[End of Document]