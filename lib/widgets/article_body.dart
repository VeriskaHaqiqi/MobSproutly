import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/article_content_parser.dart';
import '../utils/model_converter.dart';

/// Renders an article's `content` as a mix of text paragraphs and inline
/// images, in the same order the author inserted them while writing.
///
/// Inline images are embedded in `content` as a storage path (via
/// [ArticleContentParser]), the same convention already used for
/// `cover_image` -- so they're resolved into a full URL and rendered with
/// `Image.network` here.
class ArticleBody extends StatelessWidget {
  final String content;
  final TextStyle? textStyle;

  const ArticleBody({
    super.key,
    required this.content,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final style = textStyle ??
        GoogleFonts.outfit(
          fontSize: 14,
          color: Colors.black87,
          height: 1.75,
        );

    final blocks = ArticleContentParser.parse(content);

    if (blocks.isEmpty) {
      return Text('No content available.', style: style);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < blocks.length; i++) ...[
          if (blocks[i].isImage)
            _InlineArticleImage(path: blocks[i].data)
          else
            Text(blocks[i].data, style: style),
          if (i != blocks.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _InlineArticleImage extends StatelessWidget {
  final String path;

  const _InlineArticleImage({required this.path});

  String get _fullUrl {
    if (path.startsWith('http')) return path;
    return '${ModelConverter.getBaseUrl()}/storage/$path';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        _fullUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 180,
            color: Colors.grey.shade100,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (ctx, e, s) => Container(
          height: 120,
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: Icon(Icons.broken_image_outlined, color: Colors.grey.shade400),
        ),
      ),
    );
  }
}