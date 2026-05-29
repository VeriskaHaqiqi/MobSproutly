import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'expert_home.dart';
import 'expert_artikel.dart';
import 'expert_consult.dart';
import 'expert_setting.dart';

const Color kRiwMain = Color(0xFF5DCFCF);
const Color kRiwTeal = Color(0xFF76EAD0);
const Color kRiwBlue = Color(0xFF76D7EA);
const Color kRiwLGreen = Color(0xFFD0FF99);
const Color kRiwGreen = Color(0xFF99FF99);
const Color kRiwYellow = Color(0xFFFFFF9F);
const Color kRiwScaffold = Color(0xFFF0F4F3);

// ─── Models ───────────────────────────────────────────────────────────────────
enum IncomeStatus { paid, pending }

class IncomeItem {
  final String id;
  final String clientName;
  final String clientAvatar;
  final String sessionType;
  final String date;
  final String time;
  final int amountRp;
  final IncomeStatus status;
  final String invoiceNumber;

  const IncomeItem({
    required this.id,
    required this.clientName,
    required this.clientAvatar,
    required this.sessionType,
    required this.date,
    required this.time,
    required this.amountRp,
    required this.status,
    required this.invoiceNumber,
  });
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────
final List<IncomeItem> _allIncome = [
  IncomeItem(
      id: '1',
      clientName: 'Sarah Chen',
      clientAvatar:
          'https://images.unsplash.com/photo-1494790108755-2616b612b77c?w=150&q=80&auto=format&fit=crop',
      sessionType: 'Chat Consultation',
      date: 'Dec 15, 2024',
      time: '2:30 PM',
      amountRp: 45000,
      status: IncomeStatus.paid,
      invoiceNumber: 'INV-2847'),
  IncomeItem(
      id: '2',
      clientName: 'Michael Rodriguez',
      clientAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&q=80&auto=format&fit=crop',
      sessionType: 'Chat Consultation',
      date: 'Dec 14, 2024',
      time: '10:15 AM',
      amountRp: 85000,
      status: IncomeStatus.paid,
      invoiceNumber: 'INV-2846'),
  IncomeItem(
      id: '3',
      clientName: 'Emma Johnson',
      clientAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&q=80&auto=format&fit=crop',
      sessionType: 'Plant Care Plan',
      date: 'Dec 13, 2024',
      time: '4:45 PM',
      amountRp: 65000,
      status: IncomeStatus.pending,
      invoiceNumber: 'INV-2845'),
  IncomeItem(
      id: '4',
      clientName: 'David Park',
      clientAvatar:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&q=80&auto=format&fit=crop',
      sessionType: 'Chat Consultation',
      date: 'Dec 12, 2024',
      time: '11:20 AM',
      amountRp: 45000,
      status: IncomeStatus.paid,
      invoiceNumber: 'INV-2844'),
  IncomeItem(
      id: '5',
      clientName: 'Lisa Thompson',
      clientAvatar:
          'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=150&q=80&auto=format&fit=crop',
      sessionType: 'Chat Consultation',
      date: 'Dec 11, 2024',
      time: '3:00 PM',
      amountRp: 85000,
      status: IncomeStatus.paid,
      invoiceNumber: 'INV-2843'),
  IncomeItem(
      id: '6',
      clientName: 'James Anderson',
      clientAvatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&q=80&auto=format&fit=crop',
      sessionType: 'Chat Consultation',
      date: 'Nov 28, 2024',
      time: '9:00 AM',
      amountRp: 50000,
      status: IncomeStatus.paid,
      invoiceNumber: 'INV-2842'),
  IncomeItem(
      id: '7',
      clientName: 'Adela Ulin',
      clientAvatar:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&q=80&auto=format&fit=crop',
      sessionType: 'Chat Consultation',
      date: 'Nov 20, 2024',
      time: '2:00 PM',
      amountRp: 35000,
      status: IncomeStatus.paid,
      invoiceNumber: 'INV-2841'),
];

// Weekly bar chart data
final List<_WeekBar> _weekBars = [
  _WeekBar('Mon', 125000),
  _WeekBar('Tue', 180000),
  _WeekBar('Wed', 225000),
  _WeekBar('Thu', 285000),
  _WeekBar('Fri', 200000),
];

class _WeekBar {
  final String day;
  final int amount;
  _WeekBar(this.day, this.amount);
}

// ─── PDF Generator ────────────────────────────────────────────────────────────
Future<Uint8List> _generateInvoice(IncomeItem item) async {
  final doc = pw.Document();
  final teal = PdfColor.fromHex('#5DCFCF');
  final grey = PdfColors.grey700;

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: teal,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SPROUTLY',
                        style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text('Plant Care & Expert Consultation',
                        style:
                            pw.TextStyle(fontSize: 11, color: PdfColors.white)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('INVOICE',
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                    pw.SizedBox(height: 4),
                    pw.Text(item.invoiceNumber,
                        style:
                            pw.TextStyle(fontSize: 12, color: PdfColors.white)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 28),

          // From / To
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('FROM',
                      style: pw.TextStyle(fontSize: 10, color: grey)),
                  pw.SizedBox(height: 4),
                  pw.Text('Dr. Isyana Chen',
                      style: pw.TextStyle(
                          fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Orchid Specialist',
                      style: pw.TextStyle(fontSize: 11, color: grey)),
                  pw.Text('Sproutly Expert',
                      style: pw.TextStyle(fontSize: 11, color: grey)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('TO', style: pw.TextStyle(fontSize: 10, color: grey)),
                  pw.SizedBox(height: 4),
                  pw.Text(item.clientName,
                      style: pw.TextStyle(
                          fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Client',
                      style: pw.TextStyle(fontSize: 11, color: grey)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 28),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 20),

          // Session details table
          pw.Text('Session Details',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#E8F5F3'),
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(8),
                      topRight: pw.Radius.circular(8),
                    ),
                  ),
                  children: [
                    _cell('Description', isHeader: true),
                    _cell('Date', isHeader: true),
                    _cell('Amount', isHeader: true),
                  ],
                ),
                pw.TableRow(children: [
                  _cell(item.sessionType),
                  _cell('${item.date}\n${item.time}'),
                  _cell('Rp ${_fmt(item.amountRp)}'),
                ]),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Total
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 200,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#E8F5F3'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Rp ${_fmt(item.amountRp)}',
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: teal)),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // Status badge
          pw.Row(
            children: [
              pw.Text('Payment Status: ',
                  style: pw.TextStyle(fontSize: 12, color: grey)),
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: item.status == IncomeStatus.paid
                      ? PdfColor.fromHex('#D0FF99')
                      : PdfColor.fromHex('#FFF3CD'),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  item.status == IncomeStatus.paid ? 'PAID' : 'PENDING',
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: item.status == IncomeStatus.paid
                          ? PdfColor.fromHex('#2E7D32')
                          : PdfColor.fromHex('#E65100')),
                ),
              ),
            ],
          ),
          pw.Spacer(),

          // Footer
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'Thank you for using Sproutly! For questions, contact support@sproutly.com',
              style: pw.TextStyle(fontSize: 10, color: grey),
            ),
          ),
        ],
      ),
    ),
  );
  return doc.save();
}

