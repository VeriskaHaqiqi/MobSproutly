import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'expert_home.dart';
import 'expert_artikel.dart';
import 'expert_consult.dart';
import 'expert_setting.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

const Color kBiayaMain = Color(0xFF5DCFCF);
const Color kBiayaTeal = Color(0xFF76EAD0);
const Color kBiayaBlue = Color(0xFF76D7EA);
const Color kBiayaLGreen = Color(0xFFD0FF99);
const Color kBiayaGreen = Color(0xFF99FF99);
const Color kBiayaYellow = Color(0xFFFFFF9F);
const Color kBiayaScaffold = Color(0xFFF0F4F3);

// ─── Global fee state removed ─────────────────────────────────────────────────

class ExpertSettingBiayaPage extends StatefulWidget {
  const ExpertSettingBiayaPage({super.key});

  @override
  State<ExpertSettingBiayaPage> createState() => _ExpertSettingBiayaPageState();
}

class _ExpertSettingBiayaPageState extends State<ExpertSettingBiayaPage> {
  int navIndex = 3;
  final TextEditingController _feeCtrl = TextEditingController();
  String selectedCurrency = 'Rp';
  bool isSaving = false;
  String? feeErr;

  // Quick-select presets (in Rp)
  final List<int> _presets = [25000, 50000, 75000, 100000, 150000, 200000];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    selectedCurrency = 'Rp';
    final fee = user?.expertProfile?.sessionFee ?? 50000.0;
    _feeCtrl.text = fee.toInt().toString();
  }

  @override
  void dispose() {
    _feeCtrl.dispose();
    super.dispose();
  }

  double get _parsedFee =>
      double.tryParse(_feeCtrl.text.replaceAll(',', '')) ?? 0;

  void _selectPreset(int val) {
    setState(() {
      _feeCtrl.text = val.toString();
      feeErr = null;
    });
  }

  void _handleSave() async {
    final fee = _parsedFee;
    setState(() {
      if (_feeCtrl.text.trim().isEmpty) {
        feeErr = 'Please enter your consultation fee';
      } else if (fee <= 0) {
        feeErr = 'Fee must be greater than 0';
      } else if (fee < 10000) {
        feeErr = 'Minimum fee is Rp 10,000';
      } else {
        feeErr = null;
      }
    });
    if (feeErr != null) return;

    setState(() => isSaving = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.updateExpertProfile(sessionFee: fee);
    
    if (mounted) {
      setState(() => isSaving = false);
      if (success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Failed to update fee')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kBiayaTeal, kBiayaMain],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: kBiayaMain.withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 14),
              Text('Fee Updated!',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text(
                'Your consultation fee has been set to $selectedCurrency ${_formatNumber(_parsedFee.toInt())}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.5),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: kBiayaMain,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: kBiayaMain.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Text('Done',
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

  String _formatNumber(int val) {
    final s = val.toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write('.');
      result.write(s[i]);
    }
    return result.toString();
  }

  void onNavTapped(int index) {
    if (index == navIndex) return;
    setState(() => navIndex = index);
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
    return Scaffold(
      backgroundColor: kBiayaScaffold,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentFeeCard(),
                  const SizedBox(height: 16),
                  _buildSetRateCard(),
                  const SizedBox(height: 16),
                  _buildPresetsCard(),
                  const SizedBox(height: 16),
                  _buildPolicyCard(),
                  const SizedBox(height: 28),
                  _buildSaveButton(),
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
          colors: [kBiayaBlue, kBiayaTeal],
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
              Text('Set Pricing',
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

  // ── Current Fee Card ──────────────────────────────────────────────────────
  Widget _buildCurrentFeeCard() {
    final user = Provider.of<AuthProvider>(context).user;
    final currentFee = user?.expertProfile?.sessionFee ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kBiayaTeal, kBiayaMain],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: kBiayaMain.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Fee',
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.white.withOpacity(0.85))),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatNumber(currentFee.toInt())}',
                  style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text('per consultation session',
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.white.withOpacity(0.75))),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.attach_money_rounded,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // ── Set Rate Card ─────────────────────────────────────────────────────────
  Widget _buildSetRateCard() {
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
          Text('Set Your Rate',
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          Text(
              'This is the fee users must pay before starting a consultation with you',
              style: GoogleFonts.outfit(
                  fontSize: 12, color: Colors.grey.shade500, height: 1.4)),
          const SizedBox(height: 14),

          // Currency + amount row
          Row(
            children: [
              // Currency selector
              Container(
                decoration: BoxDecoration(
                  color: kBiayaTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: kBiayaTeal.withOpacity(0.3), width: 1.2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCurrency,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: Colors.white,
                    icon: const SizedBox.shrink(),
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kBiayaMain),
                    items: ['Rp', 'USD', 'SGD']
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c,
                                style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: kBiayaMain))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedCurrency = val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Fee input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: feeErr != null
                          ? Colors.redAccent
                          : Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _feeCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                    onChanged: (_) => setState(() => feeErr = null),
                    decoration: InputDecoration(
                      hintText: '50,000',
                      hintStyle: GoogleFonts.outfit(
                          fontSize: 18,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (feeErr != null) ...[
            const SizedBox(height: 6),
            Text(feeErr!,
                style:
                    GoogleFonts.outfit(fontSize: 12, color: Colors.redAccent)),
          ],
        ],
      ),
    );
  }

  // ── Presets Card ──────────────────────────────────────────────────────────
  Widget _buildPresetsCard() {
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: kBiayaLGreen.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flash_on_rounded,
                    color: Color(0xFF2E7D32), size: 18),
              ),
              const SizedBox(width: 10),
              Text('Quick Select',
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tap a preset to set your fee quickly',
              style: GoogleFonts.outfit(
                  fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presets.map((val) {
              final isSelected = _feeCtrl.text == val.toString();
              return GestureDetector(
                onTap: () => _selectPreset(val),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? kBiayaMain : const Color(0xFFF0F4F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? kBiayaMain : Colors.grey.shade200,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: kBiayaMain.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2))
                          ]
                        : null,
                  ),
                  child: Text(
                    'Rp ${_formatNumber(val)}',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Policy Card ───────────────────────────────────────────────────────────
  Widget _buildPolicyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBiayaBlue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBiayaBlue.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kBiayaMain.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded,
                size: 16, color: kBiayaMain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pricing Policy',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(
                  'This price applies to one consultation session. '
                  'You can update your pricing anytime from your account settings. '
                  'Users will see this fee before booking a session with you.',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: Colors.black54, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Save Button ───────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: isSaving ? null : _handleSave,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSaving
                ? [Colors.grey.shade300, Colors.grey.shade300]
                : [kBiayaBlue, kBiayaMain],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSaving
              ? []
              : [
                  BoxShadow(
                      color: kBiayaMain.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
        ),
        child: isSaving
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
                  Text('Saving...',
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              )
            : Text('Save Pricing',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
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
                          color: isSel ? kBiayaMain : Colors.grey.shade400,
                          errorBuilder: (_, __, ___) => Icon(
                              items[index]['fallback'] as IconData,
                              color: isSel ? kBiayaMain : Colors.grey.shade400,
                              size: 24)),
                      const SizedBox(height: 4),
                      Text(items[index]['label'] as String,
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight:
                                  isSel ? FontWeight.w600 : FontWeight.w400,
                              color:
                                  isSel ? kBiayaMain : Colors.grey.shade400)),
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
