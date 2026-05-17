import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_pencarian.dart';
import 'user_chat_locked.dart';
import 'user_semua_rating.dart';

const Color kAhliTeal = Color(0xFF76EAD0);
const Color kAhliBlue = Color(0xFF76D7EA);
const Color kAhliMain = Color(0xFF5DCFCF);
const Color kAhliLGreen = Color(0xFFD0FF99);
const Color kAhliGreen = Color(0xFF99FF99);
const Color kAhliYellow = Color(0xFFFFFF9F);
const Color kAhliScaffold = Color(0xFFF0F4F3);

class UserInformasiAhliScreen extends StatelessWidget {
  final ExpertItem expert;

  const UserInformasiAhliScreen({super.key, required this.expert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAhliScaffold,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Teal header bar ──────────────────────────────────────────
              SliverToBoxAdapter(child: buildTopBar(context)),

              // ── Main content ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildProfileCard(),
                      const SizedBox(height: 16),
                      buildStatsRow(),
                      const SizedBox(height: 16),
                      buildReviewsCard(context),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky bottom button ─────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: buildChatButton(context),
          ),
        ],
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget buildTopBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kAhliBlue, kAhliTeal],
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
                child: Text(
                  'Expert Information',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Profile Card ──────────────────────────────────────────────────────────
  Widget buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          // ── Avatar + name row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kAhliTeal, width: 2.5),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        expert.avatarUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, p) {
                          if (p == null) return child;
                          return Container(
                            color: kAhliTeal.withOpacity(0.2),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: kAhliMain),
                            ),
                          );
                        },
                        errorBuilder: (ctx, e, s) => Container(
                          color: kAhliTeal.withOpacity(0.2),
                          child: Center(
                            child: Text(expert.name[0],
                                style: GoogleFonts.outfit(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: kAhliMain)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Verified badge
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: kAhliMain,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expert.name,
                        style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(expert.specialties.first,
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: kAhliMain,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFBB00), size: 16),
                        const SizedBox(width: 4),
                        Text(expert.rating.toStringAsFixed(1),
                            style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: kAhliTeal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${expert.yearsExp} years',
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kAhliMain)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: expert.isAvailableNow
                                ? const Color(0xFF4CAF50)
                                : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(expert.availableText,
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: expert.isAvailableNow
                                    ? const Color(0xFF2E7D32)
                                    : Colors.orange.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 14),

          // ── Degree ──
          Row(
            children: [
              Icon(Icons.school_outlined,
                  size: 18, color: Colors.grey.shade500),
              const SizedBox(width: 10),
              Expanded(
                child: Text(expert.degree,
                    style: GoogleFonts.outfit(
                        fontSize: 13, color: Colors.grey.shade600)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Session fee ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_money_rounded,
                      size: 18, color: Colors.grey.shade500),
                  const SizedBox(width: 10),
                  Text('Session fee',
                      style: GoogleFonts.outfit(
                          fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
              Text(
                'Rp ${(expert.pricePerSession / 1000).toStringAsFixed(0)}K / session',
                style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 14),

          // ── Plant Specializations ──
          Text('Plant Specializations',
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: expert.specialties
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: kAhliTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: kAhliTeal.withOpacity(0.4), width: 1),
                      ),
                      child: Text(s,
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: kAhliMain,
                              fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 14),

          // ── About ──
          Text('About',
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text(expert.bio,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: Colors.grey.shade600, height: 1.6)),
        ],
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────
  Widget buildStatsRow() {
    return Row(
      children: [
        buildStatCard(
          value: '${expert.totalConsultations}+',
          label: 'Consultations',
          color: kAhliLGreen,
          icon: Icons.chat_bubble_outline_rounded,
        ),
        const SizedBox(width: 10),
        buildStatCard(
          value: expert.rating.toStringAsFixed(1),
          label: 'Rating',
          color: kAhliGreen,
          icon: Icons.star_outline_rounded,
        ),
        const SizedBox(width: 10),
        buildStatCard(
          value: expert.avgResponse,
          label: 'Response',
          color: kAhliTeal,
          icon: Icons.access_time_rounded,
        ),
      ],
    );
  }

  Widget buildStatCard({
    required String value,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: kAhliMain),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  // ── Reviews Card ──────────────────────────────────────────────────────────
  Widget buildReviewsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Reviews',
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => UserSemuaRatingScreen(expert: expert),
                  ),
                ),
                child: Text('View all',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: kAhliMain,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...expert.reviews.asMap().entries.map((entry) {
            final i = entry.key;
            final review = entry.value;
            return Column(
              children: [
                buildReviewItem(review),
                if (i < expert.reviews.length - 1) ...[
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 8),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget buildReviewItem(ReviewItem review) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Image.network(
            review.avatarUrl,
            width: 38,
            height: 38,
            fit: BoxFit.cover,
            errorBuilder: (ctx, e, s) => Container(
              width: 38,
              height: 38,
              color: kAhliTeal.withOpacity(0.2),
              child: Center(
                child: Text(review.name[0],
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kAhliMain)),
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
                children: [
                  Text(review.name,
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(
                      review.stars,
                      (i) => const Icon(Icons.star_rounded,
                          color: Color(0xFFFFBB00), size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(review.comment,
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: Colors.grey.shade600, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Chat Button ───────────────────────────────────────────────────────────
  Widget buildChatButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => UserChatLockedScreen(expert: expert),
            ),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: kAhliMain,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: kAhliMain.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text('Chat with Expert',
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
