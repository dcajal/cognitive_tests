import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sprintf/sprintf.dart';

import '../interfaces/test_result_handler.dart';
import '../models/test_results.dart';
import '../models/stroop_languages.dart';

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
  late final List<StroopItem> _page0Words; // Congruent words in black ink
  late final List<StroopItem> _page1Colors; // Color patches only
  late final List<StroopItem> _page2Words; // Incongruent word-color pairs

  /// Public getters
  List<StroopItem> get page0Words => _page0Words;
  List<StroopItem> get page1Colors => _page1Colors;
  List<StroopItem> get page2Words => _page2Words;

  /// Audio recorder for capturing user responses (only created if recording enabled)
  AudioRecorder? _recorder;

  /// List to store timestamps for each page transition
  List<int> timestamps = <int>[];

  /// File for storing audio recording (only if recording enabled)
  File? audioFile;

  /// Filename for the generated audio file
  String? audioFileName;

  /// Current page index (0-based). Starts at 0.
  int _testPage = 0;

  /// Notifier for page changes - allows widgets to listen for updates
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);

  /// Get current test page
  int get testPage => _testPage;

  /// Get page notifier for listening to page changes
  ValueNotifier<int> get pageNotifier => _pageNotifier;

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
    await _recorder?.start(
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

    // Initialize the recorder only if audio recording is enabled
    _recorder = AudioRecorder();

    // Check and request permissions if needed
    if (await _recorder!.hasPermission()) {
      debugPrint('Audio recording permission granted');
      return true;
    } else {
      debugPrint('Audio recording permission denied');
      return false;
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _recorder?.dispose();
    _pageNotifier.dispose();
  }

  /// Move to the next page and record timestamp
  void goToNextPage() {
    if (!isLastPage) {
      _testPage++;
      _pageNotifier.value = _testPage;
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
      await _recorder?.stop();
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

  /// Generates sequences for all three pages with proper constraints
  void _generateItems() {
    const colors = [Colors.red, Colors.green, Colors.blue];
    final words = _getWordsForLanguage();

    final items = _generateStroopSequence(words.length, itemCount);

    // Page 0: Words in black ink
    _page0Words = items
        .map((item) => StroopItem.word(words[item.$1], Colors.black))
        .toList();

    // Page 1: Color patches only
    _page1Colors =
        items.map((item) => StroopItem.colorOnly(colors[item.$2])).toList();

    // Page 2: Incongruent word-color pairs
    _page2Words = items
        .map((item) => StroopItem.word(words[item.$1], colors[item.$2]))
        .toList();
  }

  /// Generates a sequence of word-color pairs that satisfy all constraints:
  /// - No consecutive identical words
  /// - No consecutive identical colors
  /// - Word and color are never congruent (same index)
  List<(int wordIdx, int colorIdx)> _generateStroopSequence(
      int wordCount, int length) {
    if (length <= 0) return const <(int, int)>[];

    const colorCount = 3; // red, green, blue
    final sequence = <(int, int)>[];
    int? lastWordIdx;
    int? lastColorIdx;

    for (int i = 0; i < length; i++) {
      // Generate available word choices (excluding last word)
      final availableWords = <int>[];
      for (int w = 0; w < wordCount; w++) {
        if (lastWordIdx == null || w != lastWordIdx) {
          availableWords.add(w);
        }
      }

      // Choose random word
      final wordIdx = availableWords[_rng.nextInt(availableWords.length)];

      // Generate available color choices (excluding last color and congruent color)
      final availableColors = <int>[];
      for (int c = 0; c < colorCount; c++) {
        if ((lastColorIdx == null || c != lastColorIdx) && c != wordIdx) {
          availableColors.add(c);
        }
      }

      // If no valid colors (edge case), allow same as last but not congruent
      int colorIdx;
      if (availableColors.isEmpty) {
        final fallbackColors = <int>[];
        for (int c = 0; c < colorCount; c++) {
          if (c != wordIdx) {
            fallbackColors.add(c);
          }
        }
        colorIdx = fallbackColors[_rng.nextInt(fallbackColors.length)];
      } else {
        colorIdx = availableColors[_rng.nextInt(availableColors.length)];
      }

      sequence.add((wordIdx, colorIdx));
      lastWordIdx = wordIdx;
      lastColorIdx = colorIdx;
    }

    return sequence;
  }

  /// Get words based on selected language
  List<String> _getWordsForLanguage() {
    return StroopLanguageWords.getWordsForLanguage(language);
  }
}

/// Unified class for all Stroop test items
class StroopItem {
  final String? text; // null for color-only items
  final Color color;

  /// Private constructor
  StroopItem._(this.text, this.color);

  /// Factory for word items (with text and color)
  factory StroopItem.word(String text, Color color) =>
      StroopItem._(text, color);

  /// Factory for color-only items (no text)
  factory StroopItem.colorOnly(Color color) => StroopItem._(null, color);

  /// Whether this item has text (word) or is color-only
  bool get isWordItem => text != null;
  bool get isColorOnly => text == null;
}
