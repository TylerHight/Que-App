# Que App: Development Context and Documentation
[Last Updated: 2024-11-28]

## Purpose
This document provides essential context and current development status to assist with the ongoing development of the Que App, a Flutter application for managing BLE-enabled scent devices. This document should be used alongside the project structure document to understand both the current state and implementation details.

## Development Instructions for LLM Assistant
- Always include the complete file directory at the top of code files
- Provide the complete code file when possible
- The information provided in this document should be aimed at facilitating easy understanding of the project by the LLM.

## Current Development State

### Active Development
- **Current Task**: BLE connection reliability improvements and dialog parameter standardization
- **Last Major Change**: Refactored add device dialog into component-based architecture (2024-11-28)
- **Next Priority**: Error handling standardization across BLE operations

### Implementation Status
#### Core Services Status
- 🔄 BLE Connection Management (In Progress - Adding retry logic and error recovery)
- ✓ Device State Management
- ✓ BLE Constants and UUIDs
- 🔄 Database Service Architecture
- 🔄 Database Implementation
- 📋 Analytics Service
- 📋 Logging Service
- 📋 Encryption Service

#### Feature Implementation Status
- ✓ Device Settings Architecture
- ✓ Settings UI Components
- ✓ BLE Permissions
- 🔄 Device Control Feature (Improving connection reliability)
- ✓ Device Info Dialog
- ✓ Heart Rate Configuration UI
- 🔄 Notes Feature
- 🔄 Global Navigation

### Critical Implementation Gaps
1. BLE Connection Management
- ✓ Connection retry logic implementation
- 🔄 Error recovery mechanisms
- ✓ Connection state management
- 📋 Connection quality monitoring
- 📋 Device verification systems
- ✓ Bluetooth state management

2. Dialog Parameter Standardization
- ✓ Duration selection dialog parameters standardized
- ✓ Heart rate threshold dialog parameters aligned
- ✓ Add device dialog parameters standardized
- 📋 Connection status dialogs need standardization
- 📋 Error message standardization needed

3. Testing Strategy
- 📋 BLE connection testing framework needed
- 📋 Connection reliability testing needed
- 📋 Error recovery testing needed
- 📋 State management testing required

### Architecture Notes
1. State Management
- Using BLoC pattern for feature-level state
- ChangeNotifier for model-level state
- Equatable for state comparison
- Provider pattern for service injection
- Component-based state management for complex dialogs

2. BLE Implementation
- Singleton service pattern
- Modern FlutterBluePlus API usage
- Connection retry mechanisms implemented
- Enhanced error handling
- Standardized BLE constants
- Improved timeout handling
- Optional device connection support

3. Feature Organization
- Feature-first architecture
- Shared core services
- Feature-specific repositories
- Enhanced error handling patterns
- Proper dependency injection via provider
- Component-based dialog architecture

### Required Fixes
1. ⚠️ High Priority
- Connection state management improvements
- Error recovery mechanisms
- Connection retry logic refinement
- Bluetooth state handling optimization

2. 🔄 In Progress
- Add device dialog UI refinements
- Error handling standardization
- State management improvements
- Device verification systems
- Connection reliability improvements

3. 📋 Planned
- Connection quality monitoring
- Device verification checks
- Comprehensive connection testing
- Error logging system
- Dialog parameter standardization completion

## VERSION CONTROL
Document Version: 2.5
Last Updated: 2024-11-28