/// Images placed *inside* an article's body (not the cover image) are
/// uploaded via `POST /articles/upload-image`, same as `cover_image`, and
/// the storage path returned by that endpoint is embedded directly inside
/// the `content` string wrapped in a simple marker. This keeps `content`
/// as plain text while still preserving exactly where each image was
/// inserted, and lets it be resolved back into a real image URL when the
/// article is displayed.
library article_content_parser;

class ArticleContentBlock {
  final bool isImage;
  final String data; // plain text OR an image's storage path

  const ArticleContentBlock.text(this.data) : isImage = false;
  const ArticleContentBlock.image(this.data) : isImage = true;
}

class ArticleContentParser {
  static const String _openTag = '[[IMG:';
  static const String _closeTag = ']]';

  /// Wraps an uploaded image's storage path in the inline marker so it
  /// can be embedded inside an article's `content` string.
  static String imageMarker(String storagePath) => '$_openTag$storagePath$_closeTag';

  /// Splits a raw article `content` string into an ordered list of text
  /// and image blocks, preserving the position images were inserted at.
  static List<ArticleContentBlock> parse(String content) {
    final blocks = <ArticleContentBlock>[];
    if (content.isEmpty) return blocks;

    final pattern = RegExp(
      '${RegExp.escape(_openTag)}(.*?)${RegExp.escape(_closeTag)}',
      dotAll: true,
    );

    int lastEnd = 0;
    for (final match in pattern.allMatches(content)) {
      if (match.start > lastEnd) {
        final text = content.substring(lastEnd, match.start).trim();
        if (text.isNotEmpty) blocks.add(ArticleContentBlock.text(text));
      }

      final imagePathData = match.group(1)?.trim() ?? '';
      if (imagePathData.isNotEmpty) {
        blocks.add(ArticleContentBlock.image(imagePathData));
      }

      lastEnd = match.end;
    }

    if (lastEnd < content.length) {
      final text = content.substring(lastEnd).trim();
      if (text.isNotEmpty) blocks.add(ArticleContentBlock.text(text));
    }

    return blocks;
  }
}