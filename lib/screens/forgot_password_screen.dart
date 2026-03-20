import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../app_widgets.dart';
import 'hello_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  String? _emailErr;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _handleSend() {
    setState(() {
      _emailErr =
          _emailCtrl.text.trim().isEmpty ? 'Email wajib diisi' : null;
    });
    if (_emailErr != null) return;

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const HelloScreen(),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButtonWidget(),
              const SizedBox(height: 8),

              // Logo forgot — ditaruh di dalam lingkaran gradient teal
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFA8E6CF), Color(0xFF7DE8D8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    'assets/images/logo_forgot.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Forgot Password?',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email to receive a reset link',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 32),

              AppTextField(
                label: 'Email',
                hint: 'your@email.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailErr,
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                  text: 'Send Reset Link', onPressed: _handleSend),
            ],
          ),
        ),
      ),
    );
  }
}
