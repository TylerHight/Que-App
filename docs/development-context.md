# Que App: Development Context and Documentation
[Last Updated: 2024-11-26]

## Purpose
This document provides essential context and current development status to assist with the ongoing development of the Que App, a Flutter application for managing BLE-enabled scent devices. This document should be used alongside the project structure document to understand both the current state and implementation details.

## Current Development State

### Active Development
- **Current Task**: Completing BLE service implementation and fixing dialog parameters
- **Last Major Change**: Updated BLE service to use modern FlutterBluePlus API (2024-11-26)
- **Next Priority**: Dialog parameter standardization and database service implementation

### Implementation Status
#### Core Services Status
- ✓ BLE Connection Management
- ✓ Device State Management
- ✓ BLE Constants and UUIDs
- 🔄 Database Service
- 📋 Analytics Service
- 📋 Logging Service

#### Feature Implementation Status
- ✓ Device Settings Architecture
- ✓ Settings UI Components
- ✓ BLE Permissions
- 🔄 Device Control Feature
- 🔄 Notes Feature
- 🔄 Global Navigation

### Critical Implementation Gaps
1. Database Service
  - Need to implement core CRUD operations
  - Migration to feature-specific repositories needed
  - Local storage optimization required

2. Dialog Standardization
  - Parameter consistency required across all dialogs
  - Need unified dialog creation pattern
  - Loading state handling needed

3. Testing Strategy
  - BLoC tests needed for implemented features
  - UI component testing framework needed
  - E2E testing strategy required

### Architecture Notes
1. State Management
  - Using BLoC pattern for feature-level state
  - ChangeNotifier for model-level state
  - Equatable for state comparison

2. BLE Implementation
  - Singleton service pattern
  - Modern FlutterBluePlus API usage
  - Persistent connection management

3. Feature Organization
  - Feature-first architecture
  - Shared core services
  - Feature-specific repositories

### Core Data Types Reference
Key data structures that should be consistent across implementations:

```dart
// Device Settings Shape
{
  emission1Duration: Duration,
  emission2Duration: Duration,
  releaseInterval1: Duration,
  releaseInterval2: Duration,
  isPeriodicEmissionEnabled: bool,
  isPeriodicEmissionEnabled2: bool,
  heartrateThreshold: int,
}

// BLE Characteristic Types
{
  ledControl: uint8,
  emissionDuration: uint16,
  releaseInterval: uint16,
  periodicEnabled: bool,
  heartrateThreshold: uint8,
}
```

### Required Fixes
1. ⚠️ High Priority
  - DatabaseService CRUD operations
  - Dialog parameter standardization
  - BLE connection error handling

2. 🔄 In Progress
  - Feature-first architecture migration
  - Global state management
  - Navigation system

3. 📋 Planned
  - Analytics integration
  - Logging system
  - Comprehensive testing

### Security Considerations
- All BLE operations must implement timeout handling
- Database operations must handle transaction failures
- Device settings must validate before persistence
- BLE scanning must respect permission states
- Heart rate data must be handled securely

## VERSION CONTROL
Document Version: 2.0
Last Updated: 2024-11-26