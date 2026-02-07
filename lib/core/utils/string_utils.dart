import 'package:html/parser.dart' show parse;

class StringUtils {
  /// Converts HTML content into clean, readable plain text.
  /// 
  /// This function removes all HTML tags while preserving line breaks
  /// from <br>, <p>, and <div> tags. It also handles HTML entities
  /// like &nbsp; and &amp; automatically.
  static String htmlToPlainText(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) return '';

    // 1. Pre-process block-level tags to preserve structure
    // We add a newline before/after these tags so that text doesn't merge
    String processed = htmlString
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li>', caseSensitive: false), '\n• ')
        .replaceAll(RegExp(r'</h1>|</h2>|</h3>|</h4>|</h5>|</h6>', caseSensitive: false), '\n');

    // 2. Parse the HTML document
    final document = parse(processed);
    
    // 3. Extract text content (this automatically strips remaining tags and decodes entities)
    String text = document.body?.text ?? '';

    // 4. Final cleanup
    // - Split into lines to trim each line individually
    // - Join back while limiting excessive consecutive newlines
    return text.split('\n').map((line) => line.trim()).join('\n').trim();
  }
}
