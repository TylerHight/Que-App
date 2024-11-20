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
Total Files: 18
- ✓ Implemented: 12
- 🔄 In Progress: 4
- 📋 - Planned: 2
- ❌ Deprecated/Removed: 0

```
que_app/
├── docs/                    # Project documentation
│   ├── api/                # ❌ API documentation (empty)
│   ├── assets/             # ❌ Documentation assets (empty)
│   └── project-structure.md # ✓ Project structure documentation
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
│   │   │   │   └── timed_binary_button.dart # 🔄 Screen-specific button
│   │   │   ├── dialogs/             
│   │   │   │   ├── add_device_dialog.dart   # ✓ BLE device discovery
│   │   │   │   └── add_note_dialog.dart     # ✓ Note creation dialog
│   │   │   └── device_control_screen.dart   # ✓ Main device control screen
│   │   │
│   │   ├── device_settings/
│   │   │   ├── dialogs/
│   │   │   │   ├── delete_device_dialog.dart      # 🔄 Under development
│   │   │   │   ├── duration_selection_dialog.dart  # 🔄 Under development
│   │   │   │   └── heart_rate_threshold_dialog.dart # 📋 Planned
│   │   │   └── device_settings_screen.dart  # 🔄 Under development
│   │   │
│   │   └── notes/
│   │       ├── note_editor.dart   # ✓ Implemented
│   │       └── notes_screen.dart  # ✓ Implemented
│   │
│   ├── services/        
│   │   ├── ble_service.dart     # ✓ BLE operations
│   │   └── database_service.dart # ✓ Data persistence
│   │
│   ├── utils/           
│   │   ├── ble_utils.dart      # 📋 Planned
│   │   └── date_time_utils.dart # ✓ Implemented
│   │
│   ├── app_data.dart    # ✓ Application state management
│   ├── ble_test.dart    # ✓ BLE testing utilities
│   ├── main.dart        # ✓ Application entry point
│   └── README.md        # ✓ Library documentation
│
└── test/
    └── widget_test.dart # 🔄 Basic tests implemented
```

## Dependencies
Key dependencies:
- flutter_blue_plus: ^1.31.8
- provider: ^6.1.1
- shared_preferences: ^2.2.2
- sqflite: ^2.3.0

## Security-Sensitive Files
- lib/services/ble_service.dart - BLE communication
- lib/services/database_service.dart - Local data storage
- lib/app_data.dart - Application state and user preferences

## Recent Changes
1. [2024-11-20] Reorganized device_control directory structure
2. [2024-11-20] Renamed device_remote.dart to device_remote_card.dart
3. [2024-11-20] Added components/ and dialogs/ subdirectories
4. [2024-11-20] Updated project structure documentation

## Critical Files
1. lib/services/ble_service.dart - Core BLE communication
2. lib/services/database_service.dart - Data persistence
3. lib/screens/device_control/device_control_screen.dart - Main interface
4. lib/app_data.dart - Application state management
5. lib/models/device.dart - Core device functionality

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
3. **Shared Components**: If a component begins to be used across multiple screens, it should be moved to a shared `widgets/` directory (future consideration)

## Naming Conventions
- Files use `snake_case` naming
- Classes use `PascalCase`
- Components end with their type (e.g., `_card.dart`, `_button.dart`, `_dialog.dart`)
- Screen files end with `_screen.dart`
- Variables and functions use `camelCase`
- Constants use `SCREAMING_SNAKE_CASE`

## Development Guidelines
1. Keep components with their respective screens unless shared
2. Maintain separate README files for complex features
3. Follow established naming conventions
4. Update tests when adding new functionality
5. Keep related files grouped in feature-specific directories

## Future Structure Considerations
- Add `bloc/` directory for state management
- Add `widgets/` for truly shared components
- Add `constants/` for app-wide constants
- Add `themes/` for styling
- Add integration tests directory
- Expand documentation with API specs
- Add architecture diagrams