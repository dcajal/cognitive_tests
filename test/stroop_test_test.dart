import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cognitive_tests/cognitive_tests.dart';
import 'dart:math';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StroopTest Logic Tests', () {
    test('should generate items without errors', () {
      final test = StroopTest(
        enableAudioRecording: false,
        itemCount: 10,
        language: StroopLanguage.english,
        random: Random(42), // Fixed seed for reproducibility
      );

      expect(() => test.initialize(), returnsNormally);
      expect(test.page0Words.length, equals(10));
      expect(test.page1Colors.length, equals(10));
      expect(test.page2Words.length, equals(10));
    });

    test('should have no adjacent identical words in page 0', () {
      final test = StroopTest(
        enableAudioRecording: false,
        itemCount: 20,
        language: StroopLanguage.english,
        random: Random(42),
      );

      test.initialize();

      for (int i = 1; i < test.page0Words.length; i++) {
        expect(
          test.page0Words[i].text,
          isNot(equals(test.page0Words[i - 1].text)),
          reason: 'Adjacent words should be different at position $i',
        );
      }
    });

    test('should have no adjacent identical colors in page 1', () {
      final test = StroopTest(
        enableAudioRecording: false,
        itemCount: 20,
        language: StroopLanguage.english,
        random: Random(42),
      );

      test.initialize();

      for (int i = 1; i < test.page1Colors.length; i++) {
        expect(
          test.page1Colors[i].color,
          isNot(equals(test.page1Colors[i - 1].color)),
          reason: 'Adjacent colors should be different at position $i',
        );
      }
    });

    test('should have incongruent word-color pairs in page 2', () {
      final test = StroopTest(
        enableAudioRecording: false,
        itemCount: 20,
        language: StroopLanguage.english,
        random: Random(42),
      );

      test.initialize();

      // Map colors to their semantic indices
      final Map<Color, int> colorToIndex = {
        Colors.red: 0,
        Colors.green: 1,
        Colors.blue: 2,
      };
      final words = ['RED', 'GREEN', 'BLUE'];

      for (final item in test.page2Words) {
        final wordIndex = words.indexOf(item.text!);
        final colorIndex = colorToIndex[item.color];

        expect(
          wordIndex,
          isNot(equals(colorIndex)),
          reason: 'Word "${item.text}" should not have its semantic color',
        );
      }
    });

    test('should support multilanguage', () {
      final test = StroopTest(
        enableAudioRecording: false,
        itemCount: 10,
        language: StroopLanguage.spanish,
        random: Random(42),
      );

      test.initialize();

      final spanishWords = ['ROJO', 'VERDE', 'AZUL'];
      for (final item in test.page0Words) {
        expect(spanishWords.contains(item.text), isTrue);
      }
    });

    test('should handle page navigation correctly', () {
      final test = StroopTest(
        enableAudioRecording: false,
        itemCount: 10,
      );

      test.initialize();

      expect(test.testPage, equals(0));
      expect(test.isLastPage, isFalse);

      test.goToNextPage();
      expect(test.testPage, equals(1));
      expect(test.isLastPage, isFalse);

      test.goToNextPage();
      expect(test.testPage, equals(2));
      expect(test.isLastPage, isTrue);

      // Should not go beyond last page
      test.goToNextPage();
      expect(test.testPage, equals(2));
    });
  });
}
