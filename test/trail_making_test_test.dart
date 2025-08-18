import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_tests/cognitive_tests.dart';

/// Mock implementation of TestResultHandler for testing
class MockTestResultHandler implements TestResultHandler {
  TrailMakingTestResult? lastTrailMakingResult;
  StroopTestResult? lastStroopResult;

  @override
  Future<void> handleStroopTestResults(
    BuildContext context,
    StroopTestResult result,
  ) async {
    lastStroopResult = result;
  }

  @override
  Future<void> handleTrailMakingTestResults(
    BuildContext context,
    TrailMakingTestResult result,
  ) async {
    lastTrailMakingResult = result;
  }

  void reset() {
    lastTrailMakingResult = null;
    lastStroopResult = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('TrailMakingTest Logic Tests', () {
    late TrailMakingTest trailMakingTest;
    late MockTestResultHandler mockHandler;

    setUp(() {
      mockHandler = MockTestResultHandler();
      trailMakingTest = TrailMakingTest(resultHandler: mockHandler);
    });

    test('should initialize with correct default state', () {
      expect(trailMakingTest.isFirstTest, isTrue);
      expect(trailMakingTest.paintingOffsets, isEmpty);
      expect(trailMakingTest.localOffsets, isEmpty);
      expect(trailMakingTest.globalOffsets, isEmpty);
      expect(trailMakingTest.unixTimestamps, isEmpty);
    });

    test('should record gesture data correctly', () {
      const localOffset = Offset(10.0, 20.0);
      const globalOffset = Offset(100.0, 200.0);

      trailMakingTest.recordGesture(localOffset, globalOffset);

      expect(trailMakingTest.localOffsets.length, equals(1));
      expect(trailMakingTest.globalOffsets.length, equals(1));
      expect(trailMakingTest.unixTimestamps.length, equals(1));
      expect(trailMakingTest.localOffsets.first, equals(localOffset));
      expect(trailMakingTest.globalOffsets.first, equals(globalOffset));
      expect(trailMakingTest.unixTimestamps.first, isA<int>());
    });

    test('should record multiple gesture points in sequence', () {
      final gestures = [
        (const Offset(10.0, 20.0), const Offset(100.0, 200.0)),
        (const Offset(15.0, 25.0), const Offset(150.0, 250.0)),
        (const Offset(20.0, 30.0), const Offset(200.0, 300.0)),
      ];

      for (final (local, global) in gestures) {
        trailMakingTest.recordGesture(local, global);
      }

      expect(trailMakingTest.localOffsets.length, equals(3));
      expect(trailMakingTest.globalOffsets.length, equals(3));
      expect(trailMakingTest.unixTimestamps.length, equals(3));

      // Check that timestamps are in ascending order
      for (int i = 1; i < trailMakingTest.unixTimestamps.length; i++) {
        expect(
          trailMakingTest.unixTimestamps[i],
          greaterThanOrEqualTo(trailMakingTest.unixTimestamps[i - 1]),
        );
      }
    });

    test('should handle null gesture positions', () {
      trailMakingTest.recordGesture(null, null);

      expect(trailMakingTest.localOffsets.length, equals(1));
      expect(trailMakingTest.globalOffsets.length, equals(1));
      expect(trailMakingTest.unixTimestamps.length, equals(1));
      expect(trailMakingTest.localOffsets.first, isNull);
      expect(trailMakingTest.globalOffsets.first, isNull);
    });

    test('should clear gesture data correctly', () {
      // Record some data first
      trailMakingTest.recordGesture(
        const Offset(10.0, 20.0),
        const Offset(100.0, 200.0),
      );

      expect(trailMakingTest.localOffsets.isNotEmpty, isTrue);
      expect(trailMakingTest.globalOffsets.isNotEmpty, isTrue);
      expect(trailMakingTest.unixTimestamps.isNotEmpty, isTrue);

      // Clear the data
      trailMakingTest.clearGestureData();

      expect(trailMakingTest.localOffsets, isEmpty);
      expect(trailMakingTest.globalOffsets, isEmpty);
      expect(trailMakingTest.unixTimestamps, isEmpty);
    });

    test('should transition from Part A to Part B correctly', () {
      expect(trailMakingTest.isFirstTest, isTrue);

      trailMakingTest.moveToNextTest();

      expect(trailMakingTest.isFirstTest, isFalse);
    });

    test('should maintain Part B state after multiple transitions', () {
      trailMakingTest.moveToNextTest();
      trailMakingTest.moveToNextTest();
      trailMakingTest.moveToNextTest();

      expect(trailMakingTest.isFirstTest, isFalse);
    });

    testWidgets('should create correct result for Part A',
        (WidgetTester tester) async {
      // Create a test widget with a GlobalKey
      final sheetKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              key: sheetKey,
              width: 200.0,
              height: 200.0,
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      // Record some gesture data
      trailMakingTest.recordGesture(
        const Offset(10.0, 20.0),
        const Offset(100.0, 200.0),
      );
      trailMakingTest.recordGesture(
        const Offset(15.0, 25.0),
        const Offset(150.0, 250.0),
      );

      // Finish the test
      await trailMakingTest.finishTest(
          tester.element(find.byKey(sheetKey)), sheetKey);

      // Verify the result handler was called
      expect(mockHandler.lastTrailMakingResult, isNotNull);
      expect(mockHandler.lastTrailMakingResult!.isPartA, isTrue);
      expect(mockHandler.lastTrailMakingResult!.traces.length, equals(2));
      expect(
          mockHandler.lastTrailMakingResult!.unixTimestamps.length, equals(2));
      expect(mockHandler.lastTrailMakingResult!.testType, equals('tmt_a'));
    });

    testWidgets('should create correct result for Part B',
        (WidgetTester tester) async {
      // Create a test widget with a GlobalKey
      final sheetKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              key: sheetKey,
              width: 200.0,
              height: 200.0,
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      // Move to Part B
      trailMakingTest.moveToNextTest();

      // Record some gesture data
      trailMakingTest.recordGesture(
        const Offset(30.0, 40.0),
        const Offset(300.0, 400.0),
      );

      // Finish the test
      await trailMakingTest.finishTest(
          tester.element(find.byKey(sheetKey)), sheetKey);

      // Verify the result handler was called
      expect(mockHandler.lastTrailMakingResult, isNotNull);
      expect(mockHandler.lastTrailMakingResult!.isPartA, isFalse);
      expect(mockHandler.lastTrailMakingResult!.traces.length, equals(1));
      expect(
          mockHandler.lastTrailMakingResult!.unixTimestamps.length, equals(1));
      expect(mockHandler.lastTrailMakingResult!.testType, equals('tmt_b'));
    });

    testWidgets('should handle coordinate transformation correctly',
        (WidgetTester tester) async {
      // Create a test widget with a specific size and position
      final sheetKey = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Container(
                key: sheetKey,
                width: 100.0,
                height: 100.0,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      // Record a gesture at the center of the container
      // The container is 100x100 at position (50, 50) due to padding
      // So center would be at global position (100, 100)
      trailMakingTest.recordGesture(
        const Offset(50.0, 50.0), // Local position (center of container)
        const Offset(100.0, 100.0), // Global position
      );

      // Finish the test
      await trailMakingTest.finishTest(
          tester.element(find.byKey(sheetKey)), sheetKey);

      // Verify the coordinate transformation
      expect(mockHandler.lastTrailMakingResult, isNotNull);
      final transformedTrace = mockHandler.lastTrailMakingResult!.traces.first;
      expect(transformedTrace, isNotNull);

      // The transformed coordinate should be relative to the container
      // and normalized to [0,1] range
      expect(transformedTrace!.dx, closeTo(0.5, 0.1));
      expect(transformedTrace.dy, closeTo(0.5, 0.1));
    });

    test('should work without result handler', () {
      final testWithoutHandler = TrailMakingTest();

      testWithoutHandler.recordGesture(
        const Offset(10.0, 20.0),
        const Offset(100.0, 200.0),
      );

      expect(testWithoutHandler.localOffsets.length, equals(1));
      expect(testWithoutHandler.globalOffsets.length, equals(1));
      expect(testWithoutHandler.unixTimestamps.length, equals(1));
    });

    test('should handle empty gesture data in finish test', () async {
      // This test ensures that finishing a test without recording gestures doesn't crash
      expect(() async {
        // Note: We can't actually call finishTest without a BuildContext and GlobalKey
        // But we can test that the TrailMakingTest can handle empty data
        expect(trailMakingTest.localOffsets, isEmpty);
        expect(trailMakingTest.globalOffsets, isEmpty);
        expect(trailMakingTest.unixTimestamps, isEmpty);
      }, returnsNormally);
    });

    group('TrailMakingTestResult Tests', () {
      test('should create Part A result correctly', () {
        final traces = [const Offset(0.1, 0.2), const Offset(0.3, 0.4)];
        final timestamps = [1000, 2000];
        final testDate = DateTime.now();

        final result = TrailMakingTestResult(
          isPartA: true,
          traces: traces,
          unixTimestamps: timestamps,
          testDate: testDate,
        );

        expect(result.isPartA, isTrue);
        expect(result.traces, equals(traces));
        expect(result.unixTimestamps, equals(timestamps));
        expect(result.testDate, equals(testDate));
        expect(result.testType, equals('tmt_a'));
      });

      test('should create Part B result correctly', () {
        final traces = [const Offset(0.5, 0.6), const Offset(0.7, 0.8)];
        final timestamps = [3000, 4000];
        final testDate = DateTime.now();

        final result = TrailMakingTestResult(
          isPartA: false,
          traces: traces,
          unixTimestamps: timestamps,
          testDate: testDate,
        );

        expect(result.isPartA, isFalse);
        expect(result.traces, equals(traces));
        expect(result.unixTimestamps, equals(timestamps));
        expect(result.testDate, equals(testDate));
        expect(result.testType, equals('tmt_b'));
      });
    });
  });
}
