import 'dart:io' as dartio;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/article_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/model_converter.dart';
import 'expert_artikel.dart';
import 'expert_detail_artikel.dart';
import 'expert_home.dart' hide ExpertAccountPage;
import 'expert_consult.dart';
import 'expert_setting.dart';
import 'expert_tulis_artikel.dart';

const Color kMyArtMain = Color(0xFF5DCFCF);
const Color kMyArtTeal = Color(0xFF76EAD0);
const Color kMyArtBlue = Color(0xFF76D7EA);
const Color kMyArtLGreen = Color(0xFFD0FF99);
const Color kMyArtScaffold = Color(0xFFF0F4F3);

class ExpertMyArticlePage extends StatefulWidget {
  const ExpertMyArticlePage({super.key});

  @override
  State<ExpertMyArticlePage> createState() => ExpertMyArticlePageState();
}

class ExpertMyArticlePageState extends State<ExpertMyArticlePage> {
  int navIndex = 1;
  String selectedCategory = 'All';
  final TextEditingController searchCtrl = TextEditingController();
  String searchQuery = '';
  int displayCount = 10;

  @override
  void initState() {
    super.initState();
    searchCtrl.addListener(() {
      setState(() => searchQuery = searchCtrl.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArticleProvider>(context, listen: false).fetchMyArticles(refresh: true);
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  List<ExpertArticleItem> get myArticles {
    final articleProvider = Provider.of<ArticleProvider>(context);
    final expert = Provider.of<AuthProvider>(context, listen: false).user;
    return articleProvider.myArticles
        .map((a) => ModelConverter.articleToExpertArticleItem(a, expert?.id))
        .toList();
  }

  List<ExpertArticleItem> get filtered {
    return myArticles.where((a) {
      final matchCat =
          selectedCategory == 'All' || a.category == selectedCategory;
      final matchSearch = searchQuery.isEmpty ||
          a.title.toLowerCase().contains(searchQuery) ||
          a.category.toLowerCase().contains(searchQuery);
      return matchCat && matchSearch;
    }).toList();
  }

  List<ExpertArticleItem> get displayed => filtered.take(displayCount).toList();

  void goToDetail(ExpertArticleItem article) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => ExpertDetailArtikelPage(article: article)),
    ).then((_) => setState(() {}));
  }

  void confirmDelete(ExpertArticleItem article) {
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
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 26),
              ),
              const SizedBox(height: 14),
              Text('Delete Article',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${article.title}"? This cannot be undone.',
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
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
                        final success = await articleProvider.deleteArticle(int.parse(article.id));
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Article deleted.',
                                  style: GoogleFonts.outfit(fontSize: 13)),
                              backgroundColor: kMyArtMain,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(articleProvider.errorMessage ?? 'Failed to delete article.',
                                  style: GoogleFonts.outfit(fontSize: 13)),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
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

