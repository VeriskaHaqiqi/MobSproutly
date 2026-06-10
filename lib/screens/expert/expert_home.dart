import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/consultation_provider.dart';
import '../../providers/article_provider.dart';
import '../../utils/model_converter.dart';
import '../../models/user_model.dart';

import 'expert_tulis_artikel.dart';
import 'expert_consult.dart';
import 'expert_my_article.dart';
import 'expert_setting_jadwal.dart';
import 'expert_setting_biaya.dart';
import 'expert_chat.dart';
import 'expert_locked_chat.dart';
import 'expert_setting.dart';
import 'expert_artikel.dart';
import 'expert_detail_artikel.dart';

const Color kExHomeYellow = Color(0xFFFFFF9F);
const Color kExHomeLGreen = Color(0xFFD0FF99);
const Color kExHomeGreen = Color(0xFF99FF99);
const Color kExHomeTeal = Color(0xFF76EAD0);
const Color kExHomeBlue = Color(0xFF76D7EA);
const Color kExHomeMain = Color(0xFF5DCFCF);
const Color kExHomeScaffold = Color(0xFFF0F4F3);
const Color kExHomeDark = Color(0xFF1E2E2B);

final List<Map<String, dynamic>> _expertArticles = [
  {
    'title': 'Complete Guide to Indoor Plant Care',
    'date': '3 days ago',
    'views': '1.2K',
    'image':
        'https://images.pexels.com/photos/4505161/pexels-photo-4505161.jpeg?auto=compress&cs=tinysrgb&w=600',
  },
  {
    'title': 'How to Keep Orchids Blooming Year-Round',
    'date': '5 days ago',
    'views': '980',
    'image':
        'https://images.pexels.com/photos/1400375/pexels-photo-1400375.jpeg?auto=compress&cs=tinysrgb&w=600',
  },
  {
    'title': 'Diagnosing Yellow Leaves: A Complete Guide',
    'date': '1 week ago',
    'views': '2.1K',
    'image':
        'https://images.pexels.com/photos/4751978/pexels-photo-4751978.jpeg?auto=compress&cs=tinysrgb&w=600',
  },
];

class ExpertHomePage extends StatefulWidget {
  const ExpertHomePage({super.key});

  @override
  State<ExpertHomePage> createState() => _ExpertHomePageState();
}

