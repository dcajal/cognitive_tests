import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sprintf/sprintf.dart';

import '../interfaces/test_result_handler.dart';
import '../models/test_results.dart';

/// Supported languages for the Stroop Test
enum StroopLanguage { english, spanish }

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

  /// Number of items per page (words or color patches). Default 100.
  final int itemCount;

  /// Language for displayed words.
  final StroopLanguage language;

  /// Random generator (can be injected for reproducibility in tests).
  final Random _rng;

  /// Constructor
  StroopTest({
    this.resultHandler,
    this.enableAudioRecording = true,
    this.itemCount = 100,
    this.language = StroopLanguage.english,
    Random? random,
  }) : _rng = random ?? Random();

  /// Stroop Data
  late final List<StroopWordItem> _page0Words; // Congruent words in black ink
  late final List<StroopColorItem> _page1Colors; // Color patches only
  late final List<StroopWordItem> _page2Words; // Incongruent word-color pairs

  /// Public getters
  List<StroopWordItem> get page0Words => _page0Words;
  List<StroopColorItem> get page1Colors => _page1Colors;
  List<StroopWordItem> get page2Words => _page2Words;

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

  /// Helper method to add timestamp if audio recording is enabled
  void _addTimestamp() {
    if (enableAudioRecording) {
      timestamps.add(DateTime.now().toUtc().millisecondsSinceEpoch);
    }
  }

  /// Helper method to setup audio recording file
  Future<void> _setupAudioFile(DateTime dt) async {
    audioFileName = sprintf(
      '%02i%02i%02i_%02i%02i%02i_stresstest_stroopaudio.wav',
      [dt.year % 100, dt.month, dt.day, dt.hour, dt.minute, dt.second],
    );

    final directory = await getApplicationDocumentsDirectory();
    final pathWav = "${directory.path}/$audioFileName";
    audioFile = await File(pathWav).create();

    debugPrint('Saving audio file to: $pathWav');
  }

  /// Helper method to start audio recording
  Future<void> _startAudioRecording(String pathWav) async {
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: pathWav,
    );
  }

  /// Initialize the audio recorder and request permissions
  Future<bool> initialize() async {
    _generateItems();
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
      _addTimestamp();
    }
  }

  /// Initializes and starts the Stroop test
  /// Creates necessary files and begins audio recording
  Future<void> startTest() async {
    final DateTime dt = DateTime.now();

    if (enableAudioRecording) {
      await _setupAudioFile(dt);
      await _startAudioRecording(
          "${(await getApplicationDocumentsDirectory()).path}/$audioFileName");
    } else {
      debugPrint('Audio recording disabled - timestamps will not be saved');
    }

    _addTimestamp();
  }

  /// Finishes the Stroop test
  /// Stops recording, saves data, and handles file upload
  Future<void> finishTest(BuildContext context) async {
    if (enableAudioRecording) {
      await _recorder.stop();
    }

    _addTimestamp();

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

  /// Generates a sequence with no identical consecutive items
  List<int> _generateSequenceNoAdjacent(int categories, int length) {
    if (categories <= 0 || length <= 0) return const <int>[];
    if (categories == 1) return List.filled(length, 0);

    final sequence = <int>[];
    int lastChoice = -1;

    for (int i = 0; i < length; i++) {
      List<int> availableChoices = List.generate(categories, (index) => index);
      if (lastChoice != -1) {
        availableChoices.remove(lastChoice);
      }

      final choice = availableChoices[_rng.nextInt(availableChoices.length)];
      sequence.add(choice);
      lastChoice = choice;
    }

    return sequence;
  }

  /// Item generation
  void _generateItems() {
    const colors = [Colors.red, Colors.green, Colors.blue];
    final words = _getWordsForLanguage();

    final wordIndices = _generateSequenceNoAdjacent(words.length, itemCount);
    final colorIndices = _generateSequenceNoAdjacent(colors.length, itemCount);

    _page0Words = _generatePage0Words(words, wordIndices);
    _page1Colors = _generatePage1Colors(colors, colorIndices);
    _page2Words = _generatePage2Words(words, colors, wordIndices, colorIndices);
  }

  /// Get words based on selected language
  List<String> _getWordsForLanguage() {
    return switch (language) {
      StroopLanguage.english => ['RED', 'GREEN', 'BLUE'],
      StroopLanguage.spanish => ['ROJO', 'VERDE', 'AZUL'],
    };
  }

  /// Generate page 0: words in black ink
  List<StroopWordItem> _generatePage0Words(
      List<String> words, List<int> wordIndices) {
    return List.generate(
        itemCount, (i) => StroopWordItem(words[wordIndices[i]], Colors.black));
  }

  /// Generate page 1: color patches only
  List<StroopColorItem> _generatePage1Colors(
      List<Color> colors, List<int> colorIndices) {
    return List.generate(
        itemCount, (i) => StroopColorItem(colors[colorIndices[i]]));
  }

  /// Generate page 2: incongruent word-color pairs
  List<StroopWordItem> _generatePage2Words(List<String> words,
      List<Color> colors, List<int> wordIndices, List<int> colorIndices) {
    return List.generate(itemCount, (i) {
      final wordIdx = wordIndices[i];
      final word = words[wordIdx];

      // Find a color that's different from the word's semantic color
      int colorIdx = colorIndices[i];
      if (colorIdx == wordIdx) {
        colorIdx = (colorIdx + 1) % colors.length;
      }

      return StroopWordItem(word, colors[colorIdx]);
    });
  }
}

class StroopWordItem {
  final String text;
  final Color color;
  StroopWordItem(this.text, this.color);
}

class StroopColorItem {
  final Color color;
  StroopColorItem(this.color);
}
