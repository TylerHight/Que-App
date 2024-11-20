# Que App

## Overview
Que App is a Flutter-based mobile application that works in conjunction with the Que Aromatherapy Necklace, a smart wearable device developed by Dr. Bimle. The app enables users to manage their aromatherapy experience through real-time heart rate monitoring and programmable scent delivery.

## Features
- **Manual Control**: Direct control of aromatherapy emissions through the app interface
- **Scheduled Release**: Timer-based programming for automated scent delivery
- **Biometric Triggers**: Heart rate threshold monitoring for automated response
    - Behavior reinforcement
    - Anxiety management
    - Custom trigger settings
- **Health Data Tracking**: Secure collection and storage of:
    - Heart rate patterns
    - Device usage statistics
    - Treatment efficacy data
- **Bluetooth Connectivity**: Seamless communication with:
    - Heart rate monitor
    - Aromatherapy necklace device

## Technical Requirements
- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- iOS 12.0+ / Android 6.0+
- Bluetooth Low Energy (BLE) capability
- Secure storage for health data

## Installation
1. Clone the repository:
```bash
git clone https://github.com/username/que_app.git
```

2. Install dependencies:
```bash
cd que_app
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Device Compatibility
### Heart Rate Monitor
- Supports standard BLE heart rate monitors
- Continuous heart rate monitoring capability
- Battery-efficient operation

### Que Aromatherapy Necklace
- Custom BLE-enabled aromatherapy device
- Programmable scent release mechanism
- Battery level monitoring
- Multiple scent cartridge support

## Privacy & Security
- End-to-end encryption for all data transmission
- HIPAA-compliant data storage
- Secure local storage of user preferences
- Optional anonymous usage analytics

## Architecture
The app follows a clean architecture pattern with:
- BLoC pattern for state management
- Repository pattern for data handling
- Service layer for device communication
- Secure storage implementation

## Development Status
- [ ] Core BLE communication
- [ ] Heart rate monitoring
- [ ] Necklace control interface
- [ ] Scheduled releases
- [ ] Data storage and analytics
- [ ] User authentication
- [ ] Settings management

## License
Copyright (c) 2024 Dr. Bimle / Que Aromatherapy
This software and associated documentation files (the "Software") are proprietary and confidential.
All rights are reserved. The Software may only be used in conjunction with an authorized Que Aromatherapy Necklace
and may not be copied, modified, merged, published, distributed, sublicensed, or sold without explicit
written permission from Dr. Bimle / Que Aromatherapy.
This Software incorporates third-party open source software components, each of which retains its own license.

## Contact
Tyler Hight - Developer
email: highttyler@gmail.com

Dr. Bimle - Owner
cpbimle@gmail.com