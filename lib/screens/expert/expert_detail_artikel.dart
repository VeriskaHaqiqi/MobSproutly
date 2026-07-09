import 'dart:io' as dartio;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'expert_artikel.dart';
import 'package:provider/provider.dart';
import '../../providers/article_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/model_converter.dart';
import '../../utils/image_helper.dart';
import '../../widgets/article_body.dart';
const Color kExDetMain = Color(0xFF5DCFCF);
const Color kExDetTeal = Color(0xFF76EAD0);
const Color kExDetBlue = Color(0xFF76D7EA);
const Color kExDetLGreen = Color(0xFFD0FF99);
const Color kExDetGreen = Color(0xFF99FF99);

String getExpertArticleContent(ExpertArticleItem article) {
  if (article.content.isNotEmpty) {
    return article.content;
  }
  return '''Starting an ${article.category.toLowerCase()} garden is one of the most rewarding ways to connect with nature from the comfort of your home. Whether you're a complete beginner or looking to expand your skills, this comprehensive guide will walk you through everything you need to know.

Why Choose ${article.category}?

${article.category} offers numerous advantages for plant enthusiasts. You have complete control over the growing environment, can enjoy them year-round, and don't need a large space to get started. Even a small balcony or windowsill can become a thriving garden.

Essential Supplies You'll Need

• Containers with proper drainage holes
• High-quality potting mix suitable for the plant type
• Seeds or starter plants from a reputable source
• Adequate light — natural or grow lights
• Watering can or spray bottle

The beauty of ${article.category.toLowerCase()} lies in its simplicity. You don't need expensive equipment or special expertise to succeed. With the right foundation and consistent care, you'll see results within weeks.

Best Varieties for Beginners

Some varieties are more forgiving than others when starting out. Choose ones that grow quickly and are relatively low-maintenance to build your confidence before moving on to more demanding species.

Pro Tip

Start with just 2–3 varieties to avoid overwhelming yourself. As you gain confidence and observe how each plant responds to your care routine, you can gradually expand your collection and experiment with more challenging specimens.

Caring for Your Plants

Remember that consistency is key when caring for your plants. Establish a routine for watering, checking soil moisture, and monitoring overall health. Rotate your plants occasionally to ensure even growth on all sides.

With these fundamentals in place, you'll soon be enjoying the satisfaction that comes from nurturing living things. The knowledge you gain from each plant will make you a better grower for every one that follows.''';
}

class ExpertDetailArtikelPage extends StatefulWidget {
  final ExpertArticleItem article;

  const ExpertDetailArtikelPage({super.key, required this.article});

  @override
  State<ExpertDetailArtikelPage> createState() =>
      ExpertDetailArtikelPageState();
}

class ExpertDetailArtikelPageState extends State<ExpertDetailArtikelPage> {
  bool get isBookmarked => expertBookmarkedIds.contains(widget.article.id);

  void toggleBookmark() {
    setState(() {
      if (isBookmarked) {
        expertBookmarkedIds.remove(widget.article.id);
        widget.article.isBookmarked = false;
      } else {
        expertBookmarkedIds.add(widget.article.id);
        widget.article.isBookmarked = true;
      }
    });
  }

  List<ExpertArticleItem> get recommendedArticles {
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    final userProvider = Provider.of<AuthProvider>(context, listen: false);
    final allExpertArticles = provider.articles.map((a) => ModelConverter.articleToExpertArticleItem(a, userProvider.user?.id)).toList();
    
    final same = allExpertArticles
        .where((a) =>
            a.id != widget.article.id && a.category == widget.article.category)
        .toList();
    final others = allExpertArticles
        .where((a) =>
            a.id != widget.article.id && a.category != widget.article.category)
        .toList();
    return [...same, ...others].take(5).toList();
  }

