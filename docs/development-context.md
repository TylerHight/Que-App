# Que App: Development Context and Documentation
[Last Updated: 2024-11-26]

## Purpose
This document provides essential context and current development status to assist with the ongoing development of the Que App, a Flutter application for managing BLE-enabled scent devices. This document should be used alongside the project structure document to understand both the current state and implementation details.

## Current Development State

### Active Development
- **Current Task**: Completing dialog parameter standardization and HIPAA compliance planning
- **Last Major Change**: Standardized dialog parameters and device info implementation (2024-11-26)
- **Next Priority**: HIPAA-compliant data storage and heart rate monitoring implementation

### Implementation Status
#### Core Services Status
- ✓ BLE Connection Management
- ✓ Device State Management
- ✓ BLE Constants and UUIDs
- 🔄 Database Service
- 📋 Analytics Service
- 📋 Logging Service
- 📋 Encryption Service

#### Feature Implementation Status
- ✓ Device Settings Architecture
- ✓ Settings UI Components
- ✓ BLE Permissions
- ✓ Device Control Feature
- ✓ Device Info Dialog
- ✓ Heart Rate Configuration UI
- 🔄 Notes Feature
- 🔄 Global Navigation

### Critical Implementation Gaps
1. Database Service
- Need to implement core CRUD operations with HIPAA compliance
- Migration to feature-specific repositories needed
- Local storage encryption required
- Secure heart rate data storage needed

2. Dialog Parameter Standardization
- ✓ Duration selection dialog parameters standardized
- ✓ Heart rate threshold dialog parameters aligned
- ✓ Device info dialog implementation completed
- Remaining dialog implementations need review

3. Testing Strategy
- BLoC tests needed for implemented features
- UI component testing framework needed
- E2E testing strategy required
- Security testing plan needed

### Architecture Notes
1. State Management
- Using BLoC pattern for feature-level state
- ChangeNotifier for model-level state
- Equatable for state comparison

2. BLE Implementation
- Singleton service pattern
- Modern FlutterBluePlus API usage
- Persistent connection management
- Standardized BLE constants implementation
- Timeout handling implemented

3. Feature Organization
- Feature-first architecture
- Shared core services
- Feature-specific repositories
- Secure data handling patterns

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
- HIPAA-compliant storage implementation
- Remaining dialog parameter standardization
- Secure heart rate data handling

2. 🔄 In Progress
- Feature-first architecture migration
- Global state management
- Navigation system
- Dialog parameters alignment

3. 📋 Planned
- Analytics integration
- Logging system
- Comprehensive testing
- Security audit implementation

### Security Considerations
- All BLE operations must implement timeout handling
- Database operations must handle transaction failures
- Device settings must validate before persistence
- BLE scanning must respect permission states
- Heart rate data must be handled securely
- HIPAA compliance required for health data storage
- All health data must be encrypted at rest
- Secure transmission protocols needed for health data

## VERSION CONTROL
Document Version: 2.2
Last Updated: 2024-11-26