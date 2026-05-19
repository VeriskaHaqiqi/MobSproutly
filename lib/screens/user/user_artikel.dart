import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_home.dart';
import 'user_bookmark_artikel.dart';
import 'user_detail_artikel.dart';
import 'user_consult.dart';
import 'user_setting.dart';

const Color kTeal = Color(0xFF76EAD0);
const Color kBlue = Color(0xFF76D7EA);
const Color kGreen = Color(0xFF99FF99);
const Color kLGreen = Color(0xFFD0FF99);
const Color kYellow = Color(0xFFFFFF9F);
const Color kScaffold = Color(0xFFF0F4F3);
const Color kTealMain = Color(0xFF5DCFCF);

// ─── Article Model ────────────────────────────────────────────────────────────
class ArticleItem {
  final String id;
  final String category;
  final String title;
  final String author;
  final String time;
  final String imageUrl;
  bool isBookmarked;

  ArticleItem({
    required this.id,
    required this.category,
    required this.title,
    required this.author,
    required this.time,
    required this.imageUrl,
    this.isBookmarked = false,
  });
}

// ─── 4 Kategori resmi Sproutly ────────────────────────────────────────────────
// Ornamental Plants | Vegetables & Food Crops | Fruit Plants | Herbs & Spices

final List<ArticleItem> allArticles = [
  ArticleItem(
    id: '1',
    category: 'Indoor Plants',
    title: 'Complete Guide to Growing Monstera Deliciosa Indoors',
    author: 'Sarah Johnson',
    time: '2 days ago',
    imageUrl:
        'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?auto=format&fit=crop&w=800&q=80',
  ),
  ArticleItem(
    id: '2',
    category: 'Hydroponics',
    title: "Beginner's Guide to Hydroponic Lettuce Farming",
    author: 'Michael Chen',
    time: '5 days ago',
    imageUrl:
        'https://images.unsplash.com/photo-1558449028-b53a39d100fc?auto=format&fit=crop&w=800&q=80',
  ),
  ArticleItem(
    id: '3',
    category: 'Pest Control',
    title: 'Natural Ways to Control Aphids Without Chemicals',
    author: 'Emma Rodriguez',
    time: '1 week ago',
    imageUrl:
        'https://images.unsplash.com/photo-1591857177580-dc82b9ac4e1e?auto=format&fit=crop&w=800&q=80',
  ),
  ArticleItem(
    id: '4',
    category: 'Outdoor Plants',
    title: 'Planning Your First Vegetable Garden: A Step-by-Step Guide',
    author: 'David Park',
    time: '1 week ago',
    imageUrl:
        'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?auto=format&fit=crop&w=800&q=80',
  ),
  ArticleItem(
    id: '5',
    category: 'Indoor Plants',
    title: 'Top 10 Low-Maintenance Indoor Plants for Busy People',
    author: 'Lisa Thompson',
    time: '2 weeks ago',
    imageUrl:
        'https://images.unsplash.com/photo-1463320726281-696a485928c7?auto=format&fit=crop&w=800&q=80',
  ),
  ArticleItem(
    id: '6',
    category: 'Outdoor Plants',
    title: 'Growing Tomatoes: From Seed to Harvest',
    author: 'James Wilson',
    time: '2 weeks ago',
    imageUrl:
        'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=800&q=80',
  ),
  ArticleItem(
    id: '7',
    category: 'Herbal Plants',
    title: 'How to Grow Basil, Rosemary & Mint at Home',
    author: 'Dr. Emily Chen',
    time: '3 weeks ago',
    imageUrl:
        'https://images.unsplash.com/photo-1466692476868-aef1dfb1e735?auto=format&fit=crop&w=800&q=80',
  ),
  ArticleItem(
    id: '8',
    category: 'Fruit Plants',
    title: 'Tabulampot: Growing Fruit Trees in Containers',
    author: 'Dr. Mark Lee',
    time: '3 weeks ago',
    imageUrl:
        'https://images.unsplash.com/photo-1560493676-04071c5f467b?auto=format&fit=crop&w=800&q=80',
  ),
  ArticleItem(
    id: '9',
    category: 'Indoor Plants',
    title: 'Orchid Care 101: Keep Your Orchids Blooming Year-Round',
    author: 'Dr. Sarah Lee',
    time: '1 month ago',
    imageUrl:
        'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=800&q=80',
  ),
  ArticleItem(
    id: '10',
    category: 'Plant Health',
    title: 'Identifying Common Plant Diseases & How to Treat Them',
    author: 'Dr. James Wilson',
    time: '1 month ago',
    imageUrl:
        'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?auto=format&fit=crop&w=800&q=80',
  ),
];

