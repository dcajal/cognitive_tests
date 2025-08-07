import 'package:flutter/material.dart';
import '../models/test_results.dart';

/// Interface for handling cognitive test results
abstract class TestResultHandler {
  /// Handles results from Stroop Test
  Future<void> handleStroopTestResults(
    BuildContext context,
    StroopTestResult result,
  );

  /// Handles results from Trail Making Test
  Future<void> handleTrailMakingTestResults(
    BuildContext context,
    TrailMakingTestResult result,
  );
}
