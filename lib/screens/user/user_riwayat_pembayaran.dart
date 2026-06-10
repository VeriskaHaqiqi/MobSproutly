import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:provider/provider.dart';
import '../../providers/consultation_provider.dart';
import 'user_home.dart';
import 'user_artikel.dart';
import 'user_consult.dart';
import 'user_setting.dart';

const Color kPayHistTeal = Color(0xFF76EAD0);
const Color kPayHistBlue = Color(0xFF76D7EA);
const Color kPayHistMain = Color(0xFF5DCFCF);
const Color kPayHistScaffold = Color(0xFFE8F5F3);

enum PaymentStatus { paid, cancelled, refunded }

class PaymentItem {
  final String id;
  final String expertName;
  final String specialty;
  final String avatarUrl;
  final String topic;
  final String consultType;
  final double amount;
  final double platformFee;
  final String date;
  final String invoiceNumber;
  final PaymentStatus status;
  final String? cancelReason;

  const PaymentItem({
    required this.id,
    required this.expertName,
    required this.specialty,
    required this.avatarUrl,
    required this.topic,
    required this.consultType,
    required this.amount,
    required this.platformFee,
    required this.date,
    required this.invoiceNumber,
    this.status = PaymentStatus.paid,
    this.cancelReason,
  });

  double get total => amount + platformFee;
}


String formatRupiah(double value) {
  final number = value.round().toString();
  final result = number.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );

  return 'Rp $result';
}

String statusLabel(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.paid:
      return 'PAID';
    case PaymentStatus.cancelled:
      return 'CANCELLED';
    case PaymentStatus.refunded:
      return 'REFUNDED';
  }
}

PdfColor statusPdfColor(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.paid:
      return PdfColor.fromHex('10B981');
    case PaymentStatus.cancelled:
      return PdfColors.redAccent;
    case PaymentStatus.refunded:
      return PdfColors.orange;
  }
}

Future<Uint8List> generateInvoicePdf(PaymentItem payment) async {
  final doc = pw.Document();

  final tealColor = PdfColor.fromHex('5DCFCF');
  final tealLight = PdfColor.fromHex('E8F5F3');
  final greyColor = PdfColor.fromHex('6B7280');
  final darkColor = PdfColor.fromHex('1F2937');
  final currentStatusColor = statusPdfColor(payment.status);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: tealColor,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SPROUTLY',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Plant Care & Expert Consultation',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        payment.invoiceNumber,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BILLED TO',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: greyColor,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Sarah Johnson',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                      pw.Text(
                        'sarah.johnson@gmail.com',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE DATE',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: greyColor,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        payment.date,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: darkColor,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'STATUS',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: greyColor,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: currentStatusColor,
                          borderRadius: pw.BorderRadius.circular(20),
                        ),
                        child: pw.Text(
                          statusLabel(payment.status),
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 28),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: tealLight,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: tealColor, width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'EXPERT INFORMATION',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: greyColor,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              payment.expertName,
                              style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: darkColor,
                              ),
                            ),
                            pw.Text(
                              payment.specialty,
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: tealColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Text(
                        payment.consultType,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'SERVICE DETAILS',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: greyColor,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: pw.BoxDecoration(color: tealColor),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      'Description',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Type',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Amount',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: tealLight, width: 1),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          payment.topic,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: darkColor,
                          ),
                        ),
                        pw.Text(
                          'Consultation with ${payment.expertName}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: greyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      payment.consultType.split(' ').first,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: greyColor,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      formatRupiah(payment.amount),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: darkColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: pw.BoxDecoration(
                color: tealLight,
                border: pw.Border(
                  bottom: pw.BorderSide(color: tealLight, width: 1),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      'Platform Service Fee',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: greyColor,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      '-',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: greyColor,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      formatRupiah(payment.platformFee),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: greyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: darkColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL PAYMENT',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    formatRupiah(payment.total),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),
            pw.Divider(color: tealLight),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Sproutly — Plant Care & Expert Consultation',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: greyColor,
                  ),
                ),
                pw.Text(
                  'support@sproutly.app',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: greyColor,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'This invoice was automatically generated. For questions, contact our support team.',
              style: pw.TextStyle(
                fontSize: 8,
                color: greyColor,
              ),
            ),
          ],
        );
      },
    ),
  );

  return doc.save();
}