  // ── Delete flow ───────────────────────────────────────────────────────────
  void showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 28),
              ),
              const SizedBox(height: 14),
              Text('Delete Article',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${widget.article.title}"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        deleteArticle();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('Delete',
                          style: GoogleFonts.outfit(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteArticle() {
    // Remove from global lists
    Provider.of<ArticleProvider>(context, listen: false).deleteArticle(int.parse(widget.article.id));
    expertBookmarkedIds.remove(widget.article.id);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: kExDetTeal.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: kExDetMain, size: 28),
              ),
              const SizedBox(height: 14),
              Text('Article Deleted',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text(
                'Your article has been removed from Articles and My Articles.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.5),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx); // close success dialog
                  Navigator.pop(context); // back to article list
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: kExDetMain,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: kExDetMain.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Text('Back to Articles',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cover image widget (handles both local file and network URL) ──────────
  Widget buildCoverImage() {
    final url = widget.article.imageUrl;
    if (url.startsWith('/')) {
      return ImageHelper.fromPath(url,
          fit: BoxFit.cover, errorBuilder: (ctx, e, s) => _coverFallback());
    }
    return Image.network(url,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, p) {
          if (p == null) return child;
          return Container(
            color: kExDetTeal.withOpacity(0.3),
            child: const Center(
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: kExDetMain),
            ),
          );
        },
        errorBuilder: (ctx, e, s) => _coverFallback());
  }

  Widget _coverFallback() => Container(
        color: kExDetLGreen.withOpacity(0.3),
        child: Icon(Icons.eco_rounded, color: Colors.green.shade300, size: 48),
      );

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
                  // Badges row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: kExDetTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(widget.article.category,
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: kExDetMain)),
                      ),
                      if (widget.article.isMine) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: kExDetLGreen.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('My Article',
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E7D32))),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(widget.article.title,
                      style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.3)),
                  const SizedBox(height: 14),

                  // Author
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: kExDetTeal.withOpacity(0.3),
                        child: Text(widget.article.author[0],
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                color: kExDetMain,
                                fontSize: 14)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.article.author,
                              style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                          Text(widget.article.time,
                              style: GoogleFonts.outfit(
                                  fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  const SizedBox(height: 16),

                  // Body text
                  ArticleBody(
                    content: getExpertArticleContent(widget.article),
                    textStyle: GoogleFonts.outfit(
                        fontSize: 14, color: Colors.black87, height: 1.75),
                  ),
                  const SizedBox(height: 28),

                  // Delete button — only for own articles
                  if (widget.article.isMine) ...[
                    buildDeleteButton(),
                    const SizedBox(height: 24),
                  ],

                  // More articles
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
      backgroundColor: kExDetMain,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
      ),
      actions: [
        // Bookmark
        GestureDetector(
          onTap: toggleBookmark,
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isBookmarked ? kExDetMain : Colors.black.withOpacity(0.3),
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
        // Delete icon in app bar (only for own)
        if (widget.article.isMine)
          GestureDetector(
            onTap: showDeleteConfirm,
            child: Container(
              margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            buildCoverImage(),
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

  // ── Delete Button ─────────────────────────────────────────────────────────
  Widget buildDeleteButton() {
    return GestureDetector(
      onTap: showDeleteConfirm,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.withOpacity(0.25), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent, size: 18),
            const SizedBox(width: 8),
            Text('Delete This Article',
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent)),
          ],
        ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('More Articles',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text('See All',
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: kExDetMain,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 4),
            physics: const BouncingScrollPhysics(),
            itemCount: recs.length,
            itemBuilder: (ctx, i) => buildRecCard(ctx, recs[i]),
          ),
        ),
      ],
    );
  }

  Widget buildRecCard(BuildContext context, ExpertArticleItem article) {
    final isMarked = expertBookmarkedIds.contains(article.id);
    final imgUrl = article.imageUrl;

    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (ctx) => ExpertDetailArtikelPage(article: article)),
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
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imgUrl.startsWith('/')
                      ? ImageHelper.fromPath(imgUrl,
                          height: 112,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, e, s) => _recFallback())
                      : Image.network(imgUrl,
                          height: 112,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, p) {
                            if (p == null) return child;
                            return Container(
                              height: 112,
                              color: kExDetTeal.withOpacity(0.15),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: kExDetMain),
                              ),
                            );
                          },
                          errorBuilder: (ctx, e, s) => _recFallback()),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      if (isMarked) {
                        expertBookmarkedIds.remove(article.id);
                        article.isBookmarked = false;
                      } else {
                        expertBookmarkedIds.add(article.id);
                        article.isBookmarked = true;
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isMarked
                            ? kExDetMain
                            : Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4)
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.category,
                        style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: kExDetMain)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              height: 1.35)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(article.author,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                  fontSize: 10, color: Colors.grey.shade500)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('•',
                              style: GoogleFonts.outfit(
                                  fontSize: 10, color: Colors.grey.shade400)),
                        ),
                        Text(article.time,
                            style: GoogleFonts.outfit(
                                fontSize: 10, color: Colors.grey.shade400)),
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

  Widget _recFallback() => Container(
        height: 112,
        color: kExDetLGreen.withOpacity(0.3),
        child: Icon(Icons.eco_rounded, color: Colors.green.shade300, size: 32),
      );
}