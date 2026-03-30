import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBar = MediaQuery.of(context).padding.top;

    final List<Map<String, String>> consultations = [
      {
        'name': 'Isyana Saraswati',
        'message': 'Thanks for sharing the photos. I reacan',
        'time': '10m ago',
        'status': 'online',
      },
      {
        'name': 'Fathir ILKUM TM',
        'message': 'The drip system setup looks good, just...',
        'time': '2h ago',
        'status': 'online',
      },
      {
        'name': 'Pilemon',
        'message': "You're welcome! Let me know if you see...",
        'time': 'Yesterday',
        'status': 'offline',
      },
      {
        'name': 'Adela Ulin',
        'message': 'Those leaf patterns indicate a nutrient...',
        'time': 'Mar 12',
        'status': 'read',
      },
      {
        'name': 'Rafthiri Infest',
        'message': 'Current market trends show organic...',
        'time': 'Mar 10',
        'status': 'none',
      },
      {
        'name': 'Saputri',
        'message': 'Perfect! The pH levels are now optimal...',
        'time': 'Mar 8',
        'status': 'none',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: statusBar + 10,
              left: 12,
              right: 12,
              bottom: 14,
            ),
            color: const Color(0xFF74D3E6),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF2F4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Color(0xFF68707C),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Consultations',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),

          // BODY
          Expanded(
            child: Column(
              children: [
                // SEARCH
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: const Color(0xFFE9EDF2)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search,
                            size: 18, color: Color(0xFFB2BAC6)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'Search conversations...',
                              hintStyle: GoogleFonts.outfit(
                                fontSize: 12,
                                color: const Color(0xFFB2BAC6),
                              ),
                            ),
                            style: GoogleFonts.outfit(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),

                // TAB
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: const Color(0xFFE9EDF2)),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCEEEF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Active',
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF5D6B78),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Completed',
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                color: const Color(0xFF9AA3AF),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // LIST
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: consultations.length,
                    itemBuilder: (context, index) {
                      final item = consultations[index];
                      return _ConsultationTile(
                        name: item['name']!,
                        message: item['message']!,
                        time: item['time']!,
                        status: item['status']!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // BOTTOM NAV
      bottomNavigationBar: Container(
        height: 62,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE8ECF1)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _BottomItem(icon: Icons.home_rounded, label: 'Home', active: false),
            _BottomItem(
                icon: Icons.article_outlined,
                label: 'Articles',
                active: false),
            _BottomItem(
                icon: Icons.people_alt_rounded,
                label: 'Consultation',
                active: true),
            _BottomItem(
                icon: Icons.person_rounded,
                label: 'Account',
                active: false),
          ],
        ),
      ),
    );
  }
}

class _ConsultationTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String status;

  const _ConsultationTile({
    required this.name,
    required this.message,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEAEAEA),
            child: Text(
              name[0],
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5D6B78),
              ),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: const Color(0xFFB0B7C3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (status == 'read')
                      const Icon(Icons.done_all,
                          size: 13, color: Color(0xFF79D9EA)),

                    if (status == 'read') const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: const Color(0xFFA2AAB5),
                        ),
                      ),
                    ),

                    if (status == 'online')
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF6FE0A6),
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
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        active ? const Color(0xFF74D3E6) : const Color(0xFFA1A9B5);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 21, color: color),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    );
  }
}