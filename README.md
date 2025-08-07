# Cognitive Tests

[![Platform](https://img.shields.io/badge/platform-flutter-blue)](https://flutter.dev)
[![iOS](https://img.shields.io/badge/iOS-supported-green)](https://developer.apple.com/ios/)
[![Android](https://img.shields.io/badge/Android-supported-green)](https://developer.android.com/)

A Flutter library for implementing and managing cognitive tests commonly used in neuropsychological assessments. This package provides implementations of the Stroop Test and Trail Making Test with built-in data collection, audio recording capabilities, and customizable result handling.

## Features

- **Stroop Test**: Implementation of the classic Stroop cognitive test with:
  - Optional audio recording of participant responses
  - Timestamp tracking for performance analysis
  - Page transition monitoring
  - Configurable audio recording settings

- **Trail Making Test**: Digital implementation supporting both Part A and Part B with:
  - Gesture tracking and coordinate recording
  - Real-time drawing capabilities
  - High-precision timestamp collection
  - Coordinate transformation for different screen sizes

- **Flexible Result Handling**: Customizable result processing through the `TestResultHandler` interface
- **Data Export**: Built-in support for saving test data and audio files
- **Performance Metrics**: Automatic calculation of test duration and other performance indicators

## Getting started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher

### Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  cognitive_tests: ^0.1.0
```

### Permissions

For audio recording functionality (Stroop Test), you'll need to add the appropriate permissions:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone to record audio during cognitive tests.</string>
```

## Usage

### Basic Implementation

First, import the package:

```dart
import 'package:cognitive_tests/cognitive_tests.dart';
```

### Implementing a Custom Result Handler

Create a class that implements `TestResultHandler`:

```dart
class MyTestResultHandler implements TestResultHandler {
  @override
  Future<void> handleStroopTestResults(
    BuildContext context,
    StroopTestResult result,
  ) async {
    // Process Stroop test results
    print('Stroop test completed in ${result.testDuration}ms');
    print('Page transitions: ${result.pageTransitions}');
    
    // Save or upload results as needed
    // Access audio file: result.audioFile
    // Access timestamps: result.timestamps
  }

  @override
  Future<void> handleTrailMakingTestResults(
    BuildContext context,
    TrailMakingTestResult result,
  ) async {
    // Process Trail Making test results
    print('TMT ${result.isPartA ? "Part A" : "Part B"} completed');
    print('Number of trace points: ${result.traces.length}');
    
    // Process gesture data: result.traces
    // Process timing data: result.unixTimestamps
  }
}
```

### Examples

For complete implementation examples, see the [examples directory](example/).


## Additional Information

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Issues

If you encounter any issues or have feature requests, please file them on the [GitHub repository](https://github.com/dcajal/cognitive_tests/issues).

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.