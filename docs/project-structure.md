
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
- ✓ Implemented: 16
- 🔄 In Progress: 7
- 📋 - Planned: 7
- ❌ Deprecated/Removed: 0

```  
que_app/  
├── android/                 # Android platform files  
│   └── app/  
│       └── src/  
│           └── main/  
│               ├── AndroidManifest.xml     # ✓ Platform configuration  
│               └── java/  
│                   └── com/  
│                       └── example/  
│                           └── que_app/  
│                               └── MainActivity.java  # ✓ Main activity  
├── docs/                    # Project documentation  
│   ├── api/                # 📋 API documentation (empty)│   ├── assets/             # 📋 Documentation assets (empty)│   └── project-structure.md # ✓ Project structure documentation  
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
│   │   │   ├── components/ │   │   │   │   ├── device_remote_card.dart  # ✓ Device control card  
│   │   │   │   └── timed_binary_button.dart # ✓ Timed, toggleable button for emissions  
│   │   │   ├── dialogs/ │   │   │   │   ├── add_device_dialog.dart   # 🔄 Add a new device│   │   │   └── device_control_screen.dart   # ✓ Main device control screen  
│   │   │  
│   │   ├── device_settings/  
│   │   │   ├── dialogs/  
│   │   │   │   ├── delete_device_dialog.dart      # ✓ Confirm device deletion  
│   │   │   │   ├── duration_selection_dialog.dart  # ✓ Select emission duration  
│   │   │   │   └── heart_rate_threshold_dialog.dart # ✓ Select heart rate threshold  
│   │   │   └── device_settings_screen.dart  # 🔄 Device-independent settings screen│   │   │  
│   │   └── notes/  
│   │       ├── dialogs/  
│   │       │   └── add_note_dialog.dart # ✓ Note creation dialog  
│   │       └── notes_screen.dart  # ✓ Show all notes and add notes  
│   │  
│   ├── services/  
│   │   ├── analytics_service.dart # 📋 Empty│   │   ├── ble_service.dart     # 🔄 BLE operations │   │   ├── database_service.dart  # 🔄 Data persistence│   │   └── logging_service.dart # 📋 Empty│   │  
│   ├── tools/              # Development tools  
│   │   └── ble_development_tool.dart  # 🔄 BLE testing interface│   │  
│   ├── utils/ │   │   └── ble_utils.dart      # 🔄 BLE helper functions│   │  
│   ├── widgets/           # Globally shared widgets  
│   │   ├── buttons/  
│   │   └── cards/  
│   │  
│   ├── app_data.dart    # 🔄 Globally shared data│   ├── main.dart        # ✓ Application entry point  
│   └── README.md        # ✓ Library documentation  
│  
└── test/  
 ├── bloc │   └── device_bloc_test.dart # 📋 Empty ├── models │   └── device_test.dart # 📋 Empty ├── services │   └── ble_service_test.dart # 📋 Empty └── widget└── widget_test.dart # 🔄 Basic tests implemented```  
  
## Dependencies  
Key dependencies:  
- flutter_blue_plus: ^1.31.8  
- permission_handler: ^11.0.1  
- provider: ^6.1.1  
- shared_preferences: ^2.2.2  
- sqflite: ^2.3.0  
  
## Required Permissions  
```xml  
<!-- Android Permissions -->  
<uses-permission android:name="android.permission.BLUETOOTH" />  
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />  
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />  
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />  
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />  
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />  
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />  
  
<!-- Feature declarations -->  
<uses-feature  
 android:name="android.hardware.bluetooth_le" android:required="true" /><uses-feature  
 android:name="android.hardware.bluetooth" android:required="true" />  
```  

## Security-Sensitive Files
- lib/services/ble_service.dart - BLE communication
- lib/services/database_service.dart - Local data storage
- lib/app_data.dart - Application state and user preferences
- android/app/src/main/AndroidManifest.xml - Permission declarations

## Recent Changes
1. [2024-11-20] Updated Android package structure to com.example.que_app
2. [2024-11-20] Migrated MainActivity from Kotlin to Java
3. [2024-11-20] Updated AndroidManifest.xml structure
4. [2024-11-20] Updated build.gradle configurations for SDK 34
5. [2024-11-20] Added complete set of BLE permissions

## Critical Files
1. lib/services/ble_service.dart - Core BLE communication
2. lib/services/database_service.dart - Data persistence
3. lib/screens/device_control/device_control_screen.dart - Main interface
4. lib/app_data.dart - Application state management
5. lib/models/device.dart - Core device functionality
6. android/app/src/main/AndroidManifest.xml - Platform configuration

[Previous directory details and organization sections remain unchanged...]

## Platform Requirements
- Android compileSdkVersion: 34
- Android targetSdkVersion: 34
- Android minSdkVersion: 21
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
- Implement proper error handling in BLE services
- Add comprehensive permission handling
- Implement analytics and logging services

[End of Document]