pw.Widget _cell(String text, {bool isHeader = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: pw.Text(text,
        style: pw.TextStyle(
            fontSize: 12,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal)),
  );
}

String _fmt(int val) {
  final s = val.toString();
  final result = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) result.write('.');
    result.write(s[i]);
  }
  return result.toString();
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ExpertRiwayatPemasukanPage extends StatefulWidget {
  const ExpertRiwayatPemasukanPage({super.key});

  @override
  State<ExpertRiwayatPemasukanPage> createState() =>
      _ExpertRiwayatPemasukanPageState();
}

class _ExpertRiwayatPemasukanPageState
    extends State<ExpertRiwayatPemasukanPage> {
  int navIndex = 3;

  // Filters
  String _period = 'All Time'; // All Time | This Month
  String _status = 'All'; // All | Paid | Pending
  String _sort = 'Newest'; // Newest | Oldest

  final List<String> _periods = ['All Time', 'This Month'];
  final List<String> _statuses = ['All', 'Paid', 'Pending'];

  List<IncomeItem> get _filtered {
    var list = List<IncomeItem>.from(_allIncome);

    // Period filter
    if (_period == 'This Month') {
      list = list.where((i) => i.date.startsWith('Dec')).toList();
    }

    // Status filter
    if (_status == 'Paid') {
      list = list.where((i) => i.status == IncomeStatus.paid).toList();
    } else if (_status == 'Pending') {
      list = list.where((i) => i.status == IncomeStatus.pending).toList();
    }

    // Sort
    if (_sort == 'Oldest') list = list.reversed.toList();

    return list;
  }

  int get _totalIncome => _filtered
      .where((i) => i.status == IncomeStatus.paid)
      .fold(0, (sum, i) => sum + i.amountRp);

  int get _thisMonthIncome => _allIncome
      .where((i) => i.date.startsWith('Dec') && i.status == IncomeStatus.paid)
      .fold(0, (sum, i) => sum + i.amountRp);

  int get _totalSessions => _filtered.length;

  Future<void> _downloadInvoice(IncomeItem item) async {
    try {
      final bytes = await _generateInvoice(item);
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${item.invoiceNumber}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to generate invoice',
            style: GoogleFonts.outfit(fontSize: 13)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  void _showDetail(IncomeItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Client row
            Row(
              children: [
                ClipOval(
                  child: Image.network(item.clientAvatar,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                            width: 50,
                            height: 50,
                            color: kRiwTeal.withOpacity(0.2),
                            child: Center(
                              child: Text(item.clientName[0],
                                  style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: kRiwMain)),
                            ),
                          )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.clientName,
                          style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      Text(item.sessionType,
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                _statusBadge(item.status),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 12),

            // Details
            _detailRow('Date', item.date),
            _detailRow('Time', item.time),
            _detailRow('Invoice', item.invoiceNumber),
            _detailRow('Amount', 'Rp ${_fmt(item.amountRp)}', highlight: true),
            const SizedBox(height: 20),

            // Download Invoice
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _downloadInvoice(item);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kRiwBlue, kRiwMain],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: kRiwMain.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('Download Invoice (PDF)',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                    color: highlight ? kRiwMain : Colors.black87)),
          ),
        ],
      ),
    );
  }

  void onNavTapped(int index) {
    if (index == navIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ExpertHomePage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ExpertArticlePage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ExpertConsultPage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ExpertAccountPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final maxBar =
        _weekBars.map((b) => b.amount).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: kRiwScaffold,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 16),
                  _buildFilters(),
                  const SizedBox(height: 14),
                  // Income list
                  if (list.isEmpty)
                    _buildEmpty()
                  else
                    ...list.map((item) => _buildIncomeCard(item)),
                  const SizedBox(height: 20),
                  _buildWeeklyChart(maxBar),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kRiwBlue, kRiwTeal],
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
              Text('Income History',
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

  // ── Summary Cards ─────────────────────────────────────────────────────────
  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kRiwBlue, kRiwTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: kRiwMain.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Total Income',
                  'Rp ${_fmt(_totalIncome)}',
                ),
              ),
              Container(
                  width: 1, height: 50, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _summaryItem(
                  'This Month',
                  'Rp ${_fmt(_thisMonthIncome)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Completed Consultations',
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.white.withOpacity(0.85))),
                const SizedBox(height: 2),
                Text(
                    '${_allIncome.where((i) => i.status == IncomeStatus.paid).length} sessions',
                    style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 12, color: Colors.white.withOpacity(0.85))),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ],
      ),
    );
  }

  // ── Filters ───────────────────────────────────────────────────────────────
  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Period chips
          ..._periods.map((p) => _filterChip(
                p,
                _period == p,
                () => setState(() => _period = p),
                color: kRiwMain,
              )),
          const SizedBox(width: 4),
          Container(width: 1, height: 24, color: Colors.grey.shade300),
          const SizedBox(width: 4),
          // Status chips
          ..._statuses.map((s) => _filterChip(
                s,
                _status == s,
                () => setState(() => _status = s),
                color: kRiwMain,
              )),
          const SizedBox(width: 4),
          Container(width: 1, height: 24, color: Colors.grey.shade300),
          const SizedBox(width: 4),
          // Sort chip
          GestureDetector(
            onTap: () =>
                setState(() => _sort = _sort == 'Newest' ? 'Oldest' : 'Newest'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      _sort == 'Newest'
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 13,
                      color: Colors.black54),
                  const SizedBox(width: 5),
                  Text(_sort,
                      style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? color : Colors.grey.shade300, width: 1.2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black54)),
      ),
    );
  }

  // ── Income Card ───────────────────────────────────────────────────────────
  Widget _buildIncomeCard(IncomeItem item) {
    return GestureDetector(
      onTap: () => _showDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.network(item.clientAvatar,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, p) {
                        if (p == null) return child;
                        return Container(
                          width: 44,
                          height: 44,
                          color: kRiwTeal.withOpacity(0.2),
                          child: const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: kRiwMain)),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: kRiwTeal.withOpacity(0.2),
                                shape: BoxShape.circle),
                            child: Center(
                                child: Text(item.clientName[0],
                                    style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: kRiwMain))),
                          )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.clientName,
                          style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                      Text(item.sessionType,
                          style: GoogleFonts.outfit(
                              fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Rp ${_fmt(item.amountRp)}',
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    const SizedBox(height: 3),
                    _statusBadge(item.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text('${item.date} · ${item.time}',
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: Colors.grey.shade400)),
                const Spacer(),
                Text(item.invoiceNumber,
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(IncomeStatus status) {
    final isPaid = status == IncomeStatus.paid;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: isPaid ? const Color(0xFF4CAF50) : Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(isPaid ? 'Paid' : 'Pending',
            style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isPaid ? const Color(0xFF2E7D32) : Colors.orange.shade700)),
      ],
    );
  }

  // ── Empty ─────────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded,
                size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No income records found',
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Weekly Earnings Chart ─────────────────────────────────────────────────
  Widget _buildWeeklyChart(int maxBar) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Earnings Trend',
              style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const SizedBox(height: 18),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekBars.map((bar) {
                final ratio = bar.amount / maxBar;
                final barColors = [
                  kRiwTeal,
                  kRiwBlue,
                  kRiwLGreen,
                  kRiwLGreen.withOpacity(0.7),
                  kRiwYellow,
                ];
                final colorIndex = _weekBars.indexOf(bar) % barColors.length;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Rp ${_fmt(bar.amount ~/ 1000)}K',
                        style: GoogleFonts.outfit(
                            fontSize: 9,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 40,
                      height: 110 * ratio,
                      decoration: BoxDecoration(
                        color: barColors[colorIndex],
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                        boxShadow: [
                          BoxShadow(
                              color: barColors[colorIndex].withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(bar.day,
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: Colors.grey.shade500)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
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
                      Image.asset(items[index]['icon'] as String,
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          color: isSel ? kRiwMain : Colors.grey.shade400,
                          errorBuilder: (_, __, ___) => Icon(
                              items[index]['fallback'] as IconData,
                              color: isSel ? kRiwMain : Colors.grey.shade400,
                              size: 24)),
                      const SizedBox(height: 4),
                      Text(items[index]['label'] as String,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight:
                                  isSel ? FontWeight.w600 : FontWeight.w400,
                              color: isSel ? kRiwMain : Colors.grey.shade400)),
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
