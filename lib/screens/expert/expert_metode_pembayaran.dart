import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'expert_home.dart' hide ExpertAccountPage;
import 'expert_artikel.dart';
import 'expert_consult.dart';
import 'expert_setting.dart';

const Color kPayMain = Color(0xFF5DCFCF);
const Color kPayTeal = Color(0xFF76EAD0);
const Color kPayBlue = Color(0xFF76D7EA);
const Color kPayLGreen = Color(0xFFD0FF99);
const Color kPayScaffold = Color(0xFFF0F4F3);

// ─── Global payment state removed ─────────────────────────────────────────────────────

class ExpertMetodePembayaranPage extends StatefulWidget {
  const ExpertMetodePembayaranPage({super.key});

  @override
  State<ExpertMetodePembayaranPage> createState() =>
      _ExpertMetodePembayaranPageState();
}

class _ExpertMetodePembayaranPageState
    extends State<ExpertMetodePembayaranPage> {
  int navIndex = 3;

  final TextEditingController _bankCtrl = TextEditingController();
  final TextEditingController _holderCtrl = TextEditingController();
  final TextEditingController _accountCtrl = TextEditingController();

  String? bankErr;
  String? holderErr;
  String? accountErr;
  bool isSaving = false;

  final List<String> _popularBanks = [
    'Bank Central Asia',
    'Bank Mandiri',
    'Bank Negara Indonesia',
    'Bank Rakyat Indonesia',
    'CIMB Niaga',
    'Danamon',
  ];

  @override
  void initState() {
    super.initState();

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final profile = user?.expertProfile;
    final hasBank = profile != null && profile.bankName != null && profile.bankName!.isNotEmpty;

    if (hasBank) {
      _bankCtrl.text = profile.bankName!;
      _holderCtrl.text = profile.accountHolder ?? '';
      _accountCtrl.text = profile.accountNumber ?? '';
    }

    _bankCtrl.addListener(() => setState(() {}));
    _holderCtrl.addListener(() => setState(() {}));
    _accountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bankCtrl.dispose();
    _holderCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  bool get _hasPreviewData =>
      _bankCtrl.text.isNotEmpty ||
      _holderCtrl.text.isNotEmpty ||
      _accountCtrl.text.isNotEmpty;

  void _handleSave() async {
    setState(() {
      bankErr = _bankCtrl.text.trim().isEmpty ? 'Bank name is required' : null;

      holderErr = _holderCtrl.text.trim().isEmpty
          ? 'Account holder name is required'
          : null;

      accountErr = _accountCtrl.text.trim().isEmpty
          ? 'Account number is required'
          : _accountCtrl.text.trim().length < 8
              ? 'Account number is too short'
              : null;
    });

    if (bankErr != null || holderErr != null || accountErr != null) return;

    setState(() => isSaving = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.updateBankAccount(
      bankName: _bankCtrl.text.trim(),
      accountHolder: _holderCtrl.text.trim(),
      accountNumber: _accountCtrl.text.trim(),
    );

    if (mounted) {
      setState(() => isSaving = false);
      if (success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Failed to update payment method.'),
          ),
        );
      }
    }
  }

  void _handleRemove() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Remove Payment Method',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure? Users won\'t be able to book sessions until you set a new payment method.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        await auth.updateBankAccount(
                          bankName: '',
                          accountHolder: '',
                          accountNumber: '',
                        );

                        if (!mounted) return;
                        Navigator.pop(ctx);

                        setState(() {
                          _bankCtrl.clear();
                          _holderCtrl.clear();
                          _accountCtrl.clear();

                          bankErr = null;
                          holderErr = null;
                          accountErr = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Remove',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
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
                    colors: [kPayTeal, kPayMain],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kPayMain.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Payment Method Saved!',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Users can now pay via bank transfer to your registered account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
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
                    color: kPayMain,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kPayMain.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    'Done',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  void onNavTapped(int index) {
    if (index == navIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertHomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertArticlePage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertConsultPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ExpertAccountPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPayScaffold,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 20),
                  _buildFormSection(),
                  const SizedBox(height: 20),
                  if (_hasPreviewData) ...[
                    _buildPreviewCard(),
                    const SizedBox(height: 20),
                  ],
                  _buildPaymentFlow(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                  const SizedBox(height: 12),
                  if (Provider.of<AuthProvider>(context).user?.expertProfile?.bankName?.isNotEmpty == true) _buildRemoveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
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
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Payment Method Settings',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPayBlue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: kPayBlue.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kPayMain.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: kPayMain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Information',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Users must complete payment before consultation starts. '
                  'Payment is made via direct bank transfer to your registered account.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Account Details',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Bank Name',
            controller: _bankCtrl,
            hint: 'Bank Central Asia',
            icon: Icons.account_balance_outlined,
            errorText: bankErr,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _popularBanks.map((b) {
              final isSel = _bankCtrl.text == b;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _bankCtrl.text = b;
                    bankErr = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSel ? kPayMain : kPayScaffold,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel ? kPayMain : Colors.grey.shade300,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    b,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSel ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Account Holder Name',
            controller: _holderCtrl,
            hint: Provider.of<AuthProvider>(context, listen: false).user?.name ?? 'Account Holder Name',
            icon: Icons.person_outline_rounded,
            errorText: holderErr,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Bank Account Number',
            controller: _accountCtrl,
            hint: '1234567890123',
            icon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: accountErr,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isOptional = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 6),
              Text(
                '(Optional)',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: kPayScaffold,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  errorText != null ? Colors.redAccent : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  icon,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.redAccent,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'This is how users will see your payment information',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kPayLGreen.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: kPayLGreen.withOpacity(0.6),
              width: 1.2,
            ),
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
                      color: kPayMain.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: kPayMain,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer Payment To',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          _holderCtrl.text.isNotEmpty
                              ? _holderCtrl.text
                              : 'Account Holder',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                color: Colors.black.withOpacity(0.08),
                height: 1,
              ),
              const SizedBox(height: 12),
              _previewRow(
                'Bank Name',
                _bankCtrl.text.isNotEmpty ? _bankCtrl.text : '—',
              ),
              const SizedBox(height: 6),
              _previewRow(
                'Account Number',
                _accountCtrl.text.isNotEmpty ? _accountCtrl.text : '—',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _previewRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentFlow() {
    final steps = [
      _FlowStep(
        1,
        'User Selects Expert',
        'User books a consultation with you',
        kPayTeal.withOpacity(0.3),
        kPayMain,
      ),
      _FlowStep(
        2,
        'User Pays via Bank Transfer',
        'Payment to your registered account',
        kPayLGreen.withOpacity(0.4),
        const Color(0xFF2E7D32),
      ),
      _FlowStep(
        3,
        'You Verify the Payment',
        'You check and confirm payment receipt in the app',
        const Color(0xFFFFFF9F).withOpacity(0.5),
        Colors.orange.shade700,
      ),
      _FlowStep(
        4,
        'Consultation Can Begin',
        'Session starts after your confirmation',
        kPayTeal.withOpacity(0.3),
        kPayMain,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Flow',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((e) {
            final step = e.value;
            final isLast = e.key == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: step.bg,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${step.number}',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: step.color,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 28,
                        color: Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

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
                : [kPayBlue, kPayMain],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSaving
              ? []
              : [
                  BoxShadow(
                    color: kPayMain.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
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
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Saving...',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Text(
                'Save Payment Method',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return GestureDetector(
      onTap: _handleRemove,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          'Remove Payment Method',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
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
                        color: isSel ? kPayMain : Colors.grey.shade400,
                        errorBuilder: (_, __, ___) => Icon(
                          items[index]['fallback'] as IconData,
                          color: isSel ? kPayMain : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                          color: isSel ? kPayMain : Colors.grey.shade400,
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

class _FlowStep {
  final int number;
  final String title;
  final String subtitle;
  final Color bg;
  final Color color;

  const _FlowStep(
    this.number,
    this.title,
    this.subtitle,
    this.bg,
    this.color,
  );
}
