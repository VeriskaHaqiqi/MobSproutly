import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpertArticlePage extends StatefulWidget {
  const ExpertArticlePage({super.key});

  @override
  State<ExpertArticlePage> createState() => _ExpertArticlePageState();
}

class _ExpertArticlePageState extends State<ExpertArticlePage> {
  static const Color kYellow = Color(0xFFFFFF9F);
  static const Color kLightGreen = Color(0xFFD0FF99);
  static const Color kGreen = Color(0xFF99FF99);
  static const Color kTosca = Color(0xFF76EAD0);
  static const Color kBlue = Color(0xFF76D7EA);

  static const Color kTextDark = Color(0xFF111827);
  static const Color kTextGrey = Color(0xFF6B7280);

  final TextEditingController _searchController = TextEditingController();

  String selectedFilter = 'All';
  final Set<int> bookmarkedArticles = {};

  final List<String> filters = [
    'All',
    'My Articles',
    'Indoor Plants',
    'Outdoor Plants',
    'Vegetables',
    'Fruits',
    'Herbs',
  ];

  final List<Map<String, String>> articles = [
    {
      'title': 'Complete Guide to Monstera Deliciosa Care',
      'author': 'Dr. James Mitchell',
      'time': '2 days ago',
      'category': 'Indoor Plants',
      'image': 'assets/images/cover-artikel1.jpg',
    },
    {
      'title': 'Beginner Guide to Hydroponic Gardening',
      'author': 'You',
      'time': '5 days ago',
      'category': 'Vegetables',
      'image': 'assets/images/cover-artikel2.jpg',
    },
    {
      'title': 'Natural Solutions for Common Plant Pests',
      'author': 'Dr. Sarah Chen',
      'time': '1 week ago',
      'category': 'Herbs',
      'image': 'assets/images/cover-artikel3.jpg',
    },
    {
      'title': 'Top 10 Low-Maintenance Outdoor Plants',
      'author': 'Michael Green',
      'time': '1 week ago',
      'category': 'Outdoor Plants',
      'image': 'assets/images/cover-artikel4.jpg',
    },
    {
      'title': 'Succulent Care: Everything You Need to Know',
      'author': 'Emma Rodriguez',
      'time': '2 weeks ago',
      'category': 'Indoor Plants',
      'image': 'assets/images/cover-artikel1.jpg',
    },
  ];

  List<Map<String, String>> get filteredArticles {
    final keyword = _searchController.text.toLowerCase();

    return articles.where((article) {
      final title = article['title']!.toLowerCase();
      final author = article['author']!.toLowerCase();
      final category = article['category']!;

      final matchSearch = title.contains(keyword) || author.contains(keyword);
      final matchFilter =
          selectedFilter == 'All' ? true : category == selectedFilter;

      return matchSearch && matchFilter;
    }).toList();
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/expert_home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/expert_article');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/expert_consult');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/expert_setting');
        break;
    }
  }

  void _toggleBookmark(int index) {
    setState(() {
      if (bookmarkedArticles.contains(index)) {
        bookmarkedArticles.remove(index);
      } else {
        bookmarkedArticles.add(index);
      }
    });
  }

  void _openArticle(Map<String, String> article) {
    Navigator.pushNamed(
      context,
      '/expert_article_detail',
      arguments: article,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = filteredArticles;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: data.isEmpty
                ? Center(
                    child: Text(
                      'No articles found',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: kTextGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final article = data[index];
                      final originalIndex = articles.indexOf(article);

                      return _buildArticleCard(
                        article: article,
                        index: originalIndex,
                        isBookmarked:
                            bookmarkedArticles.contains(originalIndex),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBlue,
        elevation: 8,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.pushNamed(context, '/expert_write_article');
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kBlue,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/expert_home');
        },
        icon: const Icon(
          Icons.arrow_back,
          color: kTextDark,
        ),
      ),
      title: Text(
        'Articles',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: kTextDark,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/expert_bookmark_article');
          },
          icon: const Icon(
            Icons.bookmark,
            color: Color(0xFF374151),
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.fromLTRB(16, 18, 0, 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: kTextDark,
              ),
              decoration: InputDecoration(
                hintText: 'Search by title or author',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 28,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBlue, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;

                return GestureDetector(
                  onTap: () {
                    if (filter == 'My Articles') {
                      Navigator.pushNamed(context, '/expert_my_article');
                      return;
                    }

                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? kBlue : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? kBlue : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : kTextDark,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard({
    required Map<String, String> article,
    required int index,
    required bool isBookmarked,
  }) {
    return GestureDetector(
      onTap: () => _openArticle(article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: article['author'] == 'You'
                ? kBlue.withOpacity(0.45)
                : Colors.transparent,
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(
                    article['image']!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        height: 140,
                        width: double.infinity,
                        color: kLightGreen.withOpacity(0.4),
                        child: Center(
                          child: Image.asset(
                            'assets/images/logo-hijau.png',
                            width: 42,
                            height: 42,
                            errorBuilder: (_, __, ___) {
                              return const Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => _toggleBookmark(index),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: isBookmarked ? kBlue : Colors.grey.shade600,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              article['title']!,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kTextDark,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundImage: AssetImage(
                    article['author'] == 'You'
                        ? 'assets/images/fotoprofile.png'
                        : 'assets/images/ikon profile.jpg',
                  ),
                  backgroundColor: kBlue.withOpacity(0.25),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    article['author']!,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: kTextGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: kTextGrey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  article['time']!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: kTextGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              decoration: BoxDecoration(
                color: _getCategoryColor(article['category']!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                article['category']!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getCategoryTextColor(article['category']!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Indoor Plants':
        return kTosca.withOpacity(0.25);
      case 'Outdoor Plants':
        return kGreen.withOpacity(0.25);
      case 'Vegetables':
        return kLightGreen.withOpacity(0.35);
      case 'Fruits':
        return kYellow.withOpacity(0.55);
      case 'Herbs':
        return kBlue.withOpacity(0.22);
      default:
        return kTosca.withOpacity(0.22);
    }
  }

  Color _getCategoryTextColor(String category) {
    switch (category) {
      case 'Indoor Plants':
        return const Color(0xFF20C9A6);
      case 'Outdoor Plants':
        return const Color(0xFF35B76E);
      case 'Vegetables':
        return const Color(0xFF3D8B40);
      case 'Fruits':
        return const Color(0xFF9A7B00);
      case 'Herbs':
        return const Color(0xFF2EA9BF);
      default:
        return kTextDark;
    }
  }

  Widget _buildBottomNavBar() {
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
              final bool isSelected = index == 1;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onBottomNavTapped(index),
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
                        color: isSelected ? kBlue : Colors.grey.shade400,
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            items[index]['fallback'] as IconData,
                            color: isSelected ? kBlue : Colors.grey.shade400,
                            size: 24,
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? kBlue : Colors.grey.shade400,
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