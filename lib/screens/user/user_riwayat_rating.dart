import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_home.dart';
import 'user_artikel.dart';
import 'user_consult.dart';
import 'user_setting.dart';
import 'package:provider/provider.dart';
import '../../providers/rating_provider.dart';
import '../../providers/consultation_provider.dart';
import '../../models/rating_model.dart';
import '../../utils/model_converter.dart';
const Color kRatTeal = Color(0xFF76EAD0);
const Color kRatBlue = Color(0xFF76D7EA);
const Color kRatMain = Color(0xFF5DCFCF);
const Color kRatScaffold = Color(0xFFF0F4F3);

// ─── Model ────────────────────────────────────────────────────────────────────
class RatingItem {
  final String id;
  final String expertName;
  final String specialty;
  final String avatarUrl;
  final String consultDate;
  double? rating;
  String? reviewText;

  RatingItem({
    required this.id,
    required this.expertName,
    required this.specialty,
    required this.avatarUrl,
    required this.consultDate,
    this.rating,
    this.reviewText,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class UserRiwayatRatingScreen extends StatefulWidget {
  const UserRiwayatRatingScreen({super.key});

  @override
  State<UserRiwayatRatingScreen> createState() =>
      UserRiwayatRatingScreenState();
}

class UserRiwayatRatingScreenState extends State<UserRiwayatRatingScreen> {
  int navIndex = 3;
  bool showRated = false; // false = Pending tab, true = My Ratings tab

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConsultationProvider>(context, listen: false).fetchUserConsultations(refresh: true);
      Provider.of<RatingProvider>(context, listen: false).fetchUserRatings(refresh: true);
    });
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Recently';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  List<RatingItem> _getAllItems() {
    final consultProv = Provider.of<ConsultationProvider>(context);
    
    final completed = consultProv.userConsultations.where((c) => c.status == 'completed');
    
    return completed.map((c) {
      final ratingObj = c.rating;
      final expert = c.expert;
      final avatar = expert != null ? ModelConverter.getUserAvatar(expert) : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80';
      final specialty = (expert?.specializations != null && expert!.specializations!.isNotEmpty) ? expert.specializations!.first.name : 'Botanist';
      
      return RatingItem(
        id: c.id.toString(),
        expertName: expert?.name ?? 'Expert Botanist',
        specialty: specialty,
        avatarUrl: avatar,
        consultDate: c.createdAt != null ? _formatDate(c.createdAt) : 'Recently',
        rating: ratingObj?.score.toDouble(),
        reviewText: ratingObj?.comment,
      );
    }).toList();
  }

  List<RatingItem> get unrated => _getAllItems().where((r) => r.rating == null).toList();
  List<RatingItem> get rated => _getAllItems().where((r) => r.rating != null).toList();

