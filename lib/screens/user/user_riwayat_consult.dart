import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_home.dart';
import 'user_artikel.dart';
import 'user_consult.dart';
import 'user_setting.dart';
import 'user_pencarian.dart';
import 'user_chat_locked.dart';
import 'package:provider/provider.dart';
import '../../providers/consultation_provider.dart';
import '../../providers/rating_provider.dart';
import '../../utils/model_converter.dart';
import '../../models/user_model.dart';

const Color kRiwayatTeal = Color(0xFF76EAD0);
const Color kRiwayatBlue = Color(0xFF76D7EA);
const Color kRiwayatMain = Color(0xFF5DCFCF);
const Color kRiwayatScaffold = Color(0xFFF0F4F3);
const Color kRiwayatLGreen = Color(0xFFD0FF99);

// ─── Completed Consultation Model ────────────────────────────────────────────
class CompletedConsultItem {
  final String id;
  final String expertName;
  final String specialty;
  final String avatarUrl;
  final double? rating; // null = not reviewed yet
  final String topic;
  final String date;
  final double price;
  final List<HistoryMessage> messages;

  const CompletedConsultItem({
    required this.id,
    required this.expertName,
    required this.specialty,
    required this.avatarUrl,
    required this.rating,
    required this.topic,
    required this.date,
    required this.price,
    required this.messages,
  });
}

class HistoryMessage {
  final String text;
  final bool isMe;
  final String time;

  const HistoryMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}


// ─── Screen ───────────────────────────────────────────────────────────────────
class UserRiwayatConsultScreen extends StatefulWidget {
  const UserRiwayatConsultScreen({super.key});

  @override
  State<UserRiwayatConsultScreen> createState() =>
      UserRiwayatConsultScreenState();
}

