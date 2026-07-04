import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/expert_provider.dart';
import '../../utils/model_converter.dart';
import 'user_home.dart';
import 'user_artikel.dart';
import 'user_consult.dart';
import 'user_setting.dart';
import 'user_informasi_ahli.dart';

const Color kPencarianTeal = Color(0xFF76EAD0);
const Color kPencarianBlue = Color(0xFF76D7EA);
const Color kPencarianMain = Color(0xFF5DCFCF);
const Color kPencarianScaffold = Color(0xFFF0F4F3);
const Color kPencarianLGreen = Color(0xFFD0FF99);


// ─── Expert Model ─────────────────────────────────────────────────────────────
class ExpertItem {
  final String id;
  final String name;
  final String degree;
  final double rating;
  final int yearsExp;
  final bool isAvailableNow;
  final String availableText;
  final List<String> specialties;
  final String bio;
  final String avatarUrl;
  final String category; // single category — strictly one of the 4
  final double pricePerSession;
  final List<String> topics;
  final int totalConsultations;
  final String avgResponse;
  final List<ReviewItem> reviews;

  const ExpertItem({
    required this.id,
    required this.name,
    required this.degree,
    required this.rating,
    required this.yearsExp,
    required this.isAvailableNow,
    required this.availableText,
    required this.specialties,
    required this.bio,
    required this.avatarUrl,
    required this.category,
    required this.pricePerSession,
    required this.topics,
    required this.totalConsultations,
    required this.avgResponse,
    required this.reviews,
  });
}

class ReviewItem {
  final String name;
  final String avatarUrl;
  final int stars;
  final String comment;

  const ReviewItem({
    required this.name,
    required this.avatarUrl,
    required this.stars,
    required this.comment,
  });
}



// ─── Screen ───────────────────────────────────────────────────────────────────
class UserPencarianScreen extends StatefulWidget {
  const UserPencarianScreen({super.key});

  @override
  State<UserPencarianScreen> createState() => UserPencarianScreenState();
}

class UserPencarianScreenState extends State<UserPencarianScreen> {
  int navIndex = 0;
  final TextEditingController searchCtrl = TextEditingController();
  String searchQuery = '';
  String selectedCategory = 'All';

  double minRating = 0;
  double maxPrice = 100000;
  bool onlyAvailable = false;
  String sortBy = 'rating';

