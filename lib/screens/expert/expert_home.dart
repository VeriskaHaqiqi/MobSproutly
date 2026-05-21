import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'expert_artikel.dart';
class ExpertHomePage extends StatelessWidget {
  const ExpertHomePage({super.key});

  static const Color kYellow = Color(0xFFFFFF9F);
  static const Color kLightGreen = Color(0xFFD0FF99);
  static const Color kGreen = Color(0xFF99FF99);
  static const Color kTosca = Color(0xFF76EAD0);
  static const Color kBlue = Color(0xFF76D7EA);

  static const Color kTextDark = Color(0xFF111827);
  static const Color kTextGrey = Color(0xFF6B7280);

  void _goTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/expert_home');
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ExpertArticlePage(),
          ),
        );
    break;
      case 2:
        Navigator.pushReplacementNamed(context, '/expert_consult');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/expert_setting');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Dr. Taehyun Chen',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: kTextDark,
                      ),
                    ),

                    const SizedBox(height: 32),

                    _buildUploadCard(context),

                    const SizedBox(height: 30),

                    _buildSectionHeader(
                      title: 'Ongoing Consultations',
                      onTap: () =>
                          _goTo(context, '/expert_consult'),
                    ),

                    const SizedBox(height: 14),

                    _buildConsultationCard(
                      image: 'assets/images/ikon profile.jpg',
                      name: 'Michael Torres',
                      message:
                          'My monstera leaves are turning yellow...',
                      time: '2h ago',
                    ),

                    _buildConsultationCard(
                      image: 'assets/images/ikon profile.jpg',
                      name: 'Emma Williams',
                      message:
                          'Thank you for the watering advice!',
                      time: '5h ago',
                    ),

                    _buildConsultationCard(
                      image: 'assets/images/ikon profile.jpg',
                      name: 'James Anderson',
                      message:
                          'Is this root rot on my fiddle leaf fig?',
                      time: '1d ago',
                    ),

                    const SizedBox(height: 30),

                    _buildSectionHeader(
                      title: 'My Articles',
                      onTap: () =>
                          _goTo(context, '/expert_artikel'),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        children: [
                          _buildArticleCard(
                            context,
                            title:
                                'Complete Guide to Indoor Plant Care',
                            date: '3 days ago',
                            views: '1.2K',
                          ),

                          const SizedBox(width: 14),

                          _buildArticleCard(
                            context,
                            title:
                                'How to Keep Plants Healthy',
                            date: '5 days ago',
                            views: '980',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            context,
                            icon:
                                'assets/images/ikon manage schedule.png',
                            title: 'Manage Schedule',
                            routeName:
                                '/expert_manage_schedule',
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: _buildQuickAction(
                            context,
                            icon:
                                'assets/images/ikon payment method.png',
                            title: 'Set Fee',
                            routeName: '/expert_set_fee',
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

      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/fotoprofile.png',
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return CircleAvatar(
                  radius: 21,
                  backgroundColor:
                      kBlue.withOpacity(0.3),
                  child: const Icon(Icons.person),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Text(
            'Home',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          _goTo(context, '/expert_write_article'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kTosca.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: kBlue.withOpacity(0.35),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: kBlue.withOpacity(0.22),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/ikon tulis artikel.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.upload,
                          color: kBlue,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload a new article',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kTextDark,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Share tips and research for plant care.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: kTextGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: kBlue,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                'Upload Article',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
        ),

        GestureDetector(
          onTap: onTap,
          child: Text(
            'See all',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationCard({
    required String image,
    required String name,
    required String message,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              image,
              width: 46,
              height: 46,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return CircleAvatar(
                  radius: 23,
                  backgroundColor:
                      kBlue.withOpacity(0.25),
                  child: const Icon(Icons.person),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: kTextGrey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      kBlue.withOpacity(0.20),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  'Ongoing',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color:
                      Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(
    BuildContext context, {
    required String title,
    required String date,
    required String views,
  }) {
    return GestureDetector(
      onTap: () =>
          _goTo(context, '/expert_article_detail'),
      child: Container(
        width: 220,
        height: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 78,
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    kLightGreen.withOpacity(
                  0.35,
                ),
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo-hijau.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (_, __, ___) {
                    return const Icon(
                      Icons.eco_outlined,
                      color: Colors.green,
                      size: 36,
                    );
                  },
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  10,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight:
                            FontWeight.w700,
                        color: kTextDark,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        Text(
                          date,
                          style:
                              GoogleFonts.inter(
                            fontSize: 11,
                            color:
                                kTextGrey,
                          ),
                        ),

                        const Spacer(),

                        Icon(
                          Icons
                              .remove_red_eye_outlined,
                          size: 14,
                          color: Colors
                              .grey.shade500,
                        ),

                        const SizedBox(
                            width: 4),

                        Text(
                          views,
                          style:
                              GoogleFonts.inter(
                            fontSize: 11,
                            color:
                                kTextGrey,
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

  Widget _buildQuickAction(
    BuildContext context, {
    required String icon,
    required String title,
    required String routeName,
  }) {
    return GestureDetector(
      onTap: () =>
          _goTo(context, routeName),
      child: Container(
        height: 108,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Image.asset(
              icon,
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.settings,
                  color: kBlue,
                );
              },
            ),

            const Spacer(),

            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(
      BuildContext context) {
    final List<Map<String, dynamic>>
        items = [
      {
        'label': 'Home',
        'icon':
            'assets/images/home.png',
        'fallback':
            Icons.home_outlined,
      },
      {
        'label': 'Articles',
        'icon':
            'assets/images/article.png',
        'fallback':
            Icons.article_outlined,
      },
      {
        'label': 'Consultations',
        'icon':
            'assets/images/consultation.png',
        'fallback':
            Icons.chat_bubble_outline,
      },
      {
        'label': 'Account',
        'icon':
            'assets/images/user.png',
        'fallback':
            Icons.person_outline,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.08,
            ),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceAround,
            children: List.generate(
              items.length,
              (index) {
                final bool isSelected =
                    index == 0;

                return GestureDetector(
                  behavior:
                      HitTestBehavior
                          .opaque,
                  onTap: () =>
                      _onBottomNavTapped(
                    context,
                    index,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Image.asset(
                          items[index]
                                  ['icon']
                              as String,
                          width: 24,
                          height: 24,
                          fit:
                              BoxFit.contain,
                          color: isSelected
                              ? kBlue
                              : Colors.grey
                                  .shade400,
                          errorBuilder:
                              (
                            _,
                            __,
                            ___,
                          ) {
                            return Icon(
                              items[index]
                                      [
                                      'fallback']
                                  as IconData,
                              color: isSelected
                                  ? kBlue
                                  : Colors
                                      .grey
                                      .shade400,
                              size: 24,
                            );
                          },
                        ),

                        const SizedBox(
                            height: 4),

                        Text(
                          items[index]
                                  ['label']
                              as String,
                          style:
                              GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight:
                                isSelected
                                    ? FontWeight
                                        .w600
                                    : FontWeight
                                        .w400,
                            color: isSelected
                                ? kBlue
                                : Colors
                                    .grey
                                    .shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}