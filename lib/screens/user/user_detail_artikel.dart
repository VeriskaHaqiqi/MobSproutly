import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/article_provider.dart';
import '../../models/article_model.dart';
import '../../utils/model_converter.dart';
import 'user_artikel.dart';
import 'user_pencarian.dart';

const Color dTealMain = Color(0xFF5DCFCF);
const Color dTeal = Color(0xFF76EAD0);
const Color dBlue = Color(0xFF76D7EA);
const Color dLGreen = Color(0xFFD0FF99);
const Color dGreen = Color(0xFF99FF99);

// No dummy content needed

class UserDetailArtikelScreen extends StatefulWidget {
  final ArticleItem article;

  const UserDetailArtikelScreen({super.key, required this.article});

  @override
  State<UserDetailArtikelScreen> createState() =>
      UserDetailArtikelScreenState();
}

class UserDetailArtikelScreenState extends State<UserDetailArtikelScreen> {
  bool get isBookmarked => widget.article.isBookmarked;

  void toggleBookmark() async {
    final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
    final realArticle = articleProvider.articles.firstWhere(
      (a) => a.id.toString() == widget.article.id,
      orElse: () => articleProvider.bookmarkedArticles.firstWhere(
        (a) => a.id.toString() == widget.article.id,
        orElse: () => Article(
          id: int.parse(widget.article.id),
          userId: 0,
          categoryId: 0,
          title: widget.article.title,
          content: widget.article.content,
          coverImage: widget.article.imageUrl,
          status: 'published',
          isBookmarked: widget.article.isBookmarked,
        ),
      ),
    );

    final success = await articleProvider.toggleBookmark(realArticle);
    if (success) {
      setState(() {
        widget.article.isBookmarked = realArticle.isBookmarked;
        if (realArticle.isBookmarked) {
          globalBookmarkedIds.add(widget.article.id);
        } else {
          globalBookmarkedIds.remove(widget.article.id);
        }
      });
    }
  }

  // Rekomendasi: artikel lain selain yang sedang dibuka,
  // prioritaskan kategori yang sama, max 5
  List<ArticleItem> get recommendedArticles {
    final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
    final rawArticles = articleProvider.articles;
    final converted = rawArticles.map((a) => ModelConverter.articleToItem(a)).toList();

    final sameCategory = converted
        .where((a) =>
            a.id != widget.article.id && a.category == widget.article.category)
        .toList();
    final others = converted
        .where((a) =>
            a.id != widget.article.id && a.category != widget.article.category)
        .toList();
    return [...sameCategory, ...others].take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category badge ──
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: dTeal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.article.category,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: dTealMain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Title ──
                  Text(
                    widget.article.title,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Author row ──
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: dTeal.withOpacity(0.3),
                        child: Text(
                          widget.article.author[0],
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              color: dTealMain,
                              fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.article.author,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            widget.article.time,
                            style: GoogleFonts.outfit(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 16),

                  // ── Article body ──
                  Text(
                    widget.article.content.isNotEmpty
                        ? widget.article.content
                        : 'No content available.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── CTA banner ──
                  buildCtaBanner(context),
                  const SizedBox(height: 32),

                  // ── Recommended Articles ──
                  buildRecommendedSection(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sliver App Bar ────────────────────────────────────────────────────────
  SliverAppBar buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: dTealMain,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: toggleBookmark,
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isBookmarked ? dTealMain : Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.article.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: dTeal.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: dTealMain),
                  ),
                );
              },
              errorBuilder: (ctx, e, s) => Container(
                color: dLGreen.withOpacity(0.3),
                child: Icon(Icons.eco_rounded,
                    color: Colors.green.shade300, size: 48),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CTA Banner ────────────────────────────────────────────────────────────
  Widget buildCtaBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [dLGreen, dGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need personalized advice?',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chat directly with a certified botanist expert for your specific plant problems.',
            style: GoogleFonts.outfit(
                fontSize: 12, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const UserPencarianScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Start Consultation',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recommended Articles ──────────────────────────────────────────────────
  Widget buildRecommendedSection(BuildContext context) {
    final recs = recommendedArticles;
    if (recs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'You Might Also Like',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'See All',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: dTealMain,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Horizontal scroll cards
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Negative horizontal padding to bleed to screen edge
            padding: const EdgeInsets.only(right: 4),
            physics: const BouncingScrollPhysics(),
            itemCount: recs.length,
            itemBuilder: (ctx, i) => buildRecCard(ctx, recs[i]),
          ),
        ),
      ],
    );
  }

  Widget buildRecCard(BuildContext context, ArticleItem article) {
    final isMarked = globalBookmarkedIds.contains(article.id);
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => UserDetailArtikelScreen(article: article),
        ),
      ),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    article.imageUrl,
                    height: 112,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, p) {
                      if (p == null) return child;
                      return Container(
                        height: 112,
                        color: dTeal.withOpacity(0.15),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: dTealMain,
                            value: p.expectedTotalBytes != null
                                ? p.cumulativeBytesLoaded /
                                    p.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, e, s) => Container(
                      height: 112,
                      color: dLGreen.withOpacity(0.3),
                      child: Icon(Icons.eco_rounded,
                          color: Colors.green.shade300, size: 32),
                    ),
                  ),
                ),
                // Bookmark icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isMarked) {
                          globalBookmarkedIds.remove(article.id);
                          article.isBookmarked = false;
                        } else {
                          globalBookmarkedIds.add(article.id);
                          article.isBookmarked = true;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isMarked
                            ? dTealMain
                            : Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      child: Icon(
                        isMarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        size: 15,
                        color: isMarked ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.category,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: dTealMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            article.author,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                                fontSize: 10, color: Colors.grey.shade500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('•',
                              style: GoogleFonts.outfit(
                                  fontSize: 10, color: Colors.grey.shade400)),
                        ),
                        Text(
                          article.time,
                          style: GoogleFonts.outfit(
                              fontSize: 10, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
