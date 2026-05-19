import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_home.dart';
import 'user_artikel.dart';
import 'user_consult.dart';
import 'user_setting.dart';
import 'user_pencarian.dart';
import 'user_chat_locked.dart';

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

// ─── Dummy Data ───────────────────────────────────────────────────────────────
final List<CompletedConsultItem> completedConsults = [
  CompletedConsultItem(
    id: '1',
    expertName: 'Dr. Sarah Mitchell',
    specialty: 'Orchid Specialist',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108755-2616b612b77c?w=150&q=80',
    rating: 5.0,
    topic: 'Orchid root care discussion',
    date: 'Dec 18, 2024',
    price: 45.00,
    messages: [
      HistoryMessage(
          text:
              'Hi! I need help with my orchid roots — they look brown and mushy.',
          isMe: true,
          time: '10:00 AM'),
      HistoryMessage(
          text:
              'Thank you for reaching out! Brown mushy roots usually indicate root rot from overwatering. Can you send me a photo?',
          isMe: false,
          time: '10:02 AM'),
      HistoryMessage(
          text: 'Here\'s the photo — you can see the damage clearly.',
          isMe: true,
          time: '10:05 AM'),
      HistoryMessage(
          text:
              'Yes, this is definitely root rot. I recommend removing all affected roots with sterilized scissors, then repotting in fresh orchid bark. Let the roots dry for 30 minutes before repotting.',
          isMe: false,
          time: '10:08 AM'),
      HistoryMessage(
          text: 'Should I use any fungicide?', isMe: true, time: '10:10 AM'),
      HistoryMessage(
          text:
              'Yes! Apply a diluted cinnamon powder or a commercial orchid fungicide on the cut ends before repotting. This prevents further infection. Water only once the bark is completely dry.',
          isMe: false,
          time: '10:12 AM'),
      HistoryMessage(
          text: 'Thank you so much! This is really helpful.',
          isMe: true,
          time: '10:15 AM'),
      HistoryMessage(
          text:
              'You\'re welcome! Your orchid should recover well. Feel free to reach out if you notice any new symptoms. Good luck!',
          isMe: false,
          time: '10:16 AM'),
    ],
  ),
  CompletedConsultItem(
    id: '2',
    expertName: 'Mark Thompson',
    specialty: 'Tomato Specialist',
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80',
    rating: 4.0,
    topic: 'Tomato fungus issue',
    date: 'Dec 12, 2024',
    price: 38.00,
    messages: [
      HistoryMessage(
          text: 'My tomato leaves have white powdery spots. What could it be?',
          isMe: true,
          time: '2:00 PM'),
      HistoryMessage(
          text:
              'That sounds like powdery mildew, a common fungal disease. Is the weather humid where you are?',
          isMe: false,
          time: '2:03 PM'),
      HistoryMessage(
          text: 'Yes, it\'s been very humid lately.',
          isMe: true,
          time: '2:05 PM'),
      HistoryMessage(
          text:
              'That confirms it. Mix 1 tablespoon of baking soda with 1 liter of water and spray the affected leaves. Repeat every 3 days for 2 weeks. Also improve air circulation around the plant.',
          isMe: false,
          time: '2:07 PM'),
      HistoryMessage(
          text: 'Can I still eat the tomatoes?', isMe: true, time: '2:09 PM'),
      HistoryMessage(
          text:
              'The fruits are safe to eat as long as they look healthy. Remove any severely infected leaves and dispose of them away from your garden.',
          isMe: false,
          time: '2:11 PM'),
    ],
  ),
  CompletedConsultItem(
    id: '3',
    expertName: 'Dr. Emily Chen',
    specialty: 'Plant Disease Expert',
    avatarUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&q=80',
    rating: null, // Not reviewed
    topic: 'Leaf yellowing consultation',
    date: 'Dec 5, 2024',
    price: 42.00,
    messages: [
      HistoryMessage(
          text: 'My calathea leaves are turning yellow from the edges. Help!',
          isMe: true,
          time: '3:30 PM'),
      HistoryMessage(
          text:
              'Edge yellowing on calathea usually points to fluoride toxicity or inconsistent watering. Do you use tap water directly?',
          isMe: false,
          time: '3:33 PM'),
      HistoryMessage(
          text: 'Yes, I just use tap water from the sink.',
          isMe: true,
          time: '3:35 PM'),
      HistoryMessage(
          text:
              'That\'s likely the cause. Calathea is very sensitive to fluoride and chlorine in tap water. Switch to filtered water or leave tap water out overnight before using it. Also ensure the pot has proper drainage.',
          isMe: false,
          time: '3:38 PM'),
      HistoryMessage(
          text: 'How often should I water it?', isMe: true, time: '3:40 PM'),
      HistoryMessage(
          text:
              'Keep the soil consistently moist but never soggy. Typically every 5-7 days in warm weather, less in winter. Always check the top inch of soil before watering.',
          isMe: false,
          time: '3:42 PM'),
    ],
  ),
  CompletedConsultItem(
    id: '4',
    expertName: 'James Rodriguez',
    specialty: 'Hydroponic Expert',
    avatarUrl:
        'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=150&q=80',
    rating: 5.0,
    topic: 'Hydroponic setup guidance',
    date: 'Nov 28, 2024',
    price: 50.00,
    messages: [
      HistoryMessage(
          text:
              'I want to start a hydroponic system at home for lettuce. Where do I begin?',
          isMe: true,
          time: '9:00 AM'),
      HistoryMessage(
          text:
              'Great choice! For beginners, I recommend a simple Deep Water Culture (DWC) setup. You\'ll need a reservoir, an air pump, net pots, and nutrient solution.',
          isMe: false,
          time: '9:03 AM'),
      HistoryMessage(
          text: 'What nutrients do I need exactly?',
          isMe: true,
          time: '9:05 AM'),
      HistoryMessage(
          text:
              'For lettuce, use a balanced hydroponic nutrient solution with an EC of 0.8-1.2 and pH between 6.0-6.5. I recommend General Hydroponics Flora Series for beginners.',
          isMe: false,
          time: '9:08 AM'),
      HistoryMessage(
          text: 'How much light does lettuce need?',
          isMe: true,
          time: '9:10 AM'),
      HistoryMessage(
          text:
              '14-16 hours of light per day works best. A 4000K LED grow light placed 30cm above the plants is ideal. Your lettuce should be ready to harvest in 30-45 days!',
          isMe: false,
          time: '9:12 AM'),
    ],
  ),
  CompletedConsultItem(
    id: '5',
    expertName: 'Lisa Anderson',
    specialty: 'Botanist',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&q=80',
    rating: 4.5,
    topic: 'Indoor plant selection advice',
    date: 'Nov 20, 2024',
    price: 35.00,
    messages: [
      HistoryMessage(
          text:
              'I want to add more plants to my apartment but I have low light conditions. Any suggestions?',
          isMe: true,
          time: '11:00 AM'),
      HistoryMessage(
          text:
              'Perfect! Low light plants are my specialty. ZZ plants, pothos, snake plants, and peace lilies are all excellent choices for dim apartments.',
          isMe: false,
          time: '11:02 AM'),
      HistoryMessage(
          text: 'Which one is easiest to maintain?',
          isMe: true,
          time: '11:04 AM'),
      HistoryMessage(
          text:
              'The ZZ plant is virtually indestructible. It tolerates neglect, infrequent watering, and very low light. Perfect for busy plant parents. Pothos is a close second.',
          isMe: false,
          time: '11:06 AM'),
      HistoryMessage(
          text: 'How about air purifying plants?',
          isMe: true,
          time: '11:08 AM'),
      HistoryMessage(
          text:
              'Snake plant (Sansevieria) is one of the best air purifiers and thrives in low light. Peace lily also purifies air and even blooms occasionally indoors. Both are great choices!',
          isMe: false,
          time: '11:10 AM'),
    ],
  ),
];

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
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  List<CompletedConsultItem> get filtered {
    if (searchQuery.isEmpty) return completedConsults;
    return completedConsults.where((c) {
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
                      // Find matching expert from allExperts
                      ExpertItem? expert;
                      try {
                        expert = allExperts.firstWhere(
                          (e) => e.name.toLowerCase().contains(
                              item.expertName.split(' ').last.toLowerCase()),
                        );
                      } catch (_) {
                        expert =
                            allExperts.isNotEmpty ? allExperts.first : null;
                      }
                      if (expert != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) =>
                                UserChatLockedScreen(expert: expert!),
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
                        ? () {
                            setState(() {
                              // Update rating in list
                              final idx = completedConsults
                                  .indexWhere((c) => c.id == item.id);
                              if (idx != -1) {
                                completedConsults[idx] = CompletedConsultItem(
                                  id: item.id,
                                  expertName: item.expertName,
                                  specialty: item.specialty,
                                  avatarUrl: item.avatarUrl,
                                  rating: selectedStars.toDouble(),
                                  topic: item.topic,
                                  date: item.date,
                                  price: item.price,
                                  messages: item.messages,
                                );
                              }
                            });
                            Navigator.pop(ctx);
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
