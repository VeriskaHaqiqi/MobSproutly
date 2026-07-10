import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/consultation_provider.dart';
import '../../utils/model_converter.dart';
import 'user_pencarian.dart';
import 'user_chat.dart';
import 'user_consult.dart';

const Color kPayTeal = Color(0xFF76EAD0);
const Color kPayBlue = Color(0xFF76D7EA);
const Color kPayMain = Color(0xFF5DCFCF);
const Color kPayLGreen = Color(0xFFD0FF99);
const Color kPayScaffold = Color(0xFFF0F4F3);

class UserPembayaranScreen extends StatefulWidget {
  final ExpertItem expert;
  final int? consultationId;

  const UserPembayaranScreen({super.key, required this.expert, this.consultationId});

  @override
  State<UserPembayaranScreen> createState() => UserPembayaranScreenState();
}

class UserPembayaranScreenState extends State<UserPembayaranScreen> {
  // State variables
  String? uploadedFileName;
  File? uploadedFile;
  bool isUploading = false;
  bool isConfirming = false;

  String get bankName {
    final consultationProvider = Provider.of<ConsultationProvider>(context);
    return consultationProvider.expertBank?['bank_name'] ?? 'BNI';
  }

  String get accountNumber {
    final consultationProvider = Provider.of<ConsultationProvider>(context);
    return consultationProvider.expertBank?['account_number'] ?? '1234 5678 9012';
  }

  String get accountHolder {
    final consultationProvider = Provider.of<ConsultationProvider>(context);
    return consultationProvider.expertBank?['account_holder'] ??
        widget.expert.name.replaceAll('Dr. ', '').replaceAll('Dr.', '');
  }

  double get consultationFee {
    final consultationProvider = Provider.of<ConsultationProvider>(context);
    return consultationProvider.currentConsultation?.fee ?? widget.expert.pricePerSession;
  }

  double get platformFee => 2500;
  double get totalFee => consultationFee + platformFee;

  String formatRupiah(double value) {
    final number = value.round().toString();
    final result = number.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return 'Rp $result';
  }

