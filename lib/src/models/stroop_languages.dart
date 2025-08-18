/// Stroop Test Language Support
///
/// This file contains the color word translations for use in the Stroop
/// cognitive test.
library;

/// Supported languages for the Stroop Test
enum StroopLanguage {
  english,
  chinese,
  hindi,
  spanish,
  french,
  arabic,
  bengali,
  russian,
  portuguese,
  urdu,
  japanese,
  korean,
  german,
  turkish,
  italian,
}

/// Color words for each supported language
/// Maps each language to the words for RED, GREEN, and BLUE
class StroopLanguageWords {
  static const Map<StroopLanguage, List<String>> words = {
    StroopLanguage.english: ['RED', 'GREEN', 'BLUE'],
    StroopLanguage.chinese: ['红色', '绿色', '蓝色'],
    StroopLanguage.hindi: ['लाल', 'हरा', 'नीला'],
    StroopLanguage.spanish: ['ROJO', 'VERDE', 'AZUL'],
    StroopLanguage.french: ['ROUGE', 'VERT', 'BLEU'],
    StroopLanguage.arabic: ['أحمر', 'أخضر', 'أزرق'],
    StroopLanguage.bengali: ['লাল', 'সবুজ', 'নীল'],
    StroopLanguage.russian: ['КРАСНЫЙ', 'ЗЕЛЁНЫЙ', 'СИНИЙ'],
    StroopLanguage.portuguese: ['VERMELHO', 'VERDE', 'AZUL'],
    StroopLanguage.urdu: ['سرخ', 'سبز', 'نیلا'],
    StroopLanguage.japanese: ['赤', '緑', '青'],
    StroopLanguage.korean: ['빨강', '초록', '파랑'],
    StroopLanguage.german: ['ROT', 'GRÜN', 'BLAU'],
    StroopLanguage.turkish: ['KIRMIZI', 'YEŞİL', 'MAVİ'],
    StroopLanguage.italian: ['ROSSO', 'VERDE', 'BLU'],
  };

  /// Get color words for a specific language
  static List<String> getWordsForLanguage(StroopLanguage language) {
    return words[language] ?? words[StroopLanguage.english]!;
  }
}
