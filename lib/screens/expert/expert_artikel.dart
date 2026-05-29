import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'expert_home.dart' hide ExpertAccountPage;
import 'expert_setting.dart';
import 'expert_consult.dart';
import 'expert_tulis_artikel.dart';
import 'expert_bookmark.dart';
import 'expert_detail_artikel.dart';

const Color kExArtTeal = Color(0xFF76EAD0);
const Color kExArtBlue = Color(0xFF76D7EA);
const Color kExArtMain = Color(0xFF5DCFCF);
const Color kExArtLGreen = Color(0xFFD0FF99);
const Color kExArtGreen = Color(0xFF99FF99);
const Color kExArtYellow = Color(0xFFFFFF9F);
const Color kExArtScaffold = Color(0xFFF0F4F3);

// ─── Article Model ────────────────────────────────────────────────────────────
class ExpertArticleItem {
  final String id;
  final String category;
  final String title;
  final String author;
  final String time;
  final String imageUrl;
  final bool isMine;
  bool isBookmarked;

  ExpertArticleItem({
    required this.id,
    required this.category,
    required this.title,
    required this.author,
    required this.time,
    required this.imageUrl,
    this.isMine = false,
    this.isBookmarked = false,
  });
}

// ─── Kategori Artikel ────────────────────────────────────────────────────────
const List<String> expertArtikelCategories = [
  'All',
  'Ornamental Plants',
  'Vegetables & Food Crops',
  'Fruit Plants',
  'Herbs & Spices',
];

// ─── Dummy Articles ───────────────────────────────────────────────────────────
final List<ExpertArticleItem> allExpertArticles = [
  ExpertArticleItem(
    id: '1',
    category: 'Ornamental Plants',
    title: 'Complete Guide to Monstera Deliciosa Care',
    author: 'Dr. Isyana Chen',
    time: '2 days ago',
    imageUrl:
        'https://images.pexels.com/photos/3097770/pexels-photo-3097770.jpeg?auto=compress&cs=tinysrgb&w=900',
    isMine: true,
  ),
  ExpertArticleItem(
    id: '2',
    category: 'Ornamental Plants',
    title: 'Top 10 Low-Maintenance Indoor Plants for Busy People',
    author: 'Dr. Sarah Lee',
    time: '1 week ago',
    imageUrl:
        'https://images.pexels.com/photos/6208086/pexels-photo-6208086.jpeg?auto=compress&cs=tinysrgb&w=900',
  ),
  ExpertArticleItem(
    id: '3',
    category: 'Ornamental Plants',
    title: 'Orchid Care 101: Keep Your Orchids Blooming Year-Round',
    author: 'Dr. Isyana Chen',
    time: '2 weeks ago',
    imageUrl:
        'https://images.pexels.com/photos/1400375/pexels-photo-1400375.jpeg?auto=compress&cs=tinysrgb&w=900',
    isMine: true,
  ),
  ExpertArticleItem(
    id: '4',
    category: 'Vegetables & Food Crops',
    title: "Beginner's Guide to Hydroponic Lettuce Farming",
    author: 'Michael Chen',
    time: '5 days ago',
    imageUrl:
        'https://images.pexels.com/photos/4505161/pexels-photo-4505161.jpeg?auto=compress&cs=tinysrgb&w=900',
  ),
  ExpertArticleItem(
    id: '5',
    category: 'Vegetables & Food Crops',
    title: 'Growing Tomatoes: From Seed to Harvest',
    author: 'James Wilson',
    time: '2 weeks ago',
    imageUrl:
        'https://images.pexels.com/photos/1327838/pexels-photo-1327838.jpeg?auto=compress&cs=tinysrgb&w=900',
  ),
  ExpertArticleItem(
    id: '6',
    category: 'Vegetables & Food Crops',
    title: 'Natural Ways to Control Pests on Vegetable Plants',
    author: 'Dr. Isyana Chen',
    time: '3 weeks ago',
    imageUrl:
        'https://images.pexels.com/photos/4751978/pexels-photo-4751978.jpeg?auto=compress&cs=tinysrgb&w=900',
    isMine: true,
  ),
  ExpertArticleItem(
    id: '7',
    category: 'Fruit Plants',
    title: 'Container Fruit Trees: Growing Citrus & Berries at Home',
    author: 'Dr. Mark Lee',
    time: '3 weeks ago',
    imageUrl:
        'https://images.pexels.com/photos/2090902/pexels-photo-2090902.jpeg?auto=compress&cs=tinysrgb&w=900',
  ),
  ExpertArticleItem(
    id: '8',
    category: 'Fruit Plants',
    title: 'Strawberry at Home: Planting Tips for Pots & Planters',
    author: 'Dr. Aisha Patel',
    time: '1 month ago',
    imageUrl:
        'https://images.pexels.com/photos/46174/strawberries-berries-fruit-freshness-46174.jpeg?auto=compress&cs=tinysrgb&w=900',
  ),
  ExpertArticleItem(
    id: '9',
    category: 'Herbs & Spices',
    title: 'How to Grow Basil, Rosemary & Mint at Home',
    author: 'Dr. Isyana Chen',
    time: '1 month ago',
    imageUrl:
        'https://images.pexels.com/photos/143133/pexels-photo-143133.jpeg?auto=compress&cs=tinysrgb&w=900',
    isMine: true,
  ),
  ExpertArticleItem(
    id: '10',
    category: 'Herbs & Spices',
    title: 'Growing Ginger & Turmeric in Your Home Garden',
    author: 'Dr. Priya Sharma',
    time: '5 weeks ago',
    imageUrl:
        'https://images.pexels.com/photos/4198021/pexels-photo-4198021.jpeg?auto=compress&cs=tinysrgb&w=900',
  ),
];