  // ── Rating dialog (only for unrated items) ────────────────────────────────
  void showRatingDialog(RatingItem item) {
    int tempStars = 0;
    final reviewCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Expert mini card
                Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        item.avatarUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, e, s) => Container(
                          width: 44,
                          height: 44,
                          color: kRatTeal.withOpacity(0.2),
                          child: Center(
                            child: Text(item.expertName[0],
                                style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: kRatMain)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.expertName,
                              style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87)),
                          Text(item.specialty,
                              style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: kRatMain,
                                  fontWeight: FontWeight.w500)),
                          Text('Consulted on ${item.consultDate}',
                              style: GoogleFonts.outfit(
                                  fontSize: 11, color: Colors.grey.shade400)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 18),

                Text('Your opinion matters to us!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 6),
                Text('How was the quality of the consultation?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        fontSize: 13, color: Colors.grey.shade500)),
                const SizedBox(height: 18),

                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return GestureDetector(
                      onTap: () => setDialog(() => tempStars = star),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            star <= tempStars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            key: ValueKey('$star-$tempStars'),
                            color: const Color(0xFFFFBB00),
                            size: 36,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Review field
                Container(
                  decoration: BoxDecoration(
                    color: kRatScaffold,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200, width: 1.2),
                  ),
                  child: TextField(
                    controller: reviewCtrl,
                    maxLines: 3,
                    style:
                        GoogleFonts.outfit(fontSize: 13, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Leave a message (optional)',
                      hintStyle: GoogleFonts.outfit(
                          fontSize: 13, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                GestureDetector(
                  onTap: tempStars == 0
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          final success = await Provider.of<RatingProvider>(context, listen: false).submitRating(
                            consultationId: int.parse(item.id),
                            score: tempStars,
                            comment: reviewCtrl.text.trim().isEmpty ? null : reviewCtrl.text.trim(),
                          );
                          if (success && mounted) {
                            // Refresh consultations so the new rating appears
                            Provider.of<ConsultationProvider>(context, listen: false).fetchUserConsultations(refresh: true);
                            setState(() {
                              showRated = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Thanks for your rating!',
                                    style: GoogleFonts.outfit(fontSize: 13)),
                                backgroundColor: kRatMain,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else if (mounted) {
                            final err = Provider.of<RatingProvider>(context, listen: false).errorMessage ?? 'Failed to submit rating';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(err,
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: tempStars == 0 ? Colors.grey.shade200 : kRatMain,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: tempStars > 0
                          ? [
                              BoxShadow(
                                  color: kRatMain.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ]
                          : [],
                    ),
                    child: Text('Rate Now',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: tempStars == 0
                                ? Colors.grey.shade400
                                : Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),

                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Text('Maybe later',
                      style: GoogleFonts.outfit(
                          fontSize: 13, color: Colors.grey.shade400)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Delete rating dialog ──────────────────────────────────────────────────
  void showDeleteDialog(RatingItem item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 26),
              ),
              const SizedBox(height: 14),
              Text('Remove Rating',
                  style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to remove your rating for ${item.expertName}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removing rating is not supported.',
                                style: GoogleFonts.outfit(fontSize: 13)),
                            backgroundColor: Colors.grey.shade800,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('Remove',
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
            context, MaterialPageRoute(builder: (c) => HomeUserScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (c) => const UserArtikelScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (c) => const UserConsultScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (c) => const UserSettingScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = showRated ? rated : unrated;

    return Scaffold(
      backgroundColor: kRatScaffold,
      body: Column(
        children: [
          buildHeader(),
          buildTabSwitcher(),
          Expanded(
            child: list.isEmpty
                ? buildEmpty()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) => showRated
                        ? buildRatedCard(list[i])
                        : buildUnratedCard(list[i]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget buildHeader() {
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
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Ratings',
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${rated.length}/${rated.length + unrated.length} rated',
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

  // ── Tab Switcher ──────────────────────────────────────────────────────────
  Widget buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            buildTab(
              label: 'Pending',
              count: unrated.length,
              isActive: !showRated,
              color: Colors.orange,
              onTap: () => setState(() => showRated = false),
            ),
            buildTab(
              label: 'My Ratings',
              count: rated.length,
              isActive: showRated,
              color: kRatMain,
              onTap: () => setState(() => showRated = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTab({
    required String label,
    required int count,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : Colors.grey.shade500)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$count',
                    style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : Colors.grey.shade600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Unrated Card ──────────────────────────────────────────────────────────
  Widget buildUnratedCard(RatingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          buildAvatar(item),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.expertName,
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                Text(item.specialty,
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: kRatMain,
                        fontWeight: FontWeight.w500)),
                Text('Consulted on ${item.consultDate}',
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: Colors.grey.shade400)),
                const SizedBox(height: 4),
                Text("You haven't rated this consultation yet",
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => showRatingDialog(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kRatMain,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Rate\nNow',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Rated Card ────────────────────────────────────────────────────────────
  Widget buildRatedCard(RatingItem item) {
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
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAvatar(item),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.expertName,
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                Text(item.specialty,
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: kRatMain,
                        fontWeight: FontWeight.w500)),
                Text('Consulted on ${item.consultDate}',
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: Colors.grey.shade400)),
                const SizedBox(height: 8),
                // Stars
                Row(
                  children: [
                    ...List.generate(5, (i) {
                      final val = item.rating!;
                      if (i < val.floor()) {
                        return const Icon(Icons.star_rounded,
                            color: Color(0xFFFFBB00), size: 17);
                      } else if (i < val && val - i >= 0.5) {
                        return const Icon(Icons.star_half_rounded,
                            color: Color(0xFFFFBB00), size: 17);
                      } else {
                        return const Icon(Icons.star_outline_rounded,
                            color: Color(0xFFFFBB00), size: 17);
                      }
                    }),
                    const SizedBox(width: 6),
                    Text('${item.rating!.toStringAsFixed(1)} / 5',
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                  ],
                ),
                if (item.reviewText != null && item.reviewText!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text('"${item.reviewText}"',
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                          height: 1.4)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Delete button only — no edit
          GestureDetector(
            onTap: () => showDeleteDialog(item),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAvatar(RatingItem item) {
    return ClipOval(
      child: Image.network(
        item.avatarUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, p) {
          if (p == null) return child;
          return Container(
            width: 50,
            height: 50,
            color: kRatTeal.withOpacity(0.2),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: kRatMain),
            ),
          );
        },
        errorBuilder: (ctx, e, s) => Container(
          width: 50,
          height: 50,
          color: kRatTeal.withOpacity(0.2),
          child: Center(
            child: Text(item.expertName[0],
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kRatMain)),
          ),
        ),
      ),
    );
  }

  // ── Empty ─────────────────────────────────────────────────────────────────
  Widget buildEmpty() {
    final label =
        showRated ? 'No ratings yet' : 'All consultations have been rated!';
    final icon = showRated
        ? Icons.star_outline_rounded
        : Icons.check_circle_outline_rounded;
    final color = showRated ? Colors.grey.shade300 : kRatMain.withOpacity(0.4);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: color),
            const SizedBox(height: 12),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget buildBottomNavBar() {
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
                          color: isSel ? kRatMain : Colors.grey.shade400,
                          errorBuilder: (ctx, e, s) => Icon(
                              items[index]['fallback'] as IconData,
                              color: isSel ? kRatMain : Colors.grey.shade400,
                              size: 24)),
                      const SizedBox(height: 4),
                      Text(items[index]['label'] as String,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight:
                                  isSel ? FontWeight.w600 : FontWeight.w400,
                              color: isSel ? kRatMain : Colors.grey.shade400)),
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
