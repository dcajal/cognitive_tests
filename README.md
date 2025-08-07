# Cognitive Tests

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

### Stroop Test Example

```dart
class StroopTestWidget extends StatefulWidget {
  @override
  _StroopTestWidgetState createState() => _StroopTestWidgetState();
}

class _StroopTestWidgetState extends State<StroopTestWidget> {
  late StroopTest stroopTest;

  @override
  void initState() {
    super.initState();
    stroopTest = StroopTest(
      resultHandler: MyTestResultHandler(),
      enableAudioRecording: true, // Set to false to disable audio
    );
    _initializeTest();
  }

  Future<void> _initializeTest() async {
    final hasPermission = await stroopTest.initialize();
    if (hasPermission) {
      await stroopTest.startTest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stroop Test - Page ${stroopTest.testPage}')),
      body: Center(
        child: Column(
          children: [
            // Your Stroop test UI here
            ElevatedButton(
              onPressed: () => stroopTest.goToNextPage(),
              child: Text('Next Page'),
            ),
            ElevatedButton(
              onPressed: () => stroopTest.finishTest(context),
              child: Text('Finish Test'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    stroopTest.dispose();
    super.dispose();
  }
}
```

### Trail Making Test Example

```dart
class TrailMakingTestWidget extends StatefulWidget {
  @override
  _TrailMakingTestWidgetState createState() => _TrailMakingTestWidgetState();
}

class _TrailMakingTestWidgetState extends State<TrailMakingTestWidget> {
  late TrailMakingTest trailTest;
  final GlobalKey sheetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    trailTest = TrailMakingTest(resultHandler: MyTestResultHandler());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TMT ${trailTest.isFirstTest ? "Part A" : "Part B"}'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          trailTest.recordGesture(
            details.localPosition,
            details.globalPosition,
          );
          setState(() {}); // Trigger repaint
        },
        child: CustomPaint(
          key: sheetKey,
          painter: TrailPainter(trailTest.paintingOffsets),
          size: Size.infinite,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await trailTest.finishTest(context, sheetKey);
          if (trailTest.isFirstTest) {
            trailTest.moveToNextTest();
            trailTest.clearGestureData();
            setState(() {});
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}

class TrailPainter extends CustomPainter {
  final List<Offset?> offsets;
  
  TrailPainter(this.offsets);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < offsets.length - 1; i++) {
      if (offsets[i] != null && offsets[i + 1] != null) {
        canvas.drawLine(offsets[i]!, offsets[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

## API Reference

### Classes

- **`StroopTest`**: Main class for Stroop test implementation
- **`TrailMakingTest`**: Main class for Trail Making test implementation
- **`TestResultHandler`**: Interface for custom result handling
- **`StroopTestResult`**: Data model for Stroop test results
- **`TrailMakingTestResult`**: Data model for Trail Making test results

### Key Methods

- `StroopTest.initialize()`: Initialize test and request permissions
- `StroopTest.startTest()`: Begin the test and start recording
- `StroopTest.goToNextPage()`: Record page transition
- `StroopTest.finishTest()`: Complete test and process results
- `TrailMakingTest.recordGesture()`: Record gesture coordinates
- `TrailMakingTest.finishTest()`: Complete test and process results

## Additional Information

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Issues

If you encounter any issues or have feature requests, please file them on the [GitHub repository](https://github.com/dcajal/cognitive_tests/issues).

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Acknowledgments

This package implements standard neuropsychological tests commonly used in cognitive assessment research and clinical practice.
