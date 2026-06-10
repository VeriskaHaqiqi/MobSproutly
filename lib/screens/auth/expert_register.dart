import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../app_widgets.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class ExpertRegisterScreen extends StatefulWidget {
  const ExpertRegisterScreen({super.key});

  @override
  State<ExpertRegisterScreen> createState() => _ExpertRegisterScreenState();
}

class _ExpertRegisterScreenState extends State<ExpertRegisterScreen> {
  String _selectedGender = 'Male';
  bool _passVisible = false;
  bool _confirmVisible = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _almaMaterCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _bankHolderCtrl = TextEditingController();
  final _bankNumberCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Errors
  String? _nameErr;
  String? _emailErr;
  String? _phoneErr;
  String? _almaMaterErr;
  String? _expErr;
  String? _bankNameErr;
  String? _bankHolderErr;
  String? _bankNumberErr;
  String? _passErr;
  String? _confirmErr;
  String? _certErr;
  String? _diplomaErr;

  // Upload state — simpan list nama file
  List<String> _certificateFiles = [];
  String? _diplomaFile;

  bool isValidEmail(String email) =>
      RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);

  // Nomor telepon: minimal 9 digit, maksimal 15 digit, hanya angka (boleh awali +)
  bool isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 9 && digits.length <= 15;
  }

  // Nomor rekening: minimal 8 digit, hanya angka
  bool isValidBankNumber(String number) {
    final digits = number.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 8;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _almaMaterCtrl.dispose();
    _expCtrl.dispose();
    _bankNameCtrl.dispose();
    _bankHolderCtrl.dispose();
    _bankNumberCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Upload Certificates (multi-file) ─────────────────────────────────────────
  Future<void> _pickCertificates() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _certificateFiles = result.files.map((f) => f.name).toList();
          _certErr = null;
        });
      }
    } catch (e) {
      // File picker cancelled or error — do nothing
    }
  }

  // ── Upload Diploma (single image) ────────────────────────────────────────────
  Future<void> _pickDiploma() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _diplomaFile = result.files.first.name;
          _diplomaErr = null;
        });
      }
    } catch (e) {
      // File picker cancelled or error — do nothing
    }
  }

  // ── Validate & Submit ─────────────────────────────────────────────────────────
  void _handleSubmit() async {
    setState(() {
      _nameErr = _nameCtrl.text.trim().isEmpty ? 'Full name is required' : null;

      if (_emailCtrl.text.trim().isEmpty) {
        _emailErr = 'Email is required';
      } else if (!isValidEmail(_emailCtrl.text.trim())) {
        _emailErr = 'Please enter a valid email address';
      } else {
        _emailErr = null;
      }

      if (_phoneCtrl.text.trim().isEmpty) {
        _phoneErr = 'Phone number is required';
      } else if (!isValidPhone(_phoneCtrl.text.trim())) {
        _phoneErr = 'Enter a valid phone number (min. 9 digits)';
      } else {
        _phoneErr = null;
      }

      _almaMaterErr =
          _almaMaterCtrl.text.trim().isEmpty ? 'Alma mater is required' : null;

      if (_expCtrl.text.trim().isEmpty) {
        _expErr = 'Years of experience is required';
      } else if (int.tryParse(_expCtrl.text.trim()) == null ||
          int.parse(_expCtrl.text.trim()) < 1) {
        _expErr = 'Please enter a valid number (min. 1)';
      } else {
        _expErr = null;
      }

      _certErr = _certificateFiles.isEmpty
          ? 'Please upload at least one certificate'
          : null;

      _diplomaErr = _diplomaFile == null ? 'Please upload your diploma' : null;

      _bankNameErr =
          _bankNameCtrl.text.trim().isEmpty ? 'Bank name is required' : null;

      _bankHolderErr = _bankHolderCtrl.text.trim().isEmpty
          ? 'Account holder name is required'
          : null;

      if (_bankNumberCtrl.text.trim().isEmpty) {
        _bankNumberErr = 'Account number is required';
      } else if (!isValidBankNumber(_bankNumberCtrl.text.trim())) {
        _bankNumberErr = 'Enter a valid account number (min. 8 digits)';
      } else {
        _bankNumberErr = null;
      }

      if (_passCtrl.text.trim().isEmpty) {
        _passErr = 'Password is required';
      } else if (_passCtrl.text.trim().length < 8 ||
          !RegExp(r'\d').hasMatch(_passCtrl.text)) {
        _passErr = 'Min 8 characters, include at least 1 number';
      } else {
        _passErr = null;
      }

      if (_confirmCtrl.text.trim().isEmpty) {
        _confirmErr = 'Please confirm your password';
      } else if (_confirmCtrl.text != _passCtrl.text) {
        _confirmErr = 'Passwords do not match';
      } else {
        _confirmErr = null;
      }
    });

    if (_nameErr != null ||
        _emailErr != null ||
        _phoneErr != null ||
        _almaMaterErr != null ||
        _expErr != null ||
        _certErr != null ||
        _diplomaErr != null ||
        _bankNameErr != null ||
        _bankHolderErr != null ||
        _bankNumberErr != null ||
        _passErr != null ||
        _confirmErr != null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.registerExpert({
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'gender': _selectedGender,
      'password': _passCtrl.text.trim(),
      'password_confirmation': _confirmCtrl.text.trim(),
      'university': _almaMaterCtrl.text.trim(),
      'years_of_experience': int.parse(_expCtrl.text.trim()),
      'bank_name': _bankNameCtrl.text.trim(),
      'account_holder': _bankHolderCtrl.text.trim(),
      'account_number': _bankNumberCtrl.text.trim(),
    });

    if (!mounted) return;

    if (result['success']) {
      _showVerificationDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Expert registration failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showVerificationDialog() {
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
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF76EAD0).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    size: 36, color: Color(0xFF5DCFCF)),
              ),
              const SizedBox(height: 20),
              Text(
                'Application Submitted!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A2E35),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your expert account application is under review. Our team will verify your credentials and notify you via email within 3–5 business days.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.6),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0FF99).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_outlined,
                        size: 16, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _emailCtrl.text.trim(),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const LoginScreen(),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5DCFCF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text('Back to Log In',
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

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButtonWidget(),
              const SizedBox(height: 16),

              // ── Heading ──
              Center(
                child: Column(
                  children: [
                    Text('Create a New Account',
                        style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(
                      'Join our community of plant lovers and experts',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontSize: 13, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Tab Switcher ──
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EEEC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  _buildTab('Register as User', false),
                  _buildTab('Botanist Expert', true),
                ]),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'For providing consultations and publishing articles',
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: AppColors.textGrey),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Basic Info ──
              _sectionLabel('Full Name'),
              _buildField(
                  ctrl: _nameCtrl,
                  hint: 'Enter your full name',
                  errorText: _nameErr),
              const SizedBox(height: 14),

              _sectionLabel('Email Address'),
              _buildField(
                ctrl: _emailCtrl,
                hint: 'your.email@gmail.com',
                errorText: _emailErr,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              _sectionLabel('Phone Number'),
              _buildField(
                ctrl: _phoneCtrl,
                hint: '+62 812 3456 7890',
                errorText: _phoneErr,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\s\(\)]')),
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              const SizedBox(height: 14),

              // ── Gender ──
              _sectionLabel('Gender'),
              const SizedBox(height: 8),
              Row(
                children: ['Male', 'Female'].map((g) {
                  final isLast = g == 'Female';
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGender = g),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedGender == g
                                ? AppColors.teal.withOpacity(0.08)
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedGender == g
                                  ? AppColors.teal
                                  : AppColors.borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Text(g,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _selectedGender == g
                                    ? AppColors.tealDark
                                    : AppColors.textDark,
                              )),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // ── Professional Info ──
              _sectionHeader('Professional Information'),
              const SizedBox(height: 16),

              _sectionLabel('Alma Mater'),
              _buildField(
                  ctrl: _almaMaterCtrl,
                  hint: 'Universitas Indonesia',
                  errorText: _almaMaterErr),
              _helperText('Example: Universitas Indonesia'),
              const SizedBox(height: 14),

              _sectionLabel('Years of Experience'),
              _buildFieldWithSuffix(
                ctrl: _expCtrl,
                hint: '0',
                suffix: 'years',
                errorText: _expErr,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
              ),
              _helperText(
                  'Total professional experience in plant-related work'),
              const SizedBox(height: 28),

              // ── Document Uploads ──
              _sectionHeader('Document Uploads'),
              const SizedBox(height: 16),

              _sectionLabel('Certificates'),
              const SizedBox(height: 8),
              _buildUploadBox(
                icon: Icons.help_outline_rounded,
                title: _certificateFiles.isEmpty
                    ? 'Upload certificates'
                    : '${_certificateFiles.length} file(s) selected',
                subtitle: _certificateFiles.isEmpty
                    ? 'JPG/PNG/PDF  •  Multiple files allowed'
                    : _certificateFiles.join(', '),
                isUploaded: _certificateFiles.isNotEmpty,
                errorText: _certErr,
                onTap: _pickCertificates,
              ),
              const SizedBox(height: 14),

              _sectionLabel('Diploma'),
              const SizedBox(height: 8),
              _buildUploadBox(
                icon: Icons.image_outlined,
                title: _diplomaFile ?? 'Upload diploma image',
                subtitle: _diplomaFile ?? 'JPG/PNG only  •  1 file',
                isUploaded: _diplomaFile != null,
                errorText: _diplomaErr,
                onTap: _pickDiploma,
              ),
              const SizedBox(height: 28),

              // ── Bank Account ──
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('Bank Account',
                          style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      const SizedBox(width: 6),
                      const Icon(Icons.lock_outline,
                          size: 16, color: Colors.grey),
                    ]),
                    const SizedBox(height: 16),
                    _sectionLabel('Bank Name'),
                    const SizedBox(height: 6),
                    _buildField(
                        ctrl: _bankNameCtrl,
                        hint: 'Select or enter bank name',
                        errorText: _bankNameErr),
                    const SizedBox(height: 12),
                    _sectionLabel('Account Holder Name'),
                    const SizedBox(height: 6),
                    _buildField(
                        ctrl: _bankHolderCtrl,
                        hint: 'Name as per bank records',
                        errorText: _bankHolderErr),
                    const SizedBox(height: 12),
                    _sectionLabel('Account Number'),
                    const SizedBox(height: 6),
                    _buildField(
                      ctrl: _bankNumberCtrl,
                      hint: 'Enter account number',
                      errorText: _bankNumberErr,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(20),
                      ],
                    ),
                    _helperText('Used for payouts from consultations'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Security ──
              _sectionHeader('Security'),
              const SizedBox(height: 16),

              _sectionLabel('Password'),
              const SizedBox(height: 6),
              _buildPasswordField(
                ctrl: _passCtrl,
                hint: 'Create a strong password',
                isVisible: _passVisible,
                errorText: _passErr,
                onToggle: () => setState(() => _passVisible = !_passVisible),
              ),
              _helperText('Min 8 characters, include 1 number'),
              const SizedBox(height: 14),

              _sectionLabel('Confirm Password'),
              const SizedBox(height: 6),
              _buildPasswordField(
                ctrl: _confirmCtrl,
                hint: 'Re-enter your password',
                isVisible: _confirmVisible,
                errorText: _confirmErr,
                onToggle: () =>
                    setState(() => _confirmVisible = !_confirmVisible),
              ),
              const SizedBox(height: 28),

              // ── Submit Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF5DCFCF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text('Create Account',
                      style: GoogleFonts.outfit(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),

              // ── Log In Link ──
              Center(
                child: Column(
                  children: [
                    Text('Already have an account?',
                        style: GoogleFonts.outfit(
                            fontSize: 13.5, color: AppColors.textGrey)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const LoginScreen(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                        (route) => false,
                      ),
                      child: Text('Log In',
                          style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tealDark)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable Widgets ─────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) => Text(title,
      style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark));

  Widget _sectionLabel(String label) => Text(label,
      style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark));

  Widget _helperText(String text) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(text,
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textGrey)),
      );

  Widget _buildField({
    required TextEditingController ctrl,
    required String hint,
    String? errorText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  errorText != null ? Colors.redAccent : AppColors.borderColor,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(
                  fontSize: 14, color: AppColors.textGrey.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              isDense: true,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(errorText,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.redAccent)),
        ],
      ],
    );
  }

  Widget _buildFieldWithSuffix({
    required TextEditingController ctrl,
    required String hint,
    required String suffix,
    String? errorText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  errorText != null ? Colors.redAccent : AppColors.borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: GoogleFonts.outfit(
                      fontSize: 14, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.textGrey.withOpacity(0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text(suffix,
                    style: GoogleFonts.outfit(
                        fontSize: 13, color: AppColors.textGrey)),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(errorText,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.redAccent)),
        ],
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController ctrl,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  errorText != null ? Colors.redAccent : AppColors.borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  obscureText: !isVisible,
                  style: GoogleFonts.outfit(
                      fontSize: 14, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.textGrey.withOpacity(0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    isDense: true,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(
                    isVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(errorText,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.redAccent)),
        ],
      ],
    );
  }

  Widget _buildUploadBox({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isUploaded,
    required VoidCallback onTap,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            decoration: BoxDecoration(
              color: isUploaded
                  ? const Color(0xFF76EAD0).withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: errorText != null
                    ? Colors.redAccent
                    : isUploaded
                        ? AppColors.teal
                        : AppColors.borderColor,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  isUploaded ? Icons.check_circle_outline : icon,
                  size: 28,
                  color: isUploaded ? AppColors.teal : Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isUploaded ? AppColors.tealDark : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                      fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(errorText,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.redAccent)),
        ],
      ],
    );
  }

  Widget _buildTab(String label, bool isExpert) {
    final isActive = isExpert;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isExpert) Navigator.pop(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.teal.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.white : AppColors.textGrey,
              )),
        ),
      ),
    );
  }
}
