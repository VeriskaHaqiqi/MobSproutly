import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';
import '../../app_widgets.dart';
import '../../services/auth_service.dart';
import 'input_password_baru.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  String? _emailErr;
  bool _isSending = false;

  // Cooldown state — setelah kirim, user harus tunggu 24 jam
  bool _linkSent = false;
  DateTime? _sentAt;

  bool get _inCooldown {
    if (_sentAt == null) return false;
    return DateTime.now().difference(_sentAt!) < const Duration(hours: 24);
  }

  String get _cooldownRemaining {
    if (_sentAt == null) return '';
    final elapsed = DateTime.now().difference(_sentAt!);
    final remaining = const Duration(hours: 24) - elapsed;
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    return '${h}h ${m}m';
  }

  bool isValidEmail(String email) =>
      RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _handleSend() async {
    final email = _emailCtrl.text.trim();

    setState(() {
      if (email.isEmpty) {
        _emailErr = 'Email is required';
      } else if (!isValidEmail(email)) {
        _emailErr = 'Please enter a valid email address';
      } else {
        _emailErr = null;
      }
    });

    if (_emailErr != null) return;

    setState(() => _isSending = true);

    final result = await _authService.forgotPassword(email);

    if (!mounted) return;
    setState(() => _isSending = false);

    if (result['success']) {
      setState(() {
        _linkSent = true;
        _sentAt = DateTime.now();
      });
      _showSuccessDialog(email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Request failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showSuccessDialog(String email) {
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
              // Close
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child:
                      Icon(Icons.close, color: Colors.grey.shade400, size: 20),
                ),
              ),
              const SizedBox(height: 4),

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
                child: const Icon(Icons.mark_email_read_outlined,
                    color: Colors.white, size: 34),
              ),
              const SizedBox(height: 18),

              Text('Reset Link Sent!',
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 10),

              Text(
                'We\'ve sent a password reset link to',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5DCFCF)),
              ),
              const SizedBox(height: 16),

              // Info box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 15, color: Color(0xFF5DCFCF)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'The link will expire in 1 hour. Check your spam folder if you don\'t see it.',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 15, color: Color(0xFF5DCFCF)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You can request a new link after 24 hours if you don\'t receive one.',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Set new password
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SetNewPasswordScreen(email: email),
                    ),
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
                  child: Text('Set New Password',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              const BackButtonWidget(),
              const SizedBox(height: 36),

              // Lock icon
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD0FF99), Color(0xFF76EAD0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF76EAD0).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 28),

              // Heading
              Center(
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Enter your email to receive a reset link',
                  style: GoogleFonts.outfit(
                      fontSize: 13.5, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 36),

              // Email field
              AppTextField(
                label: 'Email',
                hint: 'your@gmail.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailErr,
              ),
              const SizedBox(height: 8),

              // Cooldown notice
              if (_linkSent && _inCooldown)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.orange.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 15, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'A reset link was already sent. You can request a new one in $_cooldownRemaining.',
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isSending || (_linkSent && _inCooldown))
                      ? null
                      : _handleSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5DCFCF),
                    disabledBackgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSending
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
                            Text('Sending...',
                                style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ],
                        )
                      : Text(
                          _linkSent && _inCooldown
                              ? 'Link Sent (Cooldown Active)'
                              : _linkSent
                                  ? 'Resend Reset Link'
                                  : 'Send Reset Link',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: (_linkSent && _inCooldown)
                                ? Colors.grey.shade400
                                : Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Back to login link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      text: 'Remember your password? ',
                      style: GoogleFonts.outfit(
                          fontSize: 13.5, color: AppColors.textGrey),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.tealDark),
                        ),
                      ],
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
}
