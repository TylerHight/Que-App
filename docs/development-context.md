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
- **Current Task**: Connection state management and offline synchronization
- **Last Major Change**: Fixed offline state persistence and sync mechanism (2024-11-28)
- **Next Priority**: Connection state handling optimization and BLE error recovery

### Implementation Status
#### Core Services Status
- 🔄 BLE Connection Management (In Progress - Fixing connection state checks)
- ✓ Device State Management
- ✓ BLE Constants and UUIDs
- 🔄 Database Service Architecture
- 🔄 Database Implementation
- 🔄 Offline State Management
- 📋 Analytics Service
- 📋 Logging Service
- 📋 Encryption Service

#### Feature Implementation Status
- ✓ Device Settings Architecture
- ✓ Settings UI Components
- ✓ BLE Permissions
- 🔄 Device Control Feature (Improving connection handling)
- ✓ Device Info Dialog
- ✓ Heart Rate Configuration UI
- 🔄 Offline Settings Support
- 🔄 Notes Feature
- 🔄 Global Navigation

### Critical Implementation Gaps
1. BLE Connection Management
- ✓ Connection retry logic implementation
- 🔄 Error recovery mechanisms
- 🔄 Connection state management
- 📋 Connection quality monitoring
- 📋 Device verification systems
- ✓ Bluetooth state management
- 🔄 Offline state handling

2. Dialog Parameter Standardization
- ✓ Duration selection dialog parameters standardized
- ✓ Heart rate threshold dialog parameters aligned
- ✓ Add device dialog parameters standardized
- ✓ Pending changes indicators standardized
- 📋 Connection status dialogs need standardization
- 📋 Error message standardization needed

3. Testing Strategy
- 📋 BLE connection testing framework needed
- 📋 Connection reliability testing needed
- 📋 Error recovery testing needed
- 📋 State management testing required
- 📋 Offline functionality testing needed

### Architecture Notes
1. State Management
- Using BLoC pattern for feature-level state
- ChangeNotifier for model-level state
- Equatable for state comparison
- Provider pattern for service injection
- Component-based state management for complex dialogs
- Mixin-based state management modularization
- Connection state stream management
- Offline state persistence and sync

2. BLE Implementation
- Singleton service pattern
- Modern FlutterBluePlus API usage
- Connection retry mechanisms implemented
- Enhanced error handling
- Standardized BLE constants
- Improved timeout handling
- Optional device connection support
- Offline operation support
- Stream-based connection state tracking

3. Feature Organization
- Feature-first architecture
- Shared core services
- Feature-specific repositories
- Enhanced error handling patterns
- Proper dependency injection via provider
- Component-based dialog architecture
- Modular BLoC organization using mixins
- Standardized parameter naming

### Required Fixes
1. ⚠️ High Priority
- Connection state management stream implementation
- Error recovery mechanisms
- Connection status check optimization
- Offline sync reliability

2. 🔄 In Progress
- Connection state handling refactor
- Error handling standardization
- State management improvements
- Device connection verification
- Offline state persistence

3. 📋 Planned
- Connection quality monitoring
- Device verification checks
- Comprehensive connection testing
- Error logging system
- Dialog parameter standardization completion
- Offline sync conflict resolution

## VERSION CONTROL
Document Version: 2.8
Last Updated: 2024-11-28