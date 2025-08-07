import 'dart:async';

import 'package:flutter/material.dart';

import '../interfaces/test_result_handler.dart';
import '../models/test_results.dart';

/// TrailMakingTest - Contains the business logic for the Trail Making Test
///
/// This class handles:
/// - Gesture tracking and data collection
/// - Test state management (Part A and Part B)
/// - Coordinate transformation calculations
/// - Data processing and delegation to result handlers
class TrailMakingTest {
  /// Handler for test results - can be any implementation of TestResultHandler
  final TestResultHandler? resultHandler;

  /// Constructor
  TrailMakingTest({this.resultHandler});

  /// Gesture data collection
  final List<Offset?> localOffsets = <Offset?>[];
  final List<Offset?> globalOffsets = <Offset?>[];
  final List<int> unixTimestamps = <int>[];

  /// Timing tracking
  DateTime? _now;

  /// Test state
  bool _firstTest = true;

  /// Get current test state
  bool get isFirstTest => _firstTest;

  /// Get gesture data for painting
  List<Offset?> get paintingOffsets => localOffsets;

  /// Clear all gesture data
  void clearGestureData() {
    localOffsets.clear();
    globalOffsets.clear();
    unixTimestamps.clear();
    _now = null;
  }

  /// Move to the next test (from Part A to Part B)
  void moveToNextTest() {
    _firstTest = false;
  }

  /// Record a gesture point
  void recordGesture(Offset? localPosition, Offset? globalPosition) {
    localOffsets.add(localPosition);
    globalOffsets.add(globalPosition);
    _now = DateTime.now();
    unixTimestamps.add(_now!.toUtc().millisecondsSinceEpoch);
  }

  /// Finish the current test and pass data to handler
  Future<void> finishTest(BuildContext context, GlobalKey sheetKey) async {
    List<Offset?> traces = _getTraces(globalOffsets, sheetKey);

    // Create result object and call handler if provided
    if (resultHandler != null) {
      final result = TrailMakingTestResult(
        isPartA: _firstTest,
        traces: traces,
        unixTimestamps: unixTimestamps,
        testDate: DateTime.now(),
      );

      await resultHandler!.handleTrailMakingTestResults(context, result);
    }
  }

  /// Convert global coordinates to sheet-relative coordinates
  List<Offset?> _getTraces(List<Offset?> globalOffsets, GlobalKey sheetKey) {
    final RenderBox sheetRenderBox =
        sheetKey.currentContext!.findRenderObject() as RenderBox;
    final sheetOrigin = sheetRenderBox.localToGlobal(Offset.zero);
    final sheetSize = sheetRenderBox.size;

    List<Offset?> sheetOffsets = <Offset?>[];
    for (var offset in globalOffsets) {
      offset != null
          ? sheetOffsets.add((offset - sheetOrigin)
              .scale(1 / sheetSize.width, 1 / sheetSize.height))
          : sheetOffsets.add(null);
    }
    return sheetOffsets;
  }
}
