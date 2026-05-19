import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_pencarian.dart';
import 'user_informasi_ahli.dart';
import 'user_pembayaran.dart';
import 'user_home.dart';
import 'user_artikel.dart';
import 'user_consult.dart';
import 'user_setting.dart';

const Color kLockedTeal = Color(0xFF76EAD0);
const Color kLockedBlue = Color(0xFF76D7EA);
const Color kLockedMain = Color(0xFF5DCFCF);
const Color kLockedLGreen = Color(0xFFD0FF99);
const Color kLockedGreen = Color(0xFF99FF99);
const Color kLockedScaffold = Color(0xFFE8F5F3);

class UserChatLockedScreen extends StatefulWidget {
  final ExpertItem expert;

  const UserChatLockedScreen({super.key, required this.expert});

  @override
  State<UserChatLockedScreen> createState() => UserChatLockedScreenState();
}

class UserChatLockedScreenState extends State<UserChatLockedScreen> {
  int navIndex = 2;

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
      backgroundColor: kLockedScaffold,
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  buildExpertCard(),
                  const SizedBox(height: 16),
                  buildLockedCard(),
                ],
              ),
            ),
          ),
          buildInputBar(),
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
          colors: [kLockedBlue, kLockedTeal],
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
                  'Consultations Chat',
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

  // ── Expert Card ───────────────────────────────────────────────────────────
  Widget buildExpertCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Avatar + online dot
          Stack(
            children: [
              ClipOval(
                child: Image.network(
                  widget.expert.avatarUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, p) {
                    if (p == null) return child;
                    return Container(
                      width: 56,
                      height: 56,
                      color: kLockedTeal.withOpacity(0.2),
                      child: const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: kLockedMain),
                      ),
                    );
                  },
                  errorBuilder: (ctx, e, s) => Container(
                    width: 56,
                    height: 56,
                    color: kLockedTeal.withOpacity(0.2),
                    child: Center(
                      child: Text(widget.expert.name[0],
                          style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: kLockedMain)),
                    ),
                  ),
                ),
              ),
              if (widget.expert.isAvailableNow)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Name + specialty + rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.expert.name,
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                Text(widget.expert.specialties.first,
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: kLockedMain,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFBB00), size: 15),
                    const SizedBox(width: 3),
                    Text(widget.expert.rating.toStringAsFixed(1),
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    Text('  •  ${widget.expert.yearsExp} years exp',
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ),

          // View Profile button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) =>
                    UserInformasiAhliScreen(expert: widget.expert),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: kLockedMain,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('View Profile',
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Locked Card ───────────────────────────────────────────────────────────
  Widget buildLockedCard() {
    final firstName = widget.expert.name.split(' ').first == 'Dr.'
        ? widget.expert.name.split(' ').take(2).join(' ')
        : widget.expert.name.split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: kLockedTeal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: kLockedMain, size: 34),
          ),
          const SizedBox(height: 18),

          // Title
          Text(
            'Expert Consultation',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Get personalized plant care advice from $firstName',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Session fee box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kLockedScaffold,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kLockedTeal.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session Fee',
                          style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text('45-minute consultation',
                          style: GoogleFonts.outfit(
                              fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${(widget.expert.pricePerSession / 1000).toStringAsFixed(0)}K',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Text('Valid for 7 days',
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pay Now button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => UserPembayaranScreen(expert: widget.expert),
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kLockedBlue, kLockedMain],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: kLockedMain.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Text(
                'Pay Now & Unlock Chat',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Security note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined,
                  size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                'Secure payment  •  Continue chatting after payment',
                style: GoogleFonts.outfit(
                    fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Locked Input Bar ──────────────────────────────────────────────────────
  Widget buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Photo button — disabled
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.image_outlined,
                  color: Colors.grey.shade300, size: 22),
            ),

            // Video button — disabled
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.videocam_outlined,
                  color: Colors.grey.shade300, size: 22),
            ),

            // Text field — disabled / hint only
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Type your message...',
                  style: GoogleFonts.outfit(
                      fontSize: 14, color: Colors.grey.shade400),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send button — disabled
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kLockedMain,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
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
                      Image.asset(
                        items[index]['icon'] as String,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        color: isSel ? kLockedMain : Colors.grey.shade400,
                        errorBuilder: (ctx, e, s) => Icon(
                            items[index]['fallback'] as IconData,
                            color: isSel ? kLockedMain : Colors.grey.shade400,
                            size: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(items[index]['label'] as String,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight:
                                  isSel ? FontWeight.w600 : FontWeight.w400,
                              color:
                                  isSel ? kLockedMain : Colors.grey.shade400)),
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