// ─── Bookmarked IDs ───────────────────────────────────────────────────────────
final Set<String> expertBookmarkedIds = {};

// ─── Screen ───────────────────────────────────────────────────────────────────
class ExpertArticlePage extends StatefulWidget {
  const ExpertArticlePage({super.key});

  @override
  State<ExpertArticlePage> createState() => ExpertArticlePageState();
}

class ExpertArticlePageState extends State<ExpertArticlePage> {
  int navIndex = 1;
  String selectedCategory = 'All';
  final TextEditingController searchCtrl = TextEditingController();
  String searchQuery = '';
  List<ExpertArticleItem> filtered = [];

  String getFallbackImage(String category) {
    switch (category) {
      case 'Ornamental Plants':
        return 'https://images.pexels.com/photos/6208086/pexels-photo-6208086.jpeg?auto=compress&cs=tinysrgb&w=900';
      case 'Vegetables & Food Crops':
        return 'https://images.pexels.com/photos/4505161/pexels-photo-4505161.jpeg?auto=compress&cs=tinysrgb&w=900';
      case 'Fruit Plants':
        return 'https://images.pexels.com/photos/2090902/pexels-photo-2090902.jpeg?auto=compress&cs=tinysrgb&w=900';
      case 'Herbs & Spices':
        return 'https://images.pexels.com/photos/143133/pexels-photo-143133.jpeg?auto=compress&cs=tinysrgb&w=900';
      default:
        return 'https://images.pexels.com/photos/4751978/pexels-photo-4751978.jpeg?auto=compress&cs=tinysrgb&w=900';
    }
  }

  @override
  void initState() {
    super.initState();
    filtered = List.from(allExpertArticles);
    searchCtrl.addListener(onSearch);
  }

  @override
  void dispose() {
    searchCtrl.removeListener(onSearch);
    searchCtrl.dispose();
    super.dispose();
  }

  void onSearch() {
    setState(() {
      searchQuery = searchCtrl.text.trim().toLowerCase();
      applyFilter();
    });
  }

  void applyFilter() {
    filtered = allExpertArticles.where((a) {
      final matchCat =
          selectedCategory == 'All' || a.category == selectedCategory;

      final matchSearch = searchQuery.isEmpty ||
          a.title.toLowerCase().contains(searchQuery) ||
          a.author.toLowerCase().contains(searchQuery) ||
          a.category.toLowerCase().contains(searchQuery);

      return matchCat && matchSearch;
    }).toList();
  }

