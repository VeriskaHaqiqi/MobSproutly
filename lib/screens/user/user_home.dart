import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'user_pencarian.dart';
import 'user_artikel.dart';
import 'user_consult.dart';
import 'user_setting.dart';
import 'user_detail_artikel.dart';

const Color kHomeYellow = Color(0xFFFFFF9F); 
const Color kHomeLightGreen = Color(0xFFD0FF99);
const Color kHomeGreen = Color(0xFF99FF99);
const Color kHomeTeal = Color(0xFF76EAD0);
const Color kHomeBlue = Color(0xFF76D7EA);
const Color kHomeScaffold = Color(0xFFF0F4F3);
const Color kHomeDark = Color(0xFF1E2E2B);

final List<Map<String, dynamic>> _homeActivities = [
  {
    'icon': Icons.chat_bubble_outline,
    'title': 'Dr. James Wilson replied',
    'subtitle': 'Your orchid consultation has a new message',
    'time': '10 minutes ago',
    'color': kHomeTeal,
  },
  {
    'icon': Icons.star_border,
    'title': 'Rate your last session',
    'subtitle': 'Share your experience with Dr. Sarah Lee',
    'time': '1 hour ago',
    'color': kHomeYellow,
  },
  {
    'icon': Icons.calendar_today_outlined,
    'title': 'Upcoming Consultation',
    'subtitle': 'Your session with Dr. Emily Chen starts tomorrow',
    'time': '3 hours ago',
    'color': kHomeLightGreen,
  },
  {
    'icon': Icons.payment_outlined,
    'title': 'Payment Confirmed',
    'subtitle': 'Your consultation payment has been received',
    'time': 'Yesterday',
    'color': kHomeBlue,
  },
];

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> {
  List<ArticleItem> get _recommendedArticles {
    if (allArticles.length <= 7) return allArticles;
    return allArticles.sublist(0, 7);
  }

  void _goToSearchConsultation() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const UserPencarianScreen()));
  }

  void _goToArticles() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const UserArtikelScreen()));
  }

  void _goToConsultations() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const UserConsultScreen()));
  }

  void _goToAccount() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const UserSettingScreen()));
  }

  void _goToArticleDetail(ArticleItem article) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => UserDetailArtikelScreen(article: article)),
    ).then((_) => setState(() {}));
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) return;
    if (index == 1)
      _goToArticles();
    else if (index == 2)
      _goToConsultations();
    else if (index == 3) _goToAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kHomeScaffold,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildConsultationBanner(),
                  const SizedBox(height: 28),
                  _buildArticlesSection(),
                  const SizedBox(height: 28),
                  _buildRecentActivity(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ── Header (tanpa notifikasi) ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kHomeBlue, kHomeTeal],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.88),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sarah Johnson',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Consultation Banner ───────────────────────────────────────────────────
  Widget _buildConsultationBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kHomeLightGreen, kHomeGreen],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat with Expert',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Get instant advice for houseplants,\nvegetables, fruits, and herbs.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _goToSearchConsultation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      'Start Consultation',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Icon(Icons.local_florist_rounded,
                    color: kHomeDark, size: 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Articles Section ──────────────────────────────────────────────────────
  Widget _buildArticlesSection() {
    final articles = _recommendedArticles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended Articles',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _goToArticles,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text('See All',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: kHomeBlue,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 236,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 6),
            itemCount: articles.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) => _buildArticleCard(articles[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildArticleCard(ArticleItem article) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _goToArticleDetail(article),
      child: Container(
        width: 214,
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
            _buildArticleCover(article),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.category,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              height: 1.3)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(article.author,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: Colors.grey.shade500)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('•',
                              style: GoogleFonts.inter(
                                  color: Colors.grey.shade400, fontSize: 11)),
                        ),
                        Text(article.time,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: Colors.grey.shade400)),
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

  Widget _buildArticleCover(ArticleItem article) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        height: 112,
        width: double.infinity,
        child: Image.network(
          article.imageUrl,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _articleFallback(article.category, true);
          },
          errorBuilder: (_, __, ___) =>
              _articleFallback(article.category, false),
        ),
      ),
    );
  }

  Widget _articleFallback(String category, bool isLoading) {
    return Container(
      height: 112,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kHomeLightGreen.withOpacity(0.85),
            kHomeTeal.withOpacity(0.75),
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.local_florist_outlined,
                color: Colors.white.withOpacity(0.85), size: 34),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(category,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
          if (isLoading)
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // ── Recent Activity ───────────────────────────────────────────────────────
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Recent Activity',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
        ),
        const SizedBox(height: 14),
        ..._homeActivities.map((activity) => _buildActivityItem(activity)),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(activity['icon'] as IconData,
                  color: Colors.black54, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity['title'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 3),
                Text(activity['subtitle'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 3),
                Text(activity['time'] as String,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNavBar() {
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
              final bool isSelected = index == 0;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onBottomNavTapped(index),
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
                        color: isSelected ? kHomeBlue : Colors.grey.shade400,
                        errorBuilder: (_, __, ___) => Icon(
                            items[index]['fallback'] as IconData,
                            color:
                                isSelected ? kHomeBlue : Colors.grey.shade400,
                            size: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(items[index]['label'] as String,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? kHomeBlue
                                  : Colors.grey.shade400)),
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
