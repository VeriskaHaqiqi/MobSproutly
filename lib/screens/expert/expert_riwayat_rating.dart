import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'expert_home.dart' hide ExpertAccountPage;
import 'expert_artikel.dart';
import 'expert_consult.dart';
import 'expert_setting.dart';

const Color kRatMain = Color(0xFF5DCFCF);
const Color kRatTeal = Color(0xFF76EAD0);
const Color kRatBlue = Color(0xFF76D7EA);
const Color kRatScaffold = Color(0xFFF0F4F3);

// ─── Model ────────────────────────────────────────────────────────────────────
class ExpertRatingItem {
  final String id;
  final String consultDate;
  final String topic;
  final double rating;
  final String reviewText;

  const ExpertRatingItem({
    required this.id,
    required this.consultDate,
    required this.topic,
    required this.rating,
    required this.reviewText,
  });
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────
// Data yang belum dirating sudah dihapus.
final List<ExpertRatingItem> _ratings = [
  ExpertRatingItem(
    id: '1',
    consultDate: 'Dec 15, 2024',
    topic: 'Orchid root care discussion',
    rating: 5.0,
    reviewText:
        'Dr. Isyana was incredibly knowledgeable and patient. She explained everything clearly and my orchid is recovering beautifully. Highly recommend!',
  ),
  ExpertRatingItem(
    id: '2',
    consultDate: 'Dec 12, 2024',
    topic: 'Tomato fungus issue',
    rating: 4.0,
    reviewText:
        'Very helpful advice about powdery mildew. The treatment she recommended worked within a week. Would consult again.',
  ),
  ExpertRatingItem(
    id: '3',
    consultDate: 'Dec 8, 2024',
    topic: 'Hydroponic setup guidance',
    rating: 5.0,
    reviewText:
        'Amazing session! She walked me through every step of setting up my hydroponic system. Her expertise is unmatched. 10/10!',
  ),
  ExpertRatingItem(
    id: '4',
    consultDate: 'Dec 3, 2024',
    topic: 'Rose bush pruning',
    rating: 4.0,
    reviewText:
        'Good consultation overall. The pruning technique she described worked well. A bit rushed but still very informative.',
  ),
  ExpertRatingItem(
    id: '5',
    consultDate: 'Nov 28, 2024',
    topic: 'Monstera care tips',
    rating: 5.0,
    reviewText:
        'Absolutely loved the session. Very detailed advice and she even followed up with extra tips. My monstera is thriving now!',
  ),
  ExpertRatingItem(
    id: '6',
    consultDate: 'Nov 20, 2024',
    topic: 'Basil herb growing',
    rating: 3.0,
    reviewText:
        'Decent advice but I was hoping for more specific product recommendations. Still helpful for a beginner like me.',
  ),
  ExpertRatingItem(
    id: '7',
    consultDate: 'Nov 16, 2024',
    topic: 'Indoor plant selection advice',
    rating: 2.0,
    reviewText:
        'The advice was okay, but I expected more detailed recommendations based on my room condition.',
  ),
  ExpertRatingItem(
    id: '8',
    consultDate: 'Nov 10, 2024',
    topic: 'Leaf yellowing consultation',
    rating: 1.0,
    reviewText:
        'The consultation did not really answer my issue clearly. I still needed to look for another solution.',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class ExpertRiwayatRatingPage extends StatefulWidget {
  const ExpertRiwayatRatingPage({super.key});

  @override
  State<ExpertRiwayatRatingPage> createState() =>
      _ExpertRiwayatRatingPageState();
}

class _ExpertRiwayatRatingPageState extends State<ExpertRiwayatRatingPage> {
  int navIndex = 3;

  String _filter = 'All';

  final List<String> _filters = [
    'All',
    '5 Stars',
    '4 Stars',
    '3 Stars',
    '2 Stars',
    '1 Star',
  ];

  List<ExpertRatingItem> get filtered {
    if (_filter == 'All') return _ratings;

    final selectedRating = int.tryParse(_filter.split(' ').first);
    if (selectedRating == null) return _ratings;

    return _ratings.where((r) => r.rating.floor() == selectedRating).toList();
  }

  double get _avgRating {
    if (_ratings.isEmpty) return 0;
    return _ratings.fold(0.0, (sum, r) => sum + r.rating) / _ratings.length;
  }

  int get _totalReviews => _ratings.length;

  int _countByRating(int star) {
    return _ratings.where((r) => r.rating.floor() == star).length;
  }

  void onNavTapped(int index) {
    if (index == navIndex) return;

    setState(() => navIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertHomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertArticlePage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertConsultPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertAccountPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = filtered;

    return Scaffold(
      backgroundColor: kRatScaffold,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildFilters(),
                  const SizedBox(height: 14),
                  if (list.isEmpty)
                    _buildEmpty()
                  else
                    ...list.map((ratingItem) => _buildRatingCard(ratingItem)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kRatBlue, kRatTeal],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Row(
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
              const SizedBox(width: 12),
              Text(
                'Ratings',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary Card ──────────────────────────────────────────────────────────
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kRatBlue, kRatTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kRatMain.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Rating',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _avgRating.toStringAsFixed(1),
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6, left: 4),
                      child: Text(
                        '/ 5',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildStarRow(_avgRating, size: 18),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 76,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statItem('Total Reviews', '$_totalReviews'),
              const SizedBox(height: 10),
              _statItem('5 Stars', '${_countByRating(5)}'),
              const SizedBox(height: 10),
              _statItem('4 Stars', '${_countByRating(4)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            color: Colors.white.withOpacity(0.75),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ── Filters ───────────────────────────────────────────────────────────────
  Widget _buildFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filterItem = _filters[index];
          final isSel = _filter == filterItem;

          return GestureDetector(
            onTap: () {
              setState(() {
                _filter = filterItem;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSel ? kRatMain : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSel ? kRatMain : Colors.grey.shade300,
                  width: 1.2,
                ),
                boxShadow: isSel
                    ? [
                        BoxShadow(
                          color: kRatMain.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filterItem == 'All' ? 'All' : filterItem.split(' ').first,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSel ? Colors.white : Colors.black54,
                    ),
                  ),
                  if (filterItem != 'All') ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: isSel ? Colors.white : const Color(0xFFFFC107),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Rating Card ───────────────────────────────────────────────────────────
  Widget _buildRatingCard(ExpertRatingItem ratingItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: kRatTeal.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: kRatMain,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anonymous User',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Consulted on ${ratingItem.consultDate}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ratingItem.topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kRatMain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStarRow(ratingItem.rating, size: 18),
              const SizedBox(width: 8),
              Text(
                '${ratingItem.rating.toStringAsFixed(1)} / 5',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kRatScaffold,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: kRatTeal.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  size: 16,
                  color: kRatMain,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ratingItem.reviewText,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stars ─────────────────────────────────────────────────────────────────
  Widget _buildStarRow(double rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;

        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: size,
          color:
              filled || half ? const Color(0xFFFFC107) : Colors.grey.shade300,
        );
      }),
    );
  }

  // ── Empty ─────────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.star_outline_rounded,
              size: 52,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No ratings found',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
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
                        color: isSel ? kRatMain : Colors.grey.shade400,
                        errorBuilder: (_, __, ___) => Icon(
                          items[index]['fallback'] as IconData,
                          color: isSel ? kRatMain : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                          color: isSel ? kRatMain : Colors.grey.shade400,
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
