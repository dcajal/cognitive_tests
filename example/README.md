# Cognitive Tests Example

This example demonstrates how to use the `cognitive_tests` package to implement cognitive tests in a Flutter application.

## Features Demonstrated

- **Stroop Test Implementation**: Shows how to create a Stroop test with audio recording capabilities
- **Trail Making Test Implementation**: Demonstrates gesture tracking and drawing for the Trail Making Test
- **Custom Result Handling**: Example of implementing `TestResultHandler` to process test results
- **Permission Handling**: Shows how to handle audio recording permissions
- **UI Integration**: Complete UI examples for both tests

## Getting Started

1. Ensure you have Flutter installed and set up
2. Navigate to the example directory:
   ```bash
   cd example
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the example:
   ```bash
   flutter run
   ```

## Files Overview

- `lib/main.dart`: Main app entry point with navigation
- `lib/test_result_handler.dart`: Custom implementation of `TestResultHandler`
- `lib/stroop_test_widget.dart`: Complete Stroop test implementation
- `lib/trail_making_test_widget.dart`: Complete Trail Making test implementation

## Permission Setup

For audio recording functionality on real devices, make sure to add the required permissions as described in the main package README:

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone to record audio during cognitive tests.</string>
```

## Usage

1. Launch the app
2. Choose either "Stroop Test" or "Trail Making Test"
3. Follow the on-screen instructions
4. View the results in the console output and snackbar notifications

This example provides a solid foundation for integrating cognitive tests into your Flutter applications.