const List<String> artikelCategories = [
  'All',
  'Ornamental Plants',
  'Vegetables & Food Crops',
  'Fruit Plants',
  'Herbs & Spices',
];

// ─── Bookmark state (global) ──────────────────────────────────────────────────
final Set<String> globalBookmarkedIds = {};

// ─── Screen ───────────────────────────────────────────────────────────────────
class UserArtikelScreen extends StatefulWidget {
  const UserArtikelScreen({super.key});

  @override
  State<UserArtikelScreen> createState() => UserArtikelScreenState();
}

class UserArtikelScreenState extends State<UserArtikelScreen> {
  int navIndex = 1;
  String selectedCategory = 'All';
  final TextEditingController searchCtrl = TextEditingController();
  String searchQuery = '';
  List<ArticleItem> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = List.from(allArticles);
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
    filtered = allArticles.where((a) {
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

  void toggleBookmark(ArticleItem article) {
    setState(() {
      if (globalBookmarkedIds.contains(article.id)) {
        globalBookmarkedIds.remove(article.id);
        article.isBookmarked = false;
      } else {
        globalBookmarkedIds.add(article.id);
        article.isBookmarked = true;
      }
    });
  }

  void onNavTapped(int index) {
    if (index == navIndex) return;
    setState(() => navIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (ctx) => const HomeUserScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (ctx) => const UserConsultScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (ctx) => const UserSettingScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffold,
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
      bottomNavigationBar: buildBottomNav(),
    );
  }

  Widget buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kBlue, kTeal],
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  Text('Articles',
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => const UserBookmarkArtikelScreen()),
                    ).then((_) => setState(() {})),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark_outline_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryTabs() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 6),
        itemCount: artikelCategories.length,
        itemBuilder: (ctx, i) {
          final cat = artikelCategories[i];
          final isSel = cat == selectedCategory;
          return GestureDetector(
            onTap: () => selectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSel ? kTealMain : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSel ? kTealMain : Colors.grey.shade300,
                    width: 1.2),
              ),
              child: Center(
                child: Text(cat,
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSel ? Colors.white : Colors.grey.shade600)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No articles found',
              style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400)),
          const SizedBox(height: 4),
          Text('Try a different keyword or category',
              style: GoogleFonts.outfit(
                  fontSize: 13, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget buildArticleList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => buildArticleCard(filtered[i]),
    );
  }

  Widget buildArticleCard(ArticleItem article) {
    final isBookmarked = globalBookmarkedIds.contains(article.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => UserDetailArtikelScreen(article: article)),
      ).then((_) => setState(() {})),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
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
                  child: Image.network(
                    article.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 180,
                        color: kTeal.withOpacity(0.15),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kTealMain,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, e, s) => Container(
                      height: 180,
                      color: kLGreen.withOpacity(0.3),
                      child: Center(
                        child: Icon(Icons.eco_rounded,
                            color: Colors.green.shade300, size: 40),
                      ),
                    ),
                  ),
                ),
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
                            ? kTealMain
                            : Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2)),
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
                  Text(article.category,
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kTealMain)),
                  const SizedBox(height: 5),
                  Text(article.title,
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.35)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(article.author,
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: Colors.grey.shade500)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text('•',
                            style: GoogleFonts.outfit(
                                fontSize: 12, color: Colors.grey.shade400)),
                      ),
                      Text(article.time,
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: Colors.grey.shade400)),
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
                      Image.asset(
                        items[index]['icon'] as String,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        color: isSel ? kTealMain : Colors.grey.shade400,
                        errorBuilder: (ctx, e, s) => Icon(
                            items[index]['fallback'] as IconData,
                            color: isSel ? kTealMain : Colors.grey.shade400,
                            size: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(items[index]['label'] as String,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight:
                                  isSel ? FontWeight.w600 : FontWeight.w400,
                              color: isSel ? kTealMain : Colors.grey.shade400)),
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
