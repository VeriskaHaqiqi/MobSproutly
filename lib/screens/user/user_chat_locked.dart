import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_pencarian.dart';
import 'user_consult.dart';

const Color kLockedTeal = Color(0xFF76EAD0);
const Color kLockedBlue = Color(0xFF76D7EA);
const Color kLockedMain = Color(0xFF5DCFCF);
const Color kLockedLGreen = Color(0xFFD0FF99);
const Color kLockedGreen = Color(0xFF99FF99);
const Color kLockedScaffold = Color(0xFFF0F4F3);

class UserChatLockedScreen extends StatefulWidget {
  final ExpertItem expert;

  const UserChatLockedScreen({super.key, required this.expert});

  @override
  State<UserChatLockedScreen> createState() => UserChatLockedScreenState();
}

class UserChatLockedScreenState extends State<UserChatLockedScreen> {
  int selectedDuration = 30; // minutes
  final List<int> durations = [15, 30, 60];

  double get sessionPrice {
    final pricePerMinute = widget.expert.pricePerSession / 30;
    return pricePerMinute * selectedDuration;
  }

  void handleBooking() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: kLockedTeal.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    size: 36, color: kLockedMain),
              ),
              const SizedBox(height: 18),
              Text('Session Booked!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text(
                'Your $selectedDuration-minute session with ${widget.expert.name} has been confirmed.\nYou can now start chatting!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.6),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (c) => const UserConsultScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kLockedMain,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text('Go to Consultations',
                      style: GoogleFonts.outfit(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildExpertSummary(),
                  const SizedBox(height: 16),
                  buildDurationPicker(),
                  const SizedBox(height: 16),
                  buildPriceSummary(),
                  const SizedBox(height: 16),
                  buildInfoCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildConfirmBar(),
    );
  }

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
                      shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Book a Session',
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExpertSummary() {
    return Container(
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
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              widget.expert.avatarUrl,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, s) => Container(
                width: 58,
                height: 58,
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.expert.name,
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text(widget.expert.specialties.first,
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: kLockedMain,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFBB00), size: 14),
                    const SizedBox(width: 3),
                    Text(widget.expert.rating.toStringAsFixed(1),
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    Text('  •  ${widget.expert.yearsExp} yrs exp',
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: widget.expert.isAvailableNow
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.expert.isAvailableNow ? 'Online' : 'Offline',
              style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.expert.isAvailableNow
                      ? const Color(0xFF2E7D32)
                      : Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDurationPicker() {
    return Container(
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
          Text('Session Duration',
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: durations.map((d) {
              final isSel = selectedDuration == d;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedDuration = d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin:
                        EdgeInsets.only(right: d == durations.last ? 0 : 10),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel ? kLockedMain : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSel ? kLockedMain : Colors.grey.shade200,
                          width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text('$d min',
                            style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : Colors.black87)),
                        const SizedBox(height: 2),
                        Text(
                          'Rp ${((widget.expert.pricePerSession / 30) * d / 1000).toStringAsFixed(0)}K',
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: isSel
                                  ? Colors.white.withOpacity(0.85)
                                  : Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kLockedLGreen.withOpacity(0.5),
            kLockedGreen.withOpacity(0.5)
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Price',
                  style:
                      GoogleFonts.outfit(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(
                'Rp ${(sessionPrice / 1000).toStringAsFixed(0)}K',
                style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$selectedDuration minutes',
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
              const SizedBox(height: 4),
              Text(
                  'Rp ${(widget.expert.pricePerSession / 1000).toStringAsFixed(0)}K base',
                  style:
                      GoogleFonts.outfit(fontSize: 11, color: Colors.black45)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kLockedTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kLockedTeal.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: kLockedMain),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'After confirming your booking, you will be connected directly with ${widget.expert.name} for a live chat session. Make sure to prepare your plant questions in advance for a more productive session.',
              style: GoogleFonts.outfit(
                  fontSize: 12, color: Colors.black54, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildConfirmBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
        top: false,
        child: GestureDetector(
          onTap: handleBooking,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: kLockedMain,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: kLockedMain.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_open_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Confirm & Start Session  •  Rp ${(sessionPrice / 1000).toStringAsFixed(0)}K',
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