  @override
  void initState() {
    super.initState();
    searchCtrl.addListener(() =>
        setState(() => searchQuery = searchCtrl.text.trim().toLowerCase()));
    
    // Fetch experts from database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpertProvider>(context, listen: false).fetchExperts(refresh: true);
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  List<ExpertItem> get filteredExperts {
    final expertProvider = Provider.of<ExpertProvider>(context);
    final rawExperts = expertProvider.experts;
    List<ExpertItem> list = rawExperts.map((e) => ModelConverter.userToExpertItem(e)).toList();

    list = list.where((e) {
      final matchCat =
          selectedCategory == 'All' || e.specialties.contains(selectedCategory) || e.category == selectedCategory;
      final matchSearch = searchQuery.isEmpty ||
          e.name.toLowerCase().contains(searchQuery) ||
          e.degree.toLowerCase().contains(searchQuery) ||
          e.specialties.any((s) => s.toLowerCase().contains(searchQuery)) ||
          e.topics.any((t) => t.toLowerCase().contains(searchQuery));
      final matchRating = e.rating >= minRating;
      final matchPrice = e.pricePerSession <= maxPrice;
      final matchAvail = !onlyAvailable || e.isAvailableNow;
      return matchCat && matchSearch && matchRating && matchPrice && matchAvail;
    }).toList();

    switch (sortBy) {
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 'price_asc':
        list.sort((a, b) => a.pricePerSession.compareTo(b.pricePerSession));
      case 'price_desc':
        list.sort((a, b) => b.pricePerSession.compareTo(a.pricePerSession));
      case 'exp':
        list.sort((a, b) => b.yearsExp.compareTo(a.yearsExp));
    }
    return list;
  }

  bool get hasActiveFilters =>
      minRating > 0 || maxPrice < 100000 || onlyAvailable || sortBy != 'rating';

  void onNavTapped(int index) {
    if (index == navIndex) return;
    setState(() => navIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => HomeUserScreen()));
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (c) => const UserArtikelScreen()));
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (c) => const UserConsultScreen()));
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (c) => const UserSettingScreen()));
    }
  }

  void openFilterSheet() {
    double tRating = minRating;
    double tPrice = maxPrice;
    bool tAvail = onlyAvailable;
    String tSort = sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filter & Sort',
                        style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    GestureDetector(
                      onTap: () => ss(() {
                        tRating = 0;
                        tPrice = 100000;
                        tAvail = false;
                        tSort = 'rating';
                      }),
                      child: Text('Reset',
                          style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: kPencarianMain,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Sort By',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _chip('Top Rated', 'rating', tSort,
                        () => ss(() => tSort = 'rating')),
                    _chip('Price: Low to High', 'price_asc', tSort,
                        () => ss(() => tSort = 'price_asc')),
                    _chip('Price: High to Low', 'price_desc', tSort,
                        () => ss(() => tSort = 'price_desc')),
                    _chip('Most Experienced', 'exp', tSort,
                        () => ss(() => tSort = 'exp')),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Minimum Rating',
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFBB00), size: 15),
                      const SizedBox(width: 4),
                      Text(tRating == 0 ? 'Any' : tRating.toStringAsFixed(1),
                          style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: kPencarianMain,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
                Slider(
                    value: tRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    activeColor: kPencarianMain,
                    inactiveColor: kPencarianTeal.withOpacity(0.3),
                    onChanged: (v) => ss(() => tRating = v)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Max Price / Session',
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    Text('Rp ${(tPrice / 1000).toStringAsFixed(0)}K',
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: kPencarianMain,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                Slider(
                    value: tPrice,
                    min: 10000,
                    max: 100000,
                    divisions: 18,
                    activeColor: kPencarianMain,
                    inactiveColor: kPencarianTeal.withOpacity(0.3),
                    onChanged: (v) => ss(() => tPrice = v)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available Now Only',
                              style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87)),
                          Text('Show only currently available experts',
                              style: GoogleFonts.outfit(
                                  fontSize: 11, color: Colors.grey.shade500)),
                        ]),
                    Switch(
                        value: tAvail,
                        activeColor: kPencarianMain,
                        onChanged: (v) => ss(() => tAvail = v)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        minRating = tRating;
                        maxPrice = tPrice;
                        onlyAvailable = tAvail;
                        sortBy = tSort;
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPencarianMain,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text('Apply Filters',
                        style: GoogleFonts.outfit(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(
      String label, String value, String groupValue, VoidCallback onTap) {
    final sel = value == groupValue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? kPencarianMain : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : Colors.grey.shade600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expertProvider = Provider.of<ExpertProvider>(context);
    final experts = filteredExperts;
    final isLoading = expertProvider.isLoading && expertProvider.experts.isEmpty;

    return Scaffold(
      backgroundColor: kPencarianScaffold,
      body: Column(
        children: [
          buildHeader(),
          buildCategoryBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: kPencarianMain))
                : experts.isEmpty
                    ? buildEmpty()
                    : RefreshIndicator(
                        onRefresh: () => expertProvider.fetchExperts(refresh: true),
                        color: kPencarianMain,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: experts.length,
                          itemBuilder: (ctx, i) => buildExpertCard(experts[i]),
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(),
    );
  }

  Widget buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPencarianBlue, kPencarianTeal]),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
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
                          shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Find Expert',
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
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
                        offset: const Offset(0, 2))
                  ],
                ),
                child: TextField(
                  controller: searchCtrl,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.outfit(
                      fontSize: 16, color: Colors.black87, height: 1.1),
                  decoration: InputDecoration(
                    hintText: 'Search by name or specialty...',
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

  List<String> get dynamicCategories {
    final expertProvider = Provider.of<ExpertProvider>(context);
    final rawExperts = expertProvider.experts;
    List<ExpertItem> list = rawExperts.map((e) => ModelConverter.userToExpertItem(e)).toList();
    
    Set<String> categories = {'All'};
    for (var expert in list) {
      for (var spec in expert.specialties) {
        categories.add(spec);
      }
    }
    return categories.toList();
  }

  Widget buildCategoryBar() {
    final cats = dynamicCategories;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: openFilterSheet,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: hasActiveFilters
                          ? kPencarianMain
                          : kPencarianTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tune_rounded,
                            size: 15,
                            color: hasActiveFilters
                                ? Colors.white
                                : kPencarianMain),
                        const SizedBox(width: 6),
                        Text(hasActiveFilters ? 'Filters (active)' : 'Filters',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: hasActiveFilters
                                    ? Colors.white
                                    : kPencarianMain)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${filteredExperts.length} expert${filteredExperts.length == 1 ? '' : 's'} found',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 8),
              itemCount: cats.length,
              itemBuilder: (ctx, i) {
                final cat = cats[i];
                final sel = cat == selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: sel ? kPencarianMain : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? kPencarianMain : Colors.grey.shade200,
                          width: 1),
                    ),
                    child: Center(
                      child: Text(cat,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color:
                                  sel ? Colors.white : Colors.grey.shade600)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No experts found',
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400)),
            const SizedBox(height: 4),
            Text('Try adjusting your search or filters',
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  Widget buildExpertCard(ExpertItem expert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  expert.avatarUrl,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, p) {
                    if (p == null) return child;
                    return Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                          color: kPencarianTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kPencarianMain)),
                    );
                  },
                  errorBuilder: (ctx, e, s) => Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                        color: kPencarianTeal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                        child: Text(expert.name[0],
                            style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: kPencarianMain))),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expert.name,
                        style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(expert.degree,
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.grey.shade500)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFBB00), size: 15),
                      const SizedBox(width: 4),
                      Text(expert.rating.toStringAsFixed(1),
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      Text('  •  ${expert.yearsExp} yrs exp',
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: Colors.grey.shade500)),
                    ]),
                    const SizedBox(height: 4),
                    Text(expert.availableText,
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: expert.isAvailableNow
                                ? const Color(0xFF2E7D32)
                                : Colors.orange.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: expert.specialties
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: kPencarianTeal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(s,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: kPencarianMain,
                              fontWeight: FontWeight.w500)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          Text(expert.bio,
              style: GoogleFonts.outfit(
                  fontSize: 12, color: Colors.grey.shade600, height: 1.5)),
          const SizedBox(height: 6),
          Text(
              'Rp ${(expert.pricePerSession / 1000).toStringAsFixed(0)}K / session',
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: kPencarianMain)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => UserInformasiAhliScreen(expert: expert)),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                  color: kPencarianMain,
                  borderRadius: BorderRadius.circular(12)),
              child: Text('View Profile',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

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
              final bool sel = navIndex == index;
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
                          color: sel ? kPencarianMain : Colors.grey.shade400,
                          errorBuilder: (ctx, e, s) => Icon(
                              items[index]['fallback'] as IconData,
                              color:
                                  sel ? kPencarianMain : Colors.grey.shade400,
                              size: 24)),
                      const SizedBox(height: 4),
                      Text(items[index]['label'] as String,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight:
                                  sel ? FontWeight.w600 : FontWeight.w400,
                              color:
                                  sel ? kPencarianMain : Colors.grey.shade400)),
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
