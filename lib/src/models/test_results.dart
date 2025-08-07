import 'dart:io';
import 'package:flutter/material.dart';

/// Base class for all cognitive test results
abstract class TestResult {
  final DateTime testDate;
  final String testType;

  TestResult({
    required this.testDate,
    required this.testType,
  });
}

/// Results from the Stroop cognitive test
class StroopTestResult extends TestResult {
  final File? audioFile;
  final String? audioFilename;
  final List<int> timestamps;
  final bool audioRecordingEnabled;

  StroopTestResult({
    required this.audioFile,
    required this.audioFilename,
    required this.timestamps,
    required this.audioRecordingEnabled,
    required super.testDate,
  }) : super(testType: 'stroop');

  /// Duration of the test in milliseconds
  int get testDuration =>
      timestamps.isNotEmpty ? timestamps.last - timestamps.first : 0;

  /// Number of page transitions
  int get pageTransitions => timestamps.length > 2
      ? timestamps.length - 2 // Excluding start/end timestamps
      : 0;
}

/// Results from the Trail Making Test
class TrailMakingTestResult extends TestResult {
  final bool isPartA;
  final List<Offset?> traces;
  final List<int> unixTimestamps;

  TrailMakingTestResult({
    required this.isPartA,
    required this.traces,
    required this.unixTimestamps,
    required super.testDate,
  }) : super(testType: isPartA ? 'tmt_a' : 'tmt_b');
}
