/// Input Sanitizer for preventing injection attacks and malformed payloads.
abstract final class InputSanitizer {
  /// Strips control characters, dangerous script tags, and excessive whitespace.
  static String sanitizeText(String input) {
    var text = input.trim();
    // Remove control characters (ASCII 0-31, except newline and tab)
    text = text.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
    // Strip HTML/Script tags to prevent stored script injection
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    return text;
  }

  /// Sanitizes search queries for safe matching.
  static String sanitizeQuery(String input) {
    return sanitizeText(input).replaceAll(RegExp(r'[^\w\s\-\.]'), '');
  }
}
