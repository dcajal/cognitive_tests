import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sprintf/sprintf.dart';

import '../interfaces/test_result_handler.dart';
import '../models/test_results.dart';

/// StroopTest - Stroop cognitive test
///
/// This class handles:
/// - Audio recording management (optional)
/// - Timestamp tracking
/// - File creation and management
/// - Test data persistence
class StroopTest {
  /// Total number of pages in the Stroop test (keep in sync with StroopViewer)
  static const int totalPages = 3;

  /// Handler for test results - can be any implementation of TestResultHandler
  final TestResultHandler? resultHandler;

  /// Whether to enable audio recording
  final bool enableAudioRecording;

  /// Constructor
  StroopTest({this.resultHandler, this.enableAudioRecording = true});

  /// Audio recorder for capturing user responses
  final AudioRecorder _recorder = AudioRecorder();

  /// List to store timestamps for each page transition
  List<int> timestamps = <int>[];

  /// File for storing audio recording (only if recording enabled)
  File? audioFile;

  /// Filename for the generated audio file
  String? audioFileName;

  /// Current page index (0-based). Starts at 0.
  int _testPage = 0;

  /// Get current test page
  int get testPage => _testPage;

  /// Whether current page is the last one
  bool get isLastPage => _testPage >= totalPages - 1;

  /// Initialize the audio recorder and request permissions
  Future<bool> initialize() async {
    if (!enableAudioRecording) {
      debugPrint('Audio recording disabled');
      return true;
    }

    // Check and request permissions if needed
    if (await _recorder.hasPermission()) {
      debugPrint('Audio recording permission granted');
      return true;
    } else {
      debugPrint('Audio recording permission denied');
      return false;
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _recorder.dispose();
  }

  /// Move to the next page and record timestamp
  void goToNextPage() {
    if (!isLastPage) {
      _testPage++;
      if (enableAudioRecording) {
        timestamps.add(DateTime.now().toUtc().millisecondsSinceEpoch);
      }
    }
  }

  /// Initializes and starts the Stroop test
  /// Creates necessary files and begins audio recording
  Future<void> startTest() async {
    final DateTime dt = DateTime.now();

    // Generate unique filename for audio recording if enabled
    if (enableAudioRecording) {
      audioFileName = sprintf(
        '%02i%02i%02i_%02i%02i%02i_stresstest_stroopaudio.wav',
        [dt.year % 100, dt.month, dt.day, dt.hour, dt.minute, dt.second],
      );

      // Create audio file in the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final pathWav = "${directory.path}/$audioFileName";
      audioFile = await File(pathWav).create();

      debugPrint('Saving audio file to: $pathWav');

      // Start audio recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: pathWav,
      );
    } else {
      debugPrint('Audio recording disabled - timestamps will not be saved');
    }

    // Record the test start timestamp only if audio recording is enabled
    if (enableAudioRecording) {
      timestamps.add(DateTime.now().toUtc().millisecondsSinceEpoch);
    }
  }

  /// Finishes the Stroop test
  /// Stops recording, saves data, and handles file upload
  Future<void> finishTest(BuildContext context) async {
    // Stop audio recording if it was enabled
    if (enableAudioRecording) {
      await _recorder.stop();
    }

    // Record the test end timestamp only if audio recording is enabled
    if (enableAudioRecording) {
      timestamps.add(DateTime.now().toUtc().millisecondsSinceEpoch);
    }

    // Create result object and call handler if provided
    if (resultHandler != null) {
      final result = StroopTestResult(
        audioFile: audioFile,
        audioFilename: audioFileName,
        timestamps: timestamps,
        audioRecordingEnabled: enableAudioRecording,
        testDate: DateTime.now(),
      );

      if (context.mounted) {
        await resultHandler!.handleStroopTestResults(context, result);
      }
    }
  }
}
