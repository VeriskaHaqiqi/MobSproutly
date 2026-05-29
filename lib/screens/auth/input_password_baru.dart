import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';
import '../../app_widgets.dart';
import 'login_screen.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _passVisible = false;
  bool _confirmVisible = false;
  bool _isSaving = false;

  String? _confirmErr;

  // ── Live requirement checks ───────────────────────────────────────────────
  bool get _hasMinLength => _passCtrl.text.length >= 8;
  bool get _hasUpperAndLower =>
      _passCtrl.text.contains(RegExp(r'[A-Z]')) &&
      _passCtrl.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _passCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _allMet => _hasMinLength && _hasUpperAndLower && _hasNumber;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(() => setState(() {}));
    _confirmCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    setState(() {
      if (_confirmCtrl.text.isEmpty) {
        _confirmErr = 'Please confirm your password';
      } else if (_confirmCtrl.text != _passCtrl.text) {
        _confirmErr = 'Passwords do not match';
      } else {
        _confirmErr = null;
      }
    });

    if (!_allMet || _confirmErr != null) return;

    setState(() => _isSaving = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
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
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF76EAD0), Color(0xFF5DCFCF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5DCFCF).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_open_rounded,
                    color: Colors.white, size: 34),
              ),
              const SizedBox(height: 18),

              Text('Password Updated!',
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 10),

              Text(
                'Your new password has been saved successfully. You can now log in with your new password.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.6),
              ),
              const SizedBox(height: 22),

              // Back to Login button
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
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
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF76D7EA), Color(0xFF5DCFCF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5DCFCF).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text('Back to Login',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Text('Create New Password',
                      style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 8),
                  Text(
                    'Your new password must be different from your previous password.',
                    style: GoogleFonts.outfit(
                        fontSize: 13.5, color: AppColors.textGrey, height: 1.5),
                  ),
                  const SizedBox(height: 28),

                  // Password fields card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF6F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // New Password
                        _buildPasswordField(
                          label: 'New Password',
                          hint: 'Enter new password',
                          controller: _passCtrl,
                          isVisible: _passVisible,
                          onToggle: () =>
                              setState(() => _passVisible = !_passVisible),
                        ),
                        const SizedBox(height: 16),

                        // Confirm New Password
                        _buildPasswordField(
                          label: 'Confirm New Password',
                          hint: 'Re-enter new password',
                          controller: _confirmCtrl,
                          isVisible: _confirmVisible,
                          onToggle: () => setState(
                              () => _confirmVisible = !_confirmVisible),
                          errorText: _confirmErr,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Password Requirements
                  Text('Password Requirements',
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 12),
                  _buildRequirement(
                    label: 'At least 8 characters',
                    met: _hasMinLength,
                    active: _passCtrl.text.isNotEmpty,
                  ),
                  const SizedBox(height: 8),
                  _buildRequirement(
                    label: 'Include uppercase and lowercase letters',
                    met: _hasUpperAndLower,
                    active: _passCtrl.text.isNotEmpty,
                  ),
                  const SizedBox(height: 8),
                  _buildRequirement(
                    label: 'Include at least one number',
                    met: _hasNumber,
                    active: _passCtrl.text.isNotEmpty,
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _allMet
                            ? const Color(0xFF5DCFCF)
                            : const Color(0xFFB2E8E8),
                        disabledBackgroundColor: const Color(0xFFB2E8E8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: _allMet ? 0 : 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isSaving
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
                          : Text('Save New Password',
                              style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF76D7EA), Color(0xFF76EAD0)],
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
              Text('Set New Password',
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

  // ── Password Field ────────────────────────────────────────────────────────
  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.redAccent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
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
                        horizontal: 16, vertical: 14),
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
          const SizedBox(height: 5),
          Text(errorText,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.redAccent)),
        ],
      ],
    );
  }

  // ── Requirement Row ───────────────────────────────────────────────────────
  Widget _buildRequirement({
    required String label,
    required bool met,
    required bool active,
  }) {
    final Color iconColor = !active
        ? Colors.grey.shade400
        : met
            ? const Color(0xFF5DCFCF)
            : Colors.redAccent;

    final IconData icon = met
        ? Icons.check_circle_outline_rounded
        : Icons.radio_button_unchecked_rounded;

    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            icon,
            key: ValueKey('$met-$active'),
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 13,
                color: !active
                    ? Colors.grey.shade500
                    : met
                        ? Colors.black87
                        : Colors.grey.shade500)),
      ],
    );
  }
}