  void selectCategory(String cat) {
    setState(() {
      selectedCategory = cat;
      applyFilter();
    });
  }

  void toggleBookmark(ExpertArticleItem article) {
    setState(() {
      if (expertBookmarkedIds.contains(article.id)) {
        expertBookmarkedIds.remove(article.id);
        article.isBookmarked = false;
      } else {
        expertBookmarkedIds.add(article.id);
        article.isBookmarked = true;
      }
    });
  }

  void onNavTapped(int index) {
    if (index == navIndex) return;

    setState(() => navIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (ctx) => ExpertHomePage(),
          ),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (ctx) => ExpertConsultPage(),
          ),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (ctx) => ExpertAccountPage(),
          ),
        );
        break;
    }
  }

  void goToDetailArticle(ExpertArticleItem article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ExpertDetailArtikelPage(article: article),
      ),
    ).then((_) => setState(() {
          applyFilter(); // ← tambah ini
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kExArtScaffold,
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  buildCategoryTabs(),
                  const SizedBox(height: 14),
                  filtered.isEmpty ? buildEmpty() : buildArticleList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kExArtMain,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExpertTulisArtikelPage(),
          ),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
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
          colors: [kExArtBlue, kExArtTeal],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  Text(
                    'Articles',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ExpertBookmarkPage(),
                      ),
                    ).then((_) => setState(() {})),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
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
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchCtrl,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by title or author...',
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                      height: 1.1,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () => searchCtrl.clear(),
                            icon: Icon(
                              Icons.close,
                              size: 22,
                              color: Colors.grey.shade400,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category Tabs ─────────────────────────────────────────────────────────
  Widget buildCategoryTabs() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 6),
        itemCount: expertArtikelCategories.length,
        itemBuilder: (ctx, i) {
          final cat = expertArtikelCategories[i];
          final isSel = cat == selectedCategory;

          return GestureDetector(
            onTap: () => selectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSel ? kExArtMain : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSel ? kExArtMain : Colors.grey.shade300,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSel ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Empty ─────────────────────────────────────────────────────────────────
  Widget buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 52,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No articles found',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different keyword or category',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Article List ──────────────────────────────────────────────────────────
  Widget buildArticleList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => buildArticleCard(filtered[i]),
    );
  }

  Widget buildArticleCard(ExpertArticleItem article) {
    final isBookmarked = expertBookmarkedIds.contains(article.id);

    return GestureDetector(
      onTap: () => goToDetailArticle(article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: article.isMine
              ? Border.all(
                  color: kExArtMain.withOpacity(0.5),
                  width: 1.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    article.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;

                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: kExArtTeal.withOpacity(0.15),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kExArtMain,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, e, s) => Image.network(
                      getFallbackImage(article.category),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kExArtLGreen.withOpacity(0.8),
                              kExArtTeal.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.eco_rounded,
                            color: Colors.green.shade700,
                            size: 46,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Badge My Article
                if (article.isMine)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kExArtMain,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'My Article',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Bookmark button
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => toggleBookmark(article),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? kExArtMain
                            : Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        size: 18,
                        color:
                            isBookmarked ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kExArtMain,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    article.title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        article.author,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: article.isMine
                              ? kExArtMain
                              : Colors.grey.shade500,
                          fontWeight: article.isMine
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '•',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      Text(
                        article.time,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
        'fallback': Icons.home_outlined,
      },
      {
        'label': 'Articles',
        'icon': 'assets/images/article.png',
        'fallback': Icons.article_outlined,
      },
      {
        'label': 'Consultations',
        'icon': 'assets/images/consultation.png',
        'fallback': Icons.chat_bubble_outline,
      },
      {
        'label': 'Account',
        'icon': 'assets/images/user.png',
        'fallback': Icons.person_outline,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        items[index]['icon'] as String,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        color: isSel ? kExArtMain : Colors.grey.shade400,
                        errorBuilder: (_, __, ___) => Icon(
                          items[index]['fallback'] as IconData,
                          color: isSel ? kExArtMain : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                          color: isSel ? kExArtMain : Colors.grey.shade400,
                        ),
                      ),
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
