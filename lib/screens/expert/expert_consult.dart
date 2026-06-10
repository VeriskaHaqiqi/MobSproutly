import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/consultation_provider.dart';
import '../../utils/model_converter.dart';
import '../../models/consultation_model.dart';
import 'expert_home.dart' hide ExpertAccountPage;
import 'expert_artikel.dart';
import 'expert_setting.dart';
import 'expert_chat.dart';
import 'expert_locked_chat.dart';
import 'expert_riwayat_consult.dart';

const Color kExConMain = Color(0xFF5DCFCF);
const Color kExConTeal = Color(0xFF76EAD0);
const Color kExConBlue = Color(0xFF76D7EA);
const Color kExConLGreen = Color(0xFFD0FF99);
const Color kExConScaffold = Color(0xFFF0F4F3);

String formatRupiah(num amount) {
  final value = amount.round().toString();
  final buffer = StringBuffer();

  for (int i = 0; i < value.length; i++) {
    final reverseIndex = value.length - i;
    buffer.write(value[i]);

    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return 'Rp${buffer.toString()}';
}

// ─── Consult Item Model ───────────────────────────────────────────────────────
class ExpertConsultItem {
  final String id;
  final String clientName;
  final String clientAvatar;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final bool isRead;
  final String topic;
  final double sessionFee;
  final String category;

  const ExpertConsultItem({
    required this.id,
    required this.clientName,
    required this.clientAvatar,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    required this.isRead,
    required this.topic,
    required this.sessionFee,
    required this.category,
  });
}



// ─── Screen ───────────────────────────────────────────────────────────────────
class ExpertConsultPage extends StatefulWidget {
  final int initialTabIndex;

  const ExpertConsultPage({
    super.key,
    this.initialTabIndex = 1,
  });

  @override
  State<ExpertConsultPage> createState() => ExpertConsultPageState();
}

class ExpertConsultPageState extends State<ExpertConsultPage> {
  int navIndex = 2;
  late int tabIndex;

  final TextEditingController searchCtrl = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    tabIndex = widget.initialTabIndex;

    searchCtrl.addListener(() {
      setState(() {
        searchQuery = searchCtrl.text.trim().toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConsultationProvider>(context, listen: false).fetchExpertConsultations(refresh: true);
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  List<ExpertConsultItem> get currentList {
    final provider = Provider.of<ConsultationProvider>(context);
    final expertConsultations = provider.expertConsultations;

    List<Consultation> filterList;
    switch (tabIndex) {
      case 0:
        filterList = expertConsultations.where((c) => c.status == 'waiting_verification').toList();
        break;
      case 1:
        filterList = expertConsultations.where((c) => c.status == 'active').toList();
        break;
      default:
        filterList = expertConsultations.where((c) => c.status == 'completed').toList();
    }

    final base = filterList.map((c) => ModelConverter.consultationToExpertConsultItem(c)).toList();

    if (searchQuery.isEmpty) return base;

    return base
        .where(
          (c) =>
              c.clientName.toLowerCase().contains(searchQuery) ||
              c.topic.toLowerCase().contains(searchQuery) ||
              c.category.toLowerCase().contains(searchQuery) ||
              c.lastMessage.toLowerCase().contains(searchQuery),
        )
        .toList();
  }

  void onNavTapped(int index) {
    if (index == navIndex) return;

    setState(() => navIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => ExpertHomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => ExpertArticlePage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => ExpertAccountPage()),
        );
        break;
    }
  }

  void onCardTap(ExpertConsultItem item) {
    switch (tabIndex) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ExpertLockedChatPage(consult: item),
          ),
        );
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ExpertChatPage(
              consultationId: item.id,
              clientName: item.clientName,
              clientAvatar: item.clientAvatar,
              topic: item.topic,
            ),
          ),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => ExpertRiwayatConsultPage()),
        );
        break;
    }
  }

  void openRiwayatConsult() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => ExpertRiwayatConsultPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = currentList;

    return Scaffold(
      backgroundColor: kExConScaffold,
      body: Column(
        children: [
          buildHeader(),
          buildTabBar(),
          Expanded(
            child: list.isEmpty
                ? buildEmpty()
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) => buildCard(list[i]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNav(),
    );
  }

  Widget buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kExConBlue, kExConTeal],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultations',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Manage your client sessions',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
                  controller: searchCtrl,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.1,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search consultations...',
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
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () => searchCtrl.clear(),
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

  Widget buildTabBar() {
    final provider = Provider.of<ConsultationProvider>(context);
    final expertConsultations = provider.expertConsultations;

    final requestedCount = expertConsultations.where((c) => c.status == 'waiting_verification').length;
    final activeCount = expertConsultations.where((c) => c.status == 'active').length;
    final completedCount = expertConsultations.where((c) => c.status == 'completed').length;

    final tabs = [
      _TabInfo('Requested', requestedCount, Colors.orange),
      _TabInfo('Active', activeCount, kExConMain),
      _TabInfo('Completed', completedCount, Colors.grey.shade500),
    ];

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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final tab = tabs[i];
            final isSel = tabIndex == i;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (i == 2) {
                    openRiwayatConsult();
                  } else {
                    setState(() {
                      tabIndex = i;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSel ? tab.color : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                              color: tab.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tab.label,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSel ? Colors.white : Colors.grey.shade500,
                        ),
                      ),
                      if (tab.count > 0) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSel
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${tab.count}',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color:
                                  isSel ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildEmpty() {
    final labels = [
      'No new requests',
      'No active consultations',
      'No completed consultations',
    ];

    final subs = [
      'New client requests will appear here',
      'Accepted sessions will appear here',
      'Completed sessions will appear here',
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 52,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            labels[tabIndex],
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subs[tabIndex],
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard(ExpertConsultItem item) {
    return GestureDetector(
      onTap: () => onCardTap(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: Image.network(
                    item.clientAvatar,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, p) {
                      if (p == null) return child;

                      return Container(
                        width: 52,
                        height: 52,
                        color: kExConTeal.withOpacity(0.2),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kExConMain,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, e, s) => Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: kExConTeal.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          item.clientName.isNotEmpty ? item.clientName[0] : '?',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: kExConMain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (item.isOnline && tabIndex != 0)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
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
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kExConTeal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: kExConMain,
                      ),
                    ),
                  ),
                  if (tabIndex == 0) ...[
                    const SizedBox(height: 6),
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
                    ),
                  ] else ...[
                    const SizedBox(height: 5),
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
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (tabIndex == 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kExConLGreen.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      formatRupiah(item.sessionFee),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ] else if (tabIndex == 1) ...[
                  Icon(
                    item.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 16,
                    color: item.isRead ? kExConMain : Colors.grey.shade400,
                  ),
                ] else ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: kExConTeal.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: kExConMain,
                      size: 14,
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

  Widget buildBottomNav() {
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
                        color: isSel ? kExConMain : Colors.grey.shade400,
                        errorBuilder: (_, __, ___) => Icon(
                          items[index]['fallback'] as IconData,
                          color: isSel ? kExConMain : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                          color: isSel ? kExConMain : Colors.grey.shade400,
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

class _TabInfo {
  final String label;
  final int count;
  final Color color;

  _TabInfo(this.label, this.count, this.color);
}