  Future<void> pickFile() async {
    try {
      setState(() => isUploading = true);
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          uploadedFileName = result.files.first.name;
          if (result.files.first.path != null) {
            uploadedFile = File(result.files.first.path!);
          }
        });
      }
    } catch (_) {
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final consultationProvider = Provider.of<ConsultationProvider>(context, listen: false);
      if (widget.consultationId != null) {
        consultationProvider.fetchConsultationDetail(widget.consultationId!);
      } else {
        consultationProvider.startConsultation(
          int.parse(widget.expert.id),
          'Consultation about ${widget.expert.specialties.first}',
        );
      }
    });
  }

  void handleConfirm() async {
    final consultationProvider = Provider.of<ConsultationProvider>(context, listen: false);
    final currentCon = consultationProvider.currentConsultation;

    if (currentCon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(consultationProvider.errorMessage ?? 'Failed to start consultation. Please try again.',
              style: GoogleFonts.outfit(fontSize: 13)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (uploadedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload your payment receipt first.',
              style: GoogleFonts.outfit(fontSize: 13)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => isConfirming = true);

    final success = await consultationProvider.uploadPaymentProof(
      currentCon.id,
      uploadedFile!.path,
    );

    setState(() => isConfirming = false);

    if (success) {
      showUploadedSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(consultationProvider.errorMessage ?? 'Upload failed. Please try again.',
              style: GoogleFonts.outfit(fontSize: 13)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void showUploadedSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kPayTeal.withOpacity(0.3),
                      kPayTeal.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: kPayTeal.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: kPayMain, size: 28),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text('Proof Uploaded',
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text(
                'Your payment proof has been successfully uploaded. Please wait for the expert to verify it.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.55),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPayBlue, kPayMain],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('OK',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Verified Dialog ───────────────────────────────────────────────────────
  void showVerifiedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close X
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child:
                      Icon(Icons.close, color: Colors.grey.shade400, size: 20),
                ),
              ),
              const SizedBox(height: 4),

              // Check icon circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kPayTeal.withOpacity(0.3),
                      kPayTeal.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: kPayTeal.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: kPayMain, size: 28),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text('Payment Verified',
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text(
                'Your payment has been successfully verified. You can now begin the consultation session.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.55),
              ),
              const SizedBox(height: 20),

              // Info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPayScaffold,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sarah Johnson',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    Text('New client',
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.grey.shade500)),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade200, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Consultation Type',
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: Colors.grey.shade500)),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded,
                                color: kPayMain, size: 14),
                            const SizedBox(width: 5),
                            Text('Chat Consultation',
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Payment Status',
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: Colors.grey.shade500)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: kPayTeal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                    color: kPayMain, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 5),
                              Text('Verified',
                                  style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: kPayMain)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Start Consultation
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  // Build a dummy ConsultItem from the expert
                  final consult = ConsultItem(
                    id: widget.expert.id,
                    expertId: widget.expert.id,
                    expertName: widget.expert.name,
                    specialty: widget.expert.specialties.first,
                    lastMessage: 'Session started',
                    time: 'Just now',
                    avatarUrl: widget.expert.avatarUrl,
                    isOnline: widget.expert.isAvailableNow,
                    isRead: true,
                    isActive: true,
                    topics: widget.expert.topics,
                    sessionDurationMinutes: widget.expert.sessionDurationMinutes,
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (c) => UserChatScreen(consult: consult),
                    ),
                    (route) => route.isFirst,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPayBlue, kPayMain],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: kPayMain.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Text('Start Consultation',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),

              // Close
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Close',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Rejected Dialog ───────────────────────────────────────────────────────
  void showRejectedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close X
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child:
                      Icon(Icons.close, color: Colors.grey.shade400, size: 20),
                ),
              ),
              const SizedBox(height: 4),

              // ! icon circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                ),
                child: Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.priority_high_rounded,
                        color: Colors.redAccent, size: 28),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text('Payment Rejected',
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text(
                'Your payment could not be verified. Please review the details and try again to begin the consultation session.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.55),
              ),
              const SizedBox(height: 20),

              // Info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPayScaffold,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: kPayTeal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.eco_rounded,
                              color: kPayMain, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.expert.name,
                                style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87)),
                            Text('New Client',
                                style: GoogleFonts.outfit(
                                    fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade200, height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Payment Status',
                              style: GoogleFonts.outfit(
                                  fontSize: 12, color: Colors.grey.shade500)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 5),
                              Text('Rejected',
                                  style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Possible reasons box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.red.withOpacity(0.15), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Colors.redAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Possible reasons: incorrect transfer amount, unclear payment proof, or failed verification.',
                        style: GoogleFonts.outfit(
                            fontSize: 12, color: Colors.redAccent, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Retry Payment
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  // Reset upload state and stay on this page
                  setState(() {
                    uploadedFileName = null;
                    uploadedFile = null;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.red.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Text('Retry Payment',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),

              // Close
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Close',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPayScaffold,
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
                  const SizedBox(height: 22),
                  buildSectionTitle('Payment Method'),
                  const SizedBox(height: 10),
                  buildPaymentMethod(),
                  const SizedBox(height: 22),
                  buildSectionTitle('Expert Bank Account'),
                  const SizedBox(height: 10),
                  buildBankAccount(),
                  const SizedBox(height: 22),
                  buildSectionTitle('Payment Details'),
                  const SizedBox(height: 10),
                  buildPaymentDetails(),
                  const SizedBox(height: 22),
                  buildSectionTitle('Payment Instructions'),
                  const SizedBox(height: 10),
                  buildInstructions(),
                  const SizedBox(height: 22),
                  buildSectionTitle('Payment Proof'),
                  const SizedBox(height: 10),
                  buildUploadBox(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Secure payment  •  Your consultation will unlock after confirmation',
                          style: GoogleFonts.outfit(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  buildConfirmButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPayBlue, kPayTeal],
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
              Text('Payment',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Expert Summary ────────────────────────────────────────────────────────
  Widget buildExpertSummary() {
    final consultationProvider = Provider.of<ConsultationProvider>(context);
    final currentCon = consultationProvider.currentConsultation;
    final duration = currentCon?.duration ?? 30;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.network(
              widget.expert.avatarUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, s) => Container(
                width: 56,
                height: 56,
                color: kPayTeal.withOpacity(0.2),
                child: Center(
                  child: Text(widget.expert.name[0],
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kPayMain)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                        fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kPayTeal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Live Chat',
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: kPayMain,
                              fontWeight: FontWeight.w600)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('•',
                          style: GoogleFonts.outfit(
                              fontSize: 11, color: Colors.grey.shade400)),
                    ),
                    Text('$duration minutes',
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.expert.specialties.first.toLowerCase()} consultation',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87));
  }

  // ── Payment Method ────────────────────────────────────────────────────────
  Widget buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPayTeal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_outlined,
                color: kPayMain, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank Transfer',
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                Text("Transfer to expert's account",
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration:
                const BoxDecoration(color: kPayMain, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  // ── Bank Account ──────────────────────────────────────────────────────────
  Widget buildBankAccount() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Please transfer to the account below:',
              style: GoogleFonts.outfit(
                  fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 14),
          buildBankRow('Bank Name', bankName),
          Divider(color: Colors.grey.shade100, height: 20),
          buildBankRowCopy('Account Number', accountNumber),
          Divider(color: Colors.grey.shade100, height: 20),
          buildBankRow('Account Holder', accountHolder),
        ],
      ),
    );
  }

  Widget buildBankRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: Colors.grey.shade500)),
        ),
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87)),
      ],
    );
  }

  Widget buildBankRowCopy(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: Colors.grey.shade500)),
        ),
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value.replaceAll(' ', '')));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Account number copied!',
                    style: GoogleFonts.outfit(fontSize: 13)),
                backgroundColor: kPayMain,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child:
              Icon(Icons.copy_outlined, size: 17, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  // ── Payment Details ───────────────────────────────────────────────────────
  Widget buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          buildDetailRow(
            'Consultation Fee',
            formatRupiah(consultationFee),
          ),
          Divider(color: Colors.grey.shade100, height: 20),
          buildDetailRow(
            'Platform Fee',
            formatRupiah(platformFee),
          ),
          Divider(color: Colors.grey.shade200, height: 20),
          Row(
            children: [
              Text(
                'Total Payment',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                formatRupiah(totalFee),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: Colors.grey.shade600)),
        ),
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ],
    );
  }

  // ── Instructions ──────────────────────────────────────────────────────────
  Widget buildInstructions() {
    final steps = [
      'Transfer the exact amount to the bank account above',
      'Upload your payment receipt below',
      'Wait for payment confirmation',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPayTeal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPayTeal.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 12 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                      color: kPayMain, shape: BoxShape.circle),
                  child: Center(
                    child: Text('${i + 1}',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(step,
                      style: GoogleFonts.outfit(
                          fontSize: 13, color: Colors.black87, height: 1.4)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Upload Box ────────────────────────────────────────────────────────────
  Widget buildUploadBox() {
    final consultationProvider = Provider.of<ConsultationProvider>(context);
    final currentCon = consultationProvider.currentConsultation;
    final isWaitingVerification = currentCon?.status == 'waiting_verification';
    final bool hasFile = uploadedFileName != null || isWaitingVerification;

    return GestureDetector(
      onTap: (isUploading || isWaitingVerification) ? null : pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: hasFile ? kPayTeal.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile ? kPayMain : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            if (isUploading)
              const CircularProgressIndicator(strokeWidth: 2, color: kPayMain)
            else if (isWaitingVerification) ...[
              const Icon(Icons.hourglass_empty_rounded,
                  color: kPayMain, size: 36),
              const SizedBox(height: 10),
              Text('Verification In Progress',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kPayMain)),
              const SizedBox(height: 4),
              Text('The expert is currently verifying your payment proof.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 11, color: Colors.grey.shade500)),
            ] else if (hasFile) ...[
              const Icon(Icons.check_circle_outline_rounded,
                  color: kPayMain, size: 36),
              const SizedBox(height: 10),
              Text(uploadedFileName!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kPayMain)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() {
                  uploadedFileName = null;
                  uploadedFile = null;
                }),
                child: Text('Tap to change file',
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: Colors.grey.shade500)),
              ),
            ] else ...[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kPayTeal.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.upload_rounded, color: kPayMain, size: 24),
              ),
              const SizedBox(height: 12),
              Text('Upload Payment Receipt',
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 4),
              Text('JPG, PNG, PDF up to 5MB',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: Colors.grey.shade500)),
            ],
          ],
        ),
      ),
    );
  }

  // ── Confirm Button ────────────────────────────────────────────────────────
  Widget buildConfirmButton() {
    final consultationProvider = Provider.of<ConsultationProvider>(context);
    final currentCon = consultationProvider.currentConsultation;
    final isWaitingVerification = currentCon?.status == 'waiting_verification';

    if (isWaitingVerification) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text('Awaiting Verification',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      );
    }

    return GestureDetector(
      onTap: (isConfirming || consultationProvider.isActionLoading) ? null : handleConfirm,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isConfirming
                ? [Colors.grey.shade300, Colors.grey.shade300]
                : [kPayBlue, kPayMain],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isConfirming
              ? []
              : [
                  BoxShadow(
                      color: kPayMain.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
        ),
        child: isConfirming
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text('Uploading...',
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              )
            : Text('Confirm Payment',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
      ),
    );
  }
}