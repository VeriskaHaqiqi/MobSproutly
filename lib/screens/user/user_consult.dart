import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/consultation_provider.dart';
import '../../utils/model_converter.dart';
import 'user_home.dart';
import 'user_artikel.dart';
import 'user_pencarian.dart';
import 'user_chat.dart';
import 'user_pembayaran.dart';
import 'user_riwayat_consult.dart';
import 'user_setting.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
const Color kConsultTeal = Color(0xFF76EAD0);
const Color kConsultBlue = Color(0xFF76D7EA);
const Color kConsultMain = Color(0xFF5DCFCF);
const Color kConsultScaffold = Color(0xFFF0F4F3);

// ─── Consultation Model ───────────────────────────────────────────────────────
class ConsultItem {
  final String id;
  final String expertId;
  final String expertName;
  final String specialty;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final bool isOnline;
  final bool isRead;
  final bool isActive;
  final List<String> topics; // keyword untuk search

  const ConsultItem({
    required this.id,
    required this.expertId,
    required this.expertName,
    required this.specialty,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    this.isOnline = false,
    this.isRead = true,
    this.isActive = true,
    this.topics = const [],
  });
}


// ─── Screen ───────────────────────────────────────────────────────────────────
class UserConsultScreen extends StatefulWidget {
  const UserConsultScreen({super.key});

  @override
  State<UserConsultScreen> createState() => _UserConsultScreenState();
}

class _UserConsultScreenState extends State<UserConsultScreen> {
  int _navIndex = 2;
  bool _showActive = true;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    
    // Fetch active user consultations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConsultationProvider>(context, listen: false).fetchUserConsultations(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
  }

  List<ConsultItem> get _filtered {
    final consultationProvider = Provider.of<ConsultationProvider>(context);
    final userConsultations = consultationProvider.userConsultations;

    // Convert and filter active consultations
    final baseList = userConsultations
        .where((c) => c.status != 'completed')
        .map((c) => ModelConverter.consultationToConsultItem(c))
        .toList();

    if (_searchQuery.isEmpty) return baseList;

    return baseList.where((c) {
      return c.expertName.toLowerCase().contains(_searchQuery) ||
          c.specialty.toLowerCase().contains(_searchQuery) ||
          c.lastMessage.toLowerCase().contains(_searchQuery) ||
          c.topics.any((t) => t.toLowerCase().contains(_searchQuery));
    }).toList();
  }

  void _onNavTapped(int index) {
    if (index == _navIndex) return;
    setState(() => _navIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeUserScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const UserArtikelScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const UserSettingScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final consultationProvider = Provider.of<ConsultationProvider>(context);
    final isLoading = consultationProvider.isLoading && consultationProvider.userConsultations.isEmpty;

    return Scaffold(
      backgroundColor: kConsultScaffold,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: kConsultMain))
                : RefreshIndicator(
                    onRefresh: () => consultationProvider.fetchUserConsultations(refresh: true),
                    color: kConsultMain,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildTabSwitcher(),
                          const SizedBox(height: 12),
                          _filtered.isEmpty ? _buildEmpty() : _buildList(),
                          const SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _buildNewChatFAB(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kConsultBlue, kConsultTeal],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: Column(
            children: [
              // Title row
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
                              color: Colors.white,
                            )),
                        Text(
                          'Stay connected with your plant experts',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8)),
                        ),
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
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                      height: 1.1,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () => _searchCtrl.clear(),
                            icon: Icon(
                              Icons.close,
                              size: 22,
                              color: Colors.grey.shade400,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
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

  // ── Tab Switcher ──────────────────────────────────────────────────────────────
  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            _buildTab('Active', true),
            _buildTab('Completed', false),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    final isSelected = _showActive == isActive;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isActive && !_showActive) return;
          if (isActive && _showActive) return;
          if (!isActive) {
            // Completed → navigasi ke riwayat
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const UserRiwayatConsultScreen()),
            );
          } else {
            setState(() => _showActive = true);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? kConsultMain : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kConsultMain.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty
                ? 'No results for "$_searchQuery"'
                : 'No consultations yet',
            style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400),
          ),
          const SizedBox(height: 4),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try searching by expert name or topic'
                : 'Start a new chat with a plant expert',
            style:
                GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ── Consultation List ─────────────────────────────────────────────────────────
  Widget _buildList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey.shade100, height: 1, indent: 80),
      itemBuilder: (ctx, i) => _buildConsultCard(_filtered[i]),
    );
  }

  Widget _buildConsultCard(ConsultItem consult) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final provider = Provider.of<ConsultationProvider>(context, listen: false);
        final c = provider.userConsultations.firstWhere((item) => item.id.toString() == consult.id);

        if (c.status == 'waiting_payment' || c.status == 'rejected' || c.status == 'waiting_verification') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserPembayaranScreen(
                expert: ModelConverter.userToExpertItem(c.expert!),
                consultationId: c.id,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserChatScreen(consult: consult),
            ),
          );
        }
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            // Avatar + online dot
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.network(
                    consult.avatarUrl,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: kConsultTeal.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kConsultMain),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: kConsultTeal.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          consult.expertName[0],
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: kConsultMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (consult.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
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
            const SizedBox(width: 14),

            // Name, specialty, last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        consult.expertName,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: consult.isRead
                              ? FontWeight.w600
                              : FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        consult.time,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: consult.isRead
                              ? Colors.grey.shade400
                              : kConsultMain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    consult.specialty,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: kConsultMain,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          consult.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: consult.isRead
                                ? Colors.grey.shade500
                                : Colors.black87,
                            fontWeight: consult.isRead
                                ? FontWeight.w400
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (!consult.isRead)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: kConsultMain,
                            shape: BoxShape.circle,
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
    );
  }

  // ── New Chat FAB ──────────────────────────────────────────────────────────────
  Widget _buildNewChatFAB() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UserPencarianScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kConsultBlue, kConsultMain],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: kConsultMain.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              'New Chat',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────────
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
              final bool isSelected = _navIndex == index;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onNavTapped(index),
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
                        color: isSelected ? kConsultMain : Colors.grey.shade400,
                        errorBuilder: (_, __, ___) => Icon(
                          items[index]['fallback'] as IconData,
                          color:
                              isSelected ? kConsultMain : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isSelected ? kConsultMain : Colors.grey.shade400,
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