class _ExpertHomePageState extends State<ExpertHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConsultationProvider>(context, listen: false).fetchExpertConsultations(refresh: true);
      Provider.of<ArticleProvider>(context, listen: false).fetchMyArticles(refresh: true);
    });
  }

  void _onConsultCardTap(BuildContext context, ExpertConsultItem item) {
    final provider = Provider.of<ConsultationProvider>(context, listen: false);
    final c = provider.expertConsultations.firstWhere((element) => element.id.toString() == item.id);

    if (c.status == 'waiting_verification') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExpertLockedChatPage(consult: item),
        ),
      ).then((_) => setState(() {}));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExpertChatPage(
            consultationId: item.id,
            clientName: item.clientName,
            clientAvatar: item.clientAvatar,
            topic: item.topic,
          ),
        ),
      ).then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final expert = Provider.of<AuthProvider>(context).user;
    return Scaffold(
      backgroundColor: kExHomeScaffold,
      body: Column(
        children: [
          _buildHeader(expert),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Provider.of<ConsultationProvider>(context, listen: false).fetchExpertConsultations(refresh: true);
                await Provider.of<ArticleProvider>(context, listen: false).fetchMyArticles(refresh: true);
              },
              color: kExHomeMain,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildUploadBanner(context),
                    const SizedBox(height: 28),
                    _buildActivitySection(context),
                    const SizedBox(height: 28),
                    _buildArticlesSection(context),
                    const SizedBox(height: 28),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(User? expert) {
    final avatar = expert != null ? ModelConverter.getUserAvatar(expert) : 'https://randomuser.me/api/portraits/women/68.jpg';
    final name = expert?.name ?? 'Expert';
    final specialization = expert?.specializations != null && expert!.specializations!.isNotEmpty
        ? expert.specializations!.first.name
        : 'Botanist';
    final availStatus = expert?.expertProfile?.availabilityStatus == 'available' ? 'Online' : 'Offline';
    final availColor = expert?.expertProfile?.availabilityStatus == 'available' ? const Color(0xFF4CAF50) : Colors.red;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kExHomeBlue, kExHomeTeal],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: ClipOval(
                  child: Image.network(
                    avatar,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, p) {
                      if (p == null) return child;
                      return Container(
                        color: Colors.white.withOpacity(0.2),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, e, s) => Container(
                      color: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.88),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: availColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$availStatus · $specialization',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Upload Banner ─────────────────────────────────────────────────────────
  Widget _buildUploadBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ExpertTulisArtikelPage()),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kExHomeLGreen, kExHomeGreen],
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
                      'Share Your Knowledge',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Write and publish articles\nto help plant enthusiasts.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExpertTulisArtikelPage(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Write Article',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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
                  child: Icon(
                    Icons.article_rounded,
                    color: kExHomeDark,
                    size: 48,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Activity Feed ─────────────────────────────────────────────────────────
  Widget _buildActivitySection(BuildContext context) {

    final consultationProvider = Provider.of<ConsultationProvider>(context);
    final consultations = consultationProvider.expertConsultations;
    final feed = consultations
        .where((c) => c.status == 'waiting_verification' || c.status == 'active')
        .map((c) => ModelConverter.consultationToExpertConsultItem(c))
        .take(5)
        .toList();

    final requestedCount = consultations.where((c) => c.status == 'waiting_verification').length;
    final hasRequested = requestedCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consultations',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    if (hasRequested)
                      Text(
                        '$requestedCount new request${requestedCount > 1 ? 's' : ''} waiting',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExpertConsultPage()),
                ).then((_) => setState(() {})),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    'See all',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: kExHomeBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (feed.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 36,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No active consultations',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...feed.map((item) => _buildActivityCard(context, item)),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, ExpertConsultItem item) {
    final provider = Provider.of<ConsultationProvider>(context, listen: false);
    final c = provider.expertConsultations.firstWhere((x) => x.id.toString() == item.id);
    final isRequested = c.status == 'waiting_verification';

    final Color badgeColor = isRequested ? Colors.orange : kExHomeMain;
    final Color badgeBg = isRequested
        ? Colors.orange.withOpacity(0.12)
        : kExHomeTeal.withOpacity(0.15);

    final String badgeLabel = isRequested ? 'New Request' : 'Ongoing';

    final IconData statusIcon = isRequested
        ? Icons.notifications_rounded
        : Icons.chat_bubble_outline_rounded;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onConsultCardTap(context, item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isRequested
              ? Border(
                  left: BorderSide(
                    color: Colors.orange.withOpacity(0.6),
                    width: 3,
                  ),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Image.network(
                    item.clientAvatar,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, p) {
                      if (p == null) return child;
                      return Container(
                        width: 48,
                        height: 48,
                        color: kExHomeTeal.withOpacity(0.2),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kExHomeMain,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, e, s) => Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: kExHomeTeal.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          item.clientName.isNotEmpty ? item.clientName[0] : '?',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: kExHomeMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isRequested && item.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 12,
                      height: 12,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.clientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        item.time,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kExHomeMain,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (isRequested)
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Waiting for payment verification',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.orange.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      item.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color:
                            item.isRead ? Colors.grey.shade500 : Colors.black87,
                        fontWeight:
                            item.isRead ? FontWeight.w400 : FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 10, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        badgeLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRequested && !item.isRead) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  // ── Articles Section ──────────────────────────────────────────────────────
  Widget _buildArticlesSection(BuildContext context) {
    final articleProvider = Provider.of<ArticleProvider>(context);
    final myArticles = articleProvider.myArticles;
    final expert = Provider.of<AuthProvider>(context, listen: false).user;

    final converted = myArticles.map((a) => ModelConverter.articleToExpertArticleItem(a, expert?.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Articles',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExpertMyArticlePage()),
                ).then((_) => setState(() {})),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    'See all',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: kExHomeBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        converted.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 36,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No articles written yet',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, right: 6),
                  itemCount: converted.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (ctx, i) =>
                      _buildArticleCard(context, converted[i]),
                ),
              ),
      ],
    );
  }

  Widget _buildArticleCard(BuildContext context, ExpertArticleItem article) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExpertDetailArtikelPage(
            article: article,
          ),
        ),
      ).then((_) => setState(() {})),
      child: Container(
        width: 210,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                article.imageUrl,
                height: 108,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, p) {
                  if (p == null) return child;
                  return Container(
                    height: 108,
                    color: kExHomeTeal.withOpacity(0.15),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: kExHomeMain,
                      ),
                    ),
                  );
                },
                errorBuilder: (ctx, e, s) => Container(
                  height: 108,
                  color: kExHomeLGreen.withOpacity(0.3),
                  child: const Center(
                    child: Icon(
                      Icons.eco_rounded,
                      color: Colors.green,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          article.time,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.remove_red_eye_outlined,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '0',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
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


  // ── Quick Actions ─────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.calendar_month_outlined,
                  label: 'Manage Schedule',
                  subtitle: 'Set your availability',
                  color: kExHomeTeal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExpertSettingJadwalPage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.attach_money_rounded,
                  label: 'Set Fee',
                  subtitle: 'Update session price',
                  color: kExHomeLGreen,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExpertSettingBiayaPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kExHomeMain, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNavBar(BuildContext context) {
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
              final bool isSel = index == 0;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (index == 0) return;

                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ExpertArticlePage()),
                    );
                  } else if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ExpertConsultPage()),
                    );
                  } else if (index == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ExpertAccountPage()),
                    );
                  }
                },
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
                        color: isSel ? kExHomeMain : Colors.grey.shade400,
                        errorBuilder: (_, __, ___) => Icon(
                          items[index]['fallback'] as IconData,
                          color: isSel ? kExHomeMain : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                          color: isSel ? kExHomeMain : Colors.grey.shade400,
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