  void onNavTapped(int index) {
    if (index == navIndex) return;
    setState(() => navIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => ExpertHomePage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => ExpertConsultPage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (ctx) => ExpertAccountPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMyArtScaffold,
      body: Column(
        children: [
          buildHeader(),
          // Hint text
          if (myArticles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.swipe_rounded,
                      size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text('Swipe right on an article to delete it',
                      style: GoogleFonts.outfit(
                          fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
          Expanded(
            child: filtered.isEmpty
                ? buildEmpty()
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: displayed.length,
                          itemBuilder: (ctx, i) =>
                              buildSwipeableCard(displayed[i]),
                        ),
                      ),
                      if (displayed.length < filtered.length)
                        buildLoadMoreButton(),
                      const SizedBox(height: 12),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kMyArtMain,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ExpertTulisArtikelPage()),
        ).then((_) => setState(() {})),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kMyArtBlue, kMyArtTeal],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  Column(
                    children: [
                      Text('My Articles',
                          style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      Text('${myArticles.length} articles published',
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                  // Placeholder to balance layout
                  const SizedBox(width: 36),
                ],
              ),
              const SizedBox(height: 14),

              // Search bar
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: TextField(
                  controller: searchCtrl,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.outfit(
                      fontSize: 16, color: Colors.black87, height: 1.1),
                  decoration: InputDecoration(
                    hintText: 'Search your articles...',
                    hintStyle: GoogleFonts.outfit(
                        fontSize: 16, color: Colors.grey.shade400, height: 1.1),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.grey.shade400, size: 24),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () => searchCtrl.clear(),
                            icon: Icon(Icons.close,
                                size: 22, color: Colors.grey.shade400))
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category tabs
              SizedBox(
                height: 34,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: expertArtikelCategories.length,
                  itemBuilder: (ctx, i) {
                    final cat = expertArtikelCategories[i];
                    final isSel = cat == selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: EdgeInsets.only(
                            right: i == expertArtikelCategories.length - 1
                                ? 0
                                : 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isSel
                              ? kMyArtMain
                              : Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? kMyArtMain
                                : Colors.white.withOpacity(0.5),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(cat,
                              style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSel
                                      ? Colors.white
                                      : Colors.grey.shade700)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kMyArtTeal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.article_outlined, size: 38, color: kMyArtMain),
          ),
          const SizedBox(height: 16),
          Text(
            myArticles.isEmpty
                ? "You haven't written any articles yet"
                : 'No results found',
            style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            myArticles.isEmpty
                ? 'Tap + to write your first article'
                : 'Try a different category or keyword',
            textAlign: TextAlign.center,
            style:
                GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ── Swipeable Card (Dismissible) ──────────────────────────────────────────
  Widget buildSwipeableCard(ExpertArticleItem article) {
    return Dismissible(
      key: ValueKey(article.id),
      direction: DismissDirection.startToEnd, // swipe kanan
      confirmDismiss: (_) async {
        // Show confirm dialog, return false to prevent auto-dismiss
        confirmDelete(article);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 26),
            const SizedBox(width: 10),
            Text('Delete',
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ),
      child: buildArticleCard(article),
    );
  }

  // ── Article Card ──────────────────────────────────────────────────────────
  Widget buildArticleCard(ExpertArticleItem article) {
    final imgUrl = article.imageUrl;

    return GestureDetector(
      onTap: () => goToDetail(article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kMyArtMain.withOpacity(0.3), width: 1.2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: imgUrl.startsWith('/')
                  ? Image.file(dartio.File(imgUrl),
                      width: 100,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, s) => _imgFallback())
                  : Image.network(imgUrl,
                      width: 100,
                      height: 110,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, p) {
                        if (p == null) return child;
                        return Container(
                          width: 100,
                          height: 110,
                          color: kMyArtLGreen.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: kMyArtMain),
                          ),
                        );
                      },
                      errorBuilder: (ctx, e, s) => _imgFallback()),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            height: 1.35)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(article.category,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: kMyArtMain)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text('•',
                              style: GoogleFonts.outfit(
                                  fontSize: 11, color: Colors.grey.shade400)),
                        ),
                        Text(article.time,
                            style: GoogleFonts.outfit(
                                fontSize: 11, color: Colors.grey.shade400)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Swipe hint badge
                    Row(
                      children: [
                        Icon(Icons.swipe_rounded,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text('Swipe to delete',
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

  Widget _imgFallback() => Container(
        width: 100,
        height: 110,
        color: kMyArtLGreen.withOpacity(0.3),
        child: Icon(Icons.eco_rounded, color: Colors.green.shade300, size: 32),
      );

  // ── Load More ─────────────────────────────────────────────────────────────
  Widget buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => setState(() => displayCount += 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: kMyArtTeal.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kMyArtTeal.withOpacity(0.4), width: 1.2),
          ),
          child: Text('Load More',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kMyArtMain)),
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget buildBottomNav() {
    final List<Map<String, dynamic>> items = [
      {
        'label': 'Home',
        'icon': 'assets/images/home.png',
        'fallback': Icons.home_outlined
      },
      {
        'label': 'Articles',
        'icon': 'assets/images/article.png',
        'fallback': Icons.article_outlined
      },
      {
        'label': 'Consultations',
        'icon': 'assets/images/consultation.png',
        'fallback': Icons.chat_bubble_outline
      },
      {
        'label': 'Account',
        'icon': 'assets/images/user.png',
        'fallback': Icons.person_outline
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final bool isSel = navIndex == index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onNavTapped(index),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(items[index]['icon'] as String,
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          color: isSel ? kMyArtMain : Colors.grey.shade400,
                          errorBuilder: (_, __, ___) => Icon(
                              items[index]['fallback'] as IconData,
                              color: isSel ? kMyArtMain : Colors.grey.shade400,
                              size: 24)),
                      const SizedBox(height: 4),
                      Text(items[index]['label'] as String,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight:
                                  isSel ? FontWeight.w600 : FontWeight.w400,
                              color:
                                  isSel ? kMyArtMain : Colors.grey.shade400)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
