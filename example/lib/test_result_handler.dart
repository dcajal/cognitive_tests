import 'package:flutter/material.dart';
import 'package:cognitive_tests/cognitive_tests.dart';

class MyTestResultHandler implements TestResultHandler {
  @override
  Future<void> handleStroopTestResults(
    BuildContext context,
    StroopTestResult result,
  ) async {
    // Process Stroop test results
    print('Stroop test completed in ${result.testDuration}ms');
    print('Page transitions: ${result.pageTransitions}');

    // Show results to user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stroop test completed!\n'
            'Duration: ${result.testDuration}ms\n'
            'Page transitions: ${result.pageTransitions}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

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

    // Show results to user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'TMT ${result.isPartA ? "Part A" : "Part B"} completed!\n'
            'Trace points: ${result.traces.length}',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Process gesture data: result.traces
    // Process timing data: result.unixTimestamps
  }
}
