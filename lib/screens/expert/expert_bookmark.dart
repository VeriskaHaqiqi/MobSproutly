import 'dart:io' as _dartio;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'expert_artikel.dart';
import 'expert_detail_artikel.dart';
import 'expert_home.dart' hide ExpertAccountPage;
import 'expert_consult.dart';
import 'expert_setting.dart';
import 'package:provider/provider.dart';
import '../../providers/article_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/model_converter.dart';
import '../../utils/image_helper.dart';
const Color kExBmMain = Color(0xFF5DCFCF);
const Color kExBmTeal = Color(0xFF76EAD0);
const Color kExBmBlue = Color(0xFF76D7EA);
const Color kExBmLGreen = Color(0xFFD0FF99);
const Color kExBmScaffold = Color(0xFFF0F4F3);

class ExpertBookmarkPage extends StatefulWidget {
  const ExpertBookmarkPage({super.key});

  @override
  State<ExpertBookmarkPage> createState() => ExpertBookmarkPageState();
}

class ExpertBookmarkPageState extends State<ExpertBookmarkPage> {
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
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  List<ExpertArticleItem> get bookmarked {
    final provider = Provider.of<ArticleProvider>(context);
    final userProvider = Provider.of<AuthProvider>(context, listen: false);
    final allExpertArticles = provider.articles.map((a) => ModelConverter.articleToExpertArticleItem(a, userProvider.user?.id)).toList();
    return allExpertArticles
        .where((a) => expertBookmarkedIds.contains(a.id))
        .toList();
  }

  List<ExpertArticleItem> get filtered {
    return bookmarked.where((a) {
      final matchCat =
          selectedCategory == 'All' || a.category == selectedCategory;
      final matchSearch = searchQuery.isEmpty ||
          a.title.toLowerCase().contains(searchQuery) ||
          a.author.toLowerCase().contains(searchQuery) ||
          a.category.toLowerCase().contains(searchQuery);
      return matchCat && matchSearch;
    }).toList();
  }

  List<ExpertArticleItem> get displayed => filtered.take(displayCount).toList();

  void removeBookmark(ExpertArticleItem article) {
    setState(() {
      expertBookmarkedIds.remove(article.id);
      article.isBookmarked = false;
    });
  }

  void goToDetail(ExpertArticleItem article) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => ExpertDetailArtikelPage(article: article)),
    ).then((_) => setState(() {}));
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
      backgroundColor: kExBmScaffold,
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: filtered.isEmpty
                ? buildEmpty()
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: displayed.length,
                          itemBuilder: (ctx, i) =>
                              buildBookmarkCard(displayed[i]),
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
          colors: [kExBmBlue, kExBmTeal],
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
                  Text('Bookmarked Articles',
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmark_rounded,
                        color: Colors.white, size: 20),
                  ),
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
                    hintText: 'Search by title or author...',
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
                              ? kExBmMain
                              : Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? kExBmMain
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
              color: kExBmTeal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_outline_rounded,
                size: 38, color: kExBmMain),
          ),
          const SizedBox(height: 16),
          Text(
            bookmarked.isEmpty ? 'No saved articles yet' : 'No results found',
            style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            bookmarked.isEmpty
                ? 'Tap the bookmark icon on any article\nto save it here'
                : 'Try a different category or keyword',
            textAlign: TextAlign.center,
            style:
                GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ── Bookmark Card ─────────────────────────────────────────────────────────
  Widget buildBookmarkCard(ExpertArticleItem article) {
    return GestureDetector(
      onTap: () => goToDetail(article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: article.isMine
              ? Border.all(color: kExBmMain.withOpacity(0.4), width: 1.2)
              : null,
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
              child: article.imageUrl.startsWith('/')
                  ? ImageHelper.fromPath(article.imageUrl,
                      width: 100,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, s) => _imgFallback(),
                    )
                  : Image.network(
                      article.imageUrl,
                      width: 100,
                      height: 110,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, p) {
                        if (p == null) return child;
                        return Container(
                          width: 100,
                          height: 110,
                          color: kExBmLGreen.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: kExBmMain),
                          ),
                        );
                      },
                      errorBuilder: (ctx, e, s) => _imgFallback(),
                    ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
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
                    const SizedBox(height: 5),
                    Text(
                      'Learn essential tips on growing healthy ${article.category.toLowerCase()} plants.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Text(article.category,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: kExBmMain)),
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
                  ],
                ),
              ),
            ),

            // Remove bookmark
            GestureDetector(
              onTap: () => removeBookmark(article),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                child: const Icon(Icons.bookmark_rounded,
                    color: kExBmMain, size: 22),
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
        color: kExBmLGreen.withOpacity(0.3),
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
            color: kExBmTeal.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kExBmTeal.withOpacity(0.4), width: 1.2),
          ),
          child: Text('Load More Articles',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.w600, color: kExBmMain)),
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
                          color: isSel ? kExBmMain : Colors.grey.shade400,
                          errorBuilder: (_, __, ___) => Icon(
                              items[index]['fallback'] as IconData,
                              color: isSel ? kExBmMain : Colors.grey.shade400,
                              size: 24)),
                      const SizedBox(height: 4),
                      Text(items[index]['label'] as String,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight:
                                  isSel ? FontWeight.w600 : FontWeight.w400,
                              color: isSel ? kExBmMain : Colors.grey.shade400)),
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

// Helper untuk local file
_dartio.File _file(String path) => _dartio.File(path);
