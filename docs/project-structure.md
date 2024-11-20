# Project Structure

## Overview
This document outlines the organization of the Que App project, describing the purpose and contents of each directory and key files.

```
que_app/
├── lib/
│   ├── models/                 # Data models
│   │   ├── device.dart         # Device model class
│   │   ├── device_list.dart    # List management for devices
│   │   ├── note.dart          # Note model class
│   │   └── notes_list.dart     # List management for notes
│   │
│   ├── screens/               # UI screens and components
│   │   ├── device_control/    # Device control interface
│   │   │   ├── README.md
│   │   │   ├── add_device_dialog.dart    # BLE device discovery and pairing
│   │   │   ├── device_control_screen.dart # Main device control interface
│   │   │   ├── device_remote.dart        # Remote control features
│   │   │   └── device_settings.dart      # Device configuration
│   │   │
│   │   ├── device_settings/   # Device settings management
│   │   │   ├── device_settings.dart       # Settings interface
│   │   │   └── duration_selection_dialog.dart # Timer configuration
│   │   │
│   │   └── notes/            # Notes management
│   │       ├── README.md
│   │       ├── notes_screen.dart   # Notes list view
│   │       └── note_editor.dart    # Note creation/editing
│   │
│   ├── services/              # Core services
│   │   ├── ble_service.dart   # Bluetooth Low Energy operations
│   │   └── database_service.dart # Data persistence
│   │
│   ├── utils/                # Helper utilities
│   │   ├── ble_utils.dart    # BLE-specific utilities
│   │   └── date_time_utils.dart # Date/time handling
│   │
│   ├── app_data.dart        # Application state management
│   ├── ble_test.dart        # BLE testing utilities
│   ├── main.dart            # Application entry point
│   └── README.md            # Library documentation
│
└── test/
    └── widget_test.dart     # Widget testing
```

## Directory Details

### `lib/models/`
Contains data model classes that represent the core entities of the application:
- `device.dart`: Represents a Que device with its properties and states
- `device_list.dart`: Manages collections of Que devices
- `note.dart`: Represents user notes and observations
- `notes_list.dart`: Manages collections of notes

### `lib/screens/`
Contains the user interface components organized by feature:

#### `device_control/`
Main device control interfaces:
- `add_device_dialog.dart`: Dialog for discovering and pairing new Que devices
- `device_control_screen.dart`: Primary device control interface
- `device_remote.dart`: Remote control functionality
- `device_settings.dart`: Device-specific settings

#### `device_settings/`
Device configuration interfaces:
- `device_settings.dart`: Settings management interface
- `duration_selection_dialog.dart`: Timer and duration configuration

#### `notes/`
Note management interfaces:
- `notes_screen.dart`: List view of all notes
- `note_editor.dart`: Interface for creating and editing notes

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

### `test/`
Contains test files:
- `widget_test.dart`: Widget-level testing

## Naming Conventions
- Files use snake_case naming
- Classes use PascalCase
- Variables and functions use camelCase
- Constants use SCREAMING_SNAKE_CASE

## Development Guidelines
1. New features should be added in appropriate subdirectories
2. Maintain separate README files for complex features
3. Follow the established naming conventions
4. Update tests when adding new functionality
5. Keep related files grouped in feature-specific directories

## Future Structure Considerations
- Add `bloc/` directory for state management
- Consider adding `themes/` for styling
- Add `constants/` for app-wide constants
- Consider adding `widgets/` for shared components