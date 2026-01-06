# Looksmaxxer - Flutter App

A facial tracking and analysis app with gamification features, converted from React to Flutter for native mobile deployment.

## Features

- **7 Facial Metrics Tracking**: Facial symmetry, proportional harmony, canthal tilt, skin texture, skin clarity, jaw definition, and cheekbone prominence
- **Daily Challenges**: Gamified system with categories for hydration, sleep, posture, skincare, and nutrition
- **Progress Scoring**: Unlockable after 14 days with weighted scoring based on consistency, challenges, quality, and improvement
- **Photo Timeline**: Visual history of captured photos with confidence indicators
- **Baseline Comparison**: Track changes from your established baseline metrics
- **Quality Validation**: Real-time feedback on photo brightness, contrast, and sharpness

## Project Structure

```
flutter_app/
├── lib/
│   ├── core/
│   │   ├── constants/      # App constants, metric configurations
│   │   ├── theme/          # Colors, typography, spacing, theme data
│   │   └── utils/          # Helper utilities
│   ├── data/
│   │   ├── models/         # Data models (Photo, AppState, Challenge)
│   │   ├── repositories/   # Data repositories
│   │   └── services/       # Database & preferences services
│   ├── engine/
│   │   ├── analysis_engine.dart    # Metric analysis
│   │   └── quality_validator.dart  # Photo quality validation
│   ├── game/
│   │   ├── scoring_engine.dart     # Progress scoring
│   │   └── anti_cheat.dart         # Rate limiting & validation
│   ├── presentation/
│   │   ├── screens/        # App screens
│   │   └── widgets/        # Reusable widgets
│   ├── providers/          # Riverpod state management
│   ├── app.dart            # Main app with navigation
│   └── main.dart           # Entry point
├── android/                # Android configuration
├── ios/                    # iOS configuration
├── codemagic.yaml          # CI/CD configuration
└── pubspec.yaml            # Dependencies
```

## Setup Instructions

### Prerequisites

- Flutter SDK (>= 3.2.0)
- Dart SDK (>= 3.2.0)
- Android Studio / Xcode
- Physical device or emulator with camera support

### Installation

1. **Clone and navigate to the Flutter project:**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code generation (if using Riverpod generator):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run on device:**
   ```bash
   # Android
   flutter run -d android

   # iOS
   flutter run -d ios
   ```

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## Codemagic Deployment

The project includes a `codemagic.yaml` configuration with four workflows:

1. **ios-production**: Builds and deploys to App Store Connect / TestFlight
2. **android-production**: Builds and deploys to Google Play (internal track)
3. **development**: Triggered on develop/feature branches for testing
4. **pull-request**: Validates PRs with formatting, analysis, and tests

### Setting Up Codemagic

1. Connect your repository to Codemagic
2. Configure the following:
   - **iOS**: App Store Connect API key and provisioning profiles
   - **Android**: Upload keystore and configure signing
   - **Email**: Update recipient email addresses in `codemagic.yaml`

3. Add environment variables:
   - `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` for Google Play deployment
   - Signing credentials will be configured via Codemagic UI

## Migration Notes (React to Flutter)

### Architecture Mapping

| React | Flutter |
|-------|---------|
| React hooks (`useState`, `useEffect`) | Riverpod providers |
| IndexedDB (`idb`) | SQLite (`sqflite`) |
| localStorage | SharedPreferences |
| Framer Motion | flutter_animate |
| Tailwind CSS | Custom ThemeData |
| lucide-react | lucide_icons |
| React Router | Screen-based navigation |

### Key Differences

1. **State Management**: React hooks replaced with Riverpod for scalable state management with provider composition.

2. **Storage**:
   - Photos stored in SQLite database (vs IndexedDB)
   - App state stored in SharedPreferences (vs localStorage)
   - Both maintain the same data structure

3. **Animations**: Framer Motion spring animations translated to flutter_animate with equivalent spring physics.

4. **Styling**: Tailwind utility classes converted to Flutter's theme system with matching color palette and typography scale.

5. **Camera**: Native camera implementation using the `camera` package for better performance.

### Feature Parity Checklist

- [x] Onboarding flow (Welcome, Capture Rules, Initial Photo)
- [x] 7 facial metrics with expandable details
- [x] Quality validation (brightness, contrast, sharpness)
- [x] Progress score with unlock requirements
- [x] Daily challenges with 5 categories
- [x] Challenge streak tracking
- [x] Photo timeline with grid view
- [x] Baseline metrics with confidence bands
- [x] Profile with stats and settings
- [x] Anti-cheat rate limiting
- [x] Dark theme matching original design
- [x] Haptic feedback support
- [x] All animations preserved

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.4.9 | State management |
| sqflite | ^2.3.2 | Local database |
| shared_preferences | ^2.2.2 | Key-value storage |
| camera | ^0.10.5+9 | Camera capture |
| image | ^4.1.7 | Image processing |
| flutter_animate | ^4.5.0 | Animations |
| lucide_icons | ^0.257.0 | Icon library |
| uuid | ^4.3.3 | ID generation |
| intl | ^0.19.0 | Date formatting |

## Assumptions & Clarifications

1. **Mock Analysis**: The analysis engine generates plausible metrics without actual ML face detection, matching the original React implementation.

2. **Offline-First**: App works entirely offline with local storage, no backend required.

3. **No Data Migration**: This is a fresh Flutter implementation; data from the React web app won't transfer automatically.

4. **Portrait Only**: App is locked to portrait orientation for consistent photo capture.

5. **iOS 12+ / Android 5.0+**: Minimum supported versions for camera and storage APIs.

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/analysis_engine_test.dart
```

## Contributing

1. Create a feature branch from `develop`
2. Make changes and add tests
3. Run `flutter analyze` and `dart format .`
4. Create a PR to `develop`

## License

Proprietary - All rights reserved