class UserRiwayatPembayaranScreen extends StatefulWidget {
  const UserRiwayatPembayaranScreen({super.key});

  @override
  State<UserRiwayatPembayaranScreen> createState() =>
      UserRiwayatPembayaranScreenState();
}

class UserRiwayatPembayaranScreenState
    extends State<UserRiwayatPembayaranScreen> {
  int navIndex = 3;
  int displayCount = 5;
  final Set<String> loadingInvoices = {};
  PaymentStatus? filterStatus;

  void onNavTapped(int index) {
    if (index == navIndex) return;

    setState(() => navIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const HomeUserScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const UserArtikelScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const UserConsultScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const UserSettingScreen()),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConsultationProvider>(context, listen: false).fetchUserConsultations(refresh: true);
    });
  }

  List<PaymentItem> get _allPayments {
    final provider = Provider.of<ConsultationProvider>(context);
    final consults = provider.userConsultations.where((c) => c.payment != null).toList();

    return consults.map((c) {
      PaymentStatus st = PaymentStatus.paid;
      if (c.payment!.status == 'refunded') st = PaymentStatus.refunded;
      if (c.payment!.status == 'rejected' || c.status == 'rejected') st = PaymentStatus.cancelled;

      final expert = c.expert;
      final avatar = (expert != null && expert.photoUrl != null) ? expert.photoUrl! : 'https://images.unsplash.com/photo-1494790108755-2616b612b77c?w=150&q=80';
      
      String dateStr = 'Recently';
      if (c.payment!.createdAt != null) {
        final d = c.payment!.createdAt!;
        dateStr = '${d.day}/${d.month}/${d.year}';
      }

      return PaymentItem(
        id: c.payment!.id.toString(),
        expertName: expert?.name ?? 'Expert',
        specialty: (expert?.specializations != null && expert!.specializations!.isNotEmpty) ? expert.specializations!.first.name : 'Expert',
        avatarUrl: avatar,
        topic: c.topic ?? 'Consultation',
        consultType: 'Chat Consultation',
        amount: c.payment!.amount.toDouble(),
        platformFee: c.payment!.platformFee.toDouble(),
        date: dateStr,
        invoiceNumber: 'INV-${c.payment!.id}',
        status: st,
        cancelReason: c.payment!.rejectionNote,
      );
    }).toList();
  }

  List<PaymentItem> get filteredPayments {
    if (filterStatus == null) return _allPayments;
    return _allPayments.where((p) => p.status == filterStatus).toList();
  }

  Future<void> downloadInvoice(PaymentItem payment) async {
    setState(() => loadingInvoices.add(payment.id));

    try {
      final pdfData = await generateInvoicePdf(payment);

      await Printing.sharePdf(
        bytes: pdfData,
        filename: '${payment.invoiceNumber}.pdf',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to generate invoice. Please try again.',
              style: GoogleFonts.outfit(fontSize: 13),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loadingInvoices.remove(payment.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayed = filteredPayments.take(displayCount).toList();
    final hasMore = displayCount < filteredPayments.length;

    return Scaffold(
      backgroundColor: kPayHistScaffold,
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        buildFilterChip(
                          label: 'All',
                          count: _allPayments.length,
                          icon: Icons.list_rounded,
                          color: kPayHistMain,
                          isActive: filterStatus == null,
                          onTap: () => setState(() {
                            filterStatus = null;
                            displayCount = 5;
                          }),
                        ),
                        const SizedBox(width: 8),
                        buildFilterChip(
                          label: 'Paid',
                          count: _allPayments
                              .where((p) => p.status == PaymentStatus.paid)
                              .length,
                          icon: Icons.check_circle_outline_rounded,
                          color: const Color(0xFF10B981),
                          isActive: filterStatus == PaymentStatus.paid,
                          onTap: () => setState(() {
                            filterStatus = PaymentStatus.paid;
                            displayCount = 5;
                          }),
                        ),
                        const SizedBox(width: 8),
                        buildFilterChip(
                          label: 'Cancelled',
                          count: _allPayments
                              .where((p) => p.status == PaymentStatus.cancelled)
                              .length,
                          icon: Icons.cancel_outlined,
                          color: Colors.redAccent,
                          isActive: filterStatus == PaymentStatus.cancelled,
                          onTap: () => setState(() {
                            filterStatus = PaymentStatus.cancelled;
                            displayCount = 5;
                          }),
                        ),
                        const SizedBox(width: 8),
                        buildFilterChip(
                          label: 'Refunded',
                          count: _allPayments
                              .where((p) => p.status == PaymentStatus.refunded)
                              .length,
                          icon: Icons.replay_rounded,
                          color: Colors.orange,
                          isActive: filterStatus == PaymentStatus.refunded,
                          onTap: () => setState(() {
                            filterStatus = PaymentStatus.refunded;
                            displayCount = 5;
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredPayments.isEmpty)
                    buildEmpty()
                  else ...[
                    ...displayed.map((p) => buildPaymentCard(p)),
                    if (hasMore) buildLoadMoreButton(),
                  ],
                ],
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
          colors: [kPayHistBlue, kPayHistTeal],
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
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Payment History',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilterChip({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : color,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              '$count $label',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmpty() {
    final label = filterStatus == PaymentStatus.paid
        ? 'No paid payments'
        : filterStatus == PaymentStatus.cancelled
            ? 'No cancelled payments'
            : 'No refunded payments';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 52,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentCard(PaymentItem payment) {
    final isLoading = loadingInvoices.contains(payment.id);
    final isPaid = payment.status == PaymentStatus.paid;
    final isCancelled = payment.status == PaymentStatus.cancelled;

    final Color statusColor = isPaid
        ? const Color(0xFF10B981)
        : isCancelled
            ? Colors.redAccent
            : Colors.orange;

    final String currentStatusLabel = isPaid
        ? 'Paid'
        : isCancelled
            ? 'Cancelled'
            : 'Refunded';

    final IconData statusIcon = isPaid
        ? Icons.check_circle_outline_rounded
        : isCancelled
            ? Icons.cancel_outlined
            : Icons.replay_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        border: !isPaid
            ? Border(
                left: BorderSide(
                  color: statusColor.withOpacity(0.6),
                  width: 4,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: isPaid ? 1.0 : 0.55,
                  child: ClipOval(
                    child: Image.network(
                      payment.avatarUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, p) {
                        if (p == null) return child;

                        return Container(
                          width: 50,
                          height: 50,
                          color: kPayHistTeal.withOpacity(0.2),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kPayHistMain,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (ctx, e, s) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: kPayHistTeal.withOpacity(0.2),
                          child: Center(
                            child: Text(
                              payment.expertName[0],
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: kPayHistMain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.expertName,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isPaid ? Colors.black87 : Colors.black54,
                        ),
                      ),
                      Text(
                        payment.specialty,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isPaid ? kPayHistMain : Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        payment.topic,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isPaid ? Colors.black87 : Colors.black45,
                        ),
                      ),
                      Text(
                        payment.consultType,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPaid)
                  GestureDetector(
                    onTap: isLoading ? null : () => downloadInvoice(payment),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kPayHistTeal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kPayHistMain,
                              ),
                            )
                          : const Icon(
                              Icons.download_outlined,
                              color: kPayHistMain,
                              size: 20,
                            ),
                    ),
                  )
                else
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 18,
                    ),
                  ),
              ],
            ),
            if (!isPaid && payment.cancelReason != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: statusColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payment.cancelReason!,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: statusColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Divider(
              color: Colors.grey.shade100,
              height: 1,
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatRupiah(payment.total),
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isPaid ? Colors.black87 : Colors.black38,
                          decoration:
                              !isPaid ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(
                        payment.date,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        currentStatusLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: GestureDetector(
        onTap: () => setState(() => displayCount = filteredPayments.length),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: kPayHistMain,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: kPayHistMain.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            'Load More Payments',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBottomNavBar() {
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
                        color: isSel ? kPayHistMain : Colors.grey.shade400,
                        errorBuilder: (ctx, e, s) {
                          return Icon(
                            items[index]['fallback'] as IconData,
                            color: isSel ? kPayHistMain : Colors.grey.shade400,
                            size: 24,
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                          color: isSel ? kPayHistMain : Colors.grey.shade400,
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