class UserRiwayatConsultScreenState extends State<UserRiwayatConsultScreen> {
  int navIndex = 2;
  final TextEditingController searchCtrl = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchCtrl.addListener(() {
      setState(() => searchQuery = searchCtrl.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConsultationProvider>(context, listen: false).fetchUserConsultations(refresh: true);
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  List<CompletedConsultItem> get filtered {
    final provider = Provider.of<ConsultationProvider>(context);
    final completed = provider.userConsultations.where((c) => c.status == 'completed').toList();
    
    final items = completed.map((c) {
      final expert = c.expert;
      final avatar = expert != null ? ModelConverter.getUserAvatar(expert) : 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80';
      return CompletedConsultItem(
        id: c.id.toString(),
        expertName: expert?.name ?? 'Expert',
        specialty: (expert?.specializations != null && expert!.specializations!.isNotEmpty) ? expert.specializations!.first.name : 'Botanist',
        avatarUrl: avatar,
        rating: c.rating?.score.toDouble(),
        topic: c.topic ?? 'Plant Consultation',
        date: c.createdAt != null ? '${_monthName(c.createdAt!.month)} ${c.createdAt!.day}, ${c.createdAt!.year}' : 'Recently',
        price: c.fee,
        messages: [], // Chat messages to be fetched dynamically
      );
    }).toList();

    if (searchQuery.isEmpty) return items;
    return items.where((c) {
      return c.expertName.toLowerCase().contains(searchQuery) ||
          c.specialty.toLowerCase().contains(searchQuery) ||
          c.topic.toLowerCase().contains(searchQuery);
    }).toList();
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
    return Scaffold(
      backgroundColor: kRiwayatScaffold,
      body: Column(
        children: [
          buildHeader(),
          buildTabBar(),
          Expanded(
            child: filtered.isEmpty
                ? buildEmpty()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => buildCard(filtered[i]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kRiwayatBlue, kRiwayatTeal],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        Text('Consultations',
                            style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        Text('Stay connected with your plant experts',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8))),
                      ],
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
                        offset: const Offset(0, 2))
                  ],
                ),
                child: TextField(
                  controller: searchCtrl,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.outfit(
                      fontSize: 16, color: Colors.black87, height: 1.1),
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
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

  // ── Tab Bar (Active / Completed) ──────────────────────────────────────────
  Widget buildTabBar() {
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
            // Active tab → go back to UserConsultScreen
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text('Active',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500)),
                ),
              ),
            ),
            // Completed tab → active
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: kRiwayatMain,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                        color: kRiwayatMain.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Text('Completed',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
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
          Icon(Icons.history_rounded, size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            searchQuery.isNotEmpty
                ? 'No results for "$searchQuery"'
                : 'No completed consultations',
            style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ── Consultation Card ─────────────────────────────────────────────────────
  Widget buildCard(CompletedConsultItem item) {
    final bool isReviewed = item.rating != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Expert row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ClipOval(
                  child: Image.network(
                    item.avatarUrl,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, p) {
                      if (p == null) return child;
                      return Container(
                        width: 58,
                        height: 58,
                        color: kRiwayatTeal.withOpacity(0.2),
                        child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kRiwayatMain),
                        ),
                      );
                    },
                    errorBuilder: (ctx, e, s) => Container(
                      width: 58,
                      height: 58,
                      color: kRiwayatTeal.withOpacity(0.2),
                      child: Center(
                        child: Text(item.expertName[0],
                            style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: kRiwayatMain)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + specialty + rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.expertName,
                          style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      Text(item.specialty,
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: kRiwayatMain,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 5),
                      // Stars or Not Reviewed badge
                      isReviewed
                          ? buildStars(item.rating!)
                          : buildNotReviewedBadge(),
                    ],
                  ),
                ),

                // Completed badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kRiwayatTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Completed',
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: kRiwayatMain)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Topic box ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: kRiwayatScaffold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consultation Topic',
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(item.topic,
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Date + Price row ──
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 5),
                Text(item.date,
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.grey.shade500)),
                const Spacer(),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Action buttons ──
            Row(
              children: [
                // View Details / Leave Review
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!isReviewed) {
                        showRatingDialog(item);
                      } else {
                        showReadOnlyChat(item);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isReviewed
                              ? kRiwayatTeal.withOpacity(0.4)
                              : const Color(0xFFFFFF9F),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        isReviewed ? 'View Details' : 'Leave Review',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isReviewed
                              ? kRiwayatMain
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Chat Again
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final consultation = Provider.of<ConsultationProvider>(context, listen: false)
                          .userConsultations
                          .firstWhere((c) => c.id.toString() == item.id);
                      final User? rawExpert = consultation.expert;
                      
                      if (rawExpert != null) {
                        final expertItem = ModelConverter.userToExpertItem(rawExpert);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) =>
                                UserChatLockedScreen(expert: expertItem),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: kRiwayatMain,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Chat Again',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStars(double rating) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return const Icon(Icons.star_rounded,
                color: Color(0xFFFFBB00), size: 16);
          } else if (i < rating && rating - i >= 0.5) {
            return const Icon(Icons.star_half_rounded,
                color: Color(0xFFFFBB00), size: 16);
          } else {
            return const Icon(Icons.star_outline_rounded,
                color: Color(0xFFFFBB00), size: 16);
          }
        }),
        const SizedBox(width: 5),
        Text(rating.toStringAsFixed(1),
            style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ],
    );
  }

  Widget buildNotReviewedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text('Not Reviewed',
          style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500)),
    );
  }

  // ── Read-Only Chat (View Details) ─────────────────────────────────────────
  void showReadOnlyChat(CompletedConsultItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5F3),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),

              // Header
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kRiwayatBlue, kRiwayatTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipOval(
                      child: Image.network(item.avatarUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                              width: 36,
                              height: 36,
                              color: kRiwayatTeal.withOpacity(0.3),
                              child: Center(
                                  child: Text(item.expertName[0],
                                      style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: kRiwayatMain))))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.expertName,
                              style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          Text(item.specialty,
                              style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    // Read-only badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline_rounded,
                              size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('Read Only',
                              style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: item.messages.length,
                  itemBuilder: (ctx, i) =>
                      buildReadOnlyBubble(item, item.messages[i]),
                ),
              ),

              // Locked input bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -3))
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            color: Colors.grey.shade400, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'This consultation has ended',
                          style: GoogleFonts.outfit(
                              fontSize: 13, color: Colors.grey.shade400),
                        ),
                      ],
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

  Widget buildReadOnlyBubble(CompletedConsultItem item, HistoryMessage msg) {
    final isMe = msg.isMe;
    final maxWidth = MediaQuery.of(context).size.width * 0.68;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                ClipOval(
                  child: Image.network(
                    item.avatarUrl,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, s) => Container(
                      width: 30,
                      height: 30,
                      color: kRiwayatTeal.withOpacity(0.3),
                      child: Center(
                        child: Text(item.expertName[0],
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: kRiwayatMain)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? kRiwayatMain : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Text(msg.text,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isMe ? Colors.white : Colors.black87,
                        height: 1.45)),
              ),
              if (isMe) const SizedBox(width: 4),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                top: 3, bottom: 10, left: isMe ? 0 : 38, right: isMe ? 4 : 0),
            child: Text(msg.time,
                style: GoogleFonts.outfit(
                    fontSize: 10, color: Colors.grey.shade400)),
          ),
        ],
      ),
    );
  }

  // ── Rating Dialog ─────────────────────────────────────────────────────────
  void showRatingDialog(CompletedConsultItem item) {
    int selectedStars = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Rate Your Session',
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 6),
                Text(
                  'How was your consultation\nwith ${item.expertName}?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return GestureDetector(
                      onTap: () => setDialog(() => selectedStars = star),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          star <= selectedStars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 36,
                          color: star <= selectedStars
                              ? const Color(0xFFFFBB00)
                              : Colors.grey.shade300,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedStars > 0
                        ? () async {
                            Navigator.pop(ctx);
                            final success = await Provider.of<RatingProvider>(context, listen: false).submitRating(
                              consultationId: int.parse(item.id),
                              score: selectedStars,
                            );
                            if (success && mounted) {
                              Provider.of<ConsultationProvider>(context, listen: false).fetchUserConsultations(refresh: true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Rating submitted successfully!'),
                                  backgroundColor: kRiwayatMain,
                                ),
                              );
                            } else if (mounted) {
                              final err = Provider.of<RatingProvider>(context, listen: false).errorMessage ?? 'Failed to submit rating';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(err),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRiwayatMain,
                      disabledBackgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text('Submit Rating',
                        style: GoogleFonts.outfit(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Skip',
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
              offset: const Offset(0, -4))
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
                          color: isSel ? kRiwayatMain : Colors.grey.shade400,
                          errorBuilder: (ctx, e, s) => Icon(
                              items[index]['fallback'] as IconData,
                              color:
                                  isSel ? kRiwayatMain : Colors.grey.shade400,
                              size: 24)),
                      const SizedBox(height: 4),
                      Text(items[index]['label'] as String,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight:
                                  isSel ? FontWeight.w600 : FontWeight.w400,
                              color:
                                  isSel ? kRiwayatMain : Colors.grey.shade400)),
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
