import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_pencarian.dart';

const Color kRatingTeal = Color(0xFF76EAD0);
const Color kRatingBlue = Color(0xFF76D7EA);
const Color kRatingMain = Color(0xFF5DCFCF);
const Color kRatingLGreen = Color(0xFFD0FF99);
const Color kRatingScaffold = Color(0xFFF0F4F3);

class UserSemuaRatingScreen extends StatefulWidget {
  final ExpertItem expert;

  const UserSemuaRatingScreen({super.key, required this.expert});

  @override
  State<UserSemuaRatingScreen> createState() => UserSemuaRatingScreenState();
}

class UserSemuaRatingScreenState extends State<UserSemuaRatingScreen> {
  int filterStars = 0; // 0 = all

  List<ReviewItem> get filteredReviews {
    if (filterStars == 0) return widget.expert.reviews;
    return widget.expert.reviews.where((r) => r.stars == filterStars).toList();
  }

  // Hitung distribusi bintang
  Map<int, int> get starDistribution {
    final map = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in widget.expert.reviews) {
      map[r.stars] = (map[r.stars] ?? 0) + 1;
    }
    return map;
  }

  double get averageRating {
    if (widget.expert.reviews.isEmpty) return 0;
    final total = widget.expert.reviews.fold(0, (sum, r) => sum + r.stars);
    return total / widget.expert.reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kRatingScaffold,
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSummaryCard(),
                  buildFilterBar(),
                  buildReviewList(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kRatingBlue, kRatingTeal],
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
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reviews & Ratings',
                        style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(widget.expert.name,
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${widget.expert.reviews.length} reviews',
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary Card ─────────────────────────────────────────────────────────
  Widget buildSummaryCard() {
    final dist = starDistribution;
    final total = widget.expert.reviews.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Big rating number
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    height: 1),
              ),
              const SizedBox(height: 6),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < averageRating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFFBB00),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text('$total reviews',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),

          const SizedBox(width: 20),
          Container(width: 1, height: 100, color: Colors.grey.shade200),
          const SizedBox(width: 20),

          // Bar breakdown
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final count = dist[star] ?? 0;
                final fraction = total == 0 ? 0.0 : count / total;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Text('$star',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFBB00), size: 12),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Stack(
                            children: [
                              Container(
                                height: 8,
                                color: Colors.grey.shade100,
                              ),
                              FractionallySizedBox(
                                widthFactor: fraction,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: kRatingMain,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 20,
                        child: Text('$count',
                            style: GoogleFonts.outfit(
                                fontSize: 11, color: Colors.grey.shade500)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Bar ────────────────────────────────────────────────────────────
  Widget buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 0, 6),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            buildFilterChip(label: 'All', value: 0),
            buildFilterChip(label: '5 Stars', value: 5),
            buildFilterChip(label: '4 Stars', value: 4),
            buildFilterChip(label: '3 Stars', value: 3),
            buildFilterChip(label: '2 Stars', value: 2),
            buildFilterChip(label: '1 Star', value: 1),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget buildFilterChip({required String label, required int value}) {
    final isSel = filterStars == value;
    return GestureDetector(
      onTap: () => setState(() => filterStars = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSel ? kRatingMain : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSel ? kRatingMain : Colors.grey.shade300, width: 1.2),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value > 0) ...[
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFBB00), size: 13),
                const SizedBox(width: 4),
              ],
              Text(label,
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSel ? Colors.white : Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Review List ───────────────────────────────────────────────────────────
  Widget buildReviewList() {
    final reviews = filteredReviews;

    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.star_outline_rounded,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              filterStars == 0
                  ? 'No reviews yet'
                  : 'No $filterStars-star reviews',
              style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      itemCount: reviews.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => buildReviewCard(reviews[i]),
    );
  }

  Widget buildReviewCard(ReviewItem review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.network(
              review.avatarUrl,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, p) {
                if (p == null) return child;
                return Container(
                  width: 42,
                  height: 42,
                  color: kRatingTeal.withOpacity(0.2),
                  child: const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: kRatingMain),
                  ),
                );
              },
              errorBuilder: (ctx, e, s) => Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kRatingTeal.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(review.name[0],
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kRatingMain)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(review.name,
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    // Star badges
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.stars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFFFBB00),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(review.comment,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
