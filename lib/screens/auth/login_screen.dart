import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_colors.dart';
import '../../app_widgets.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'hello_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  String? _emailError;
  String? _passError;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _push(Widget screen) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 350),
    ));
  }

  void _handleLogin() {
    setState(() {
      _emailError = _emailController.text.trim().isEmpty
          ? 'Email wajib diisi'
          : null;
      _passError = _passController.text.trim().isEmpty
          ? 'Password wajib diisi'
          : null;
    });
    if (_emailError != null || _passError != null) return;
    _push(const HelloScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App icon — kotak putih rounded dengan logo di dalam
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/images/logo_login.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              Text(
                'Welcome Back',
                style: GoogleFonts.outfit(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue your plant journey',
                style: GoogleFonts.outfit(
                    fontSize: 13.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 30),

              AppTextField(
                label: 'Email',
                hint: 'your@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passController,
                obscureText: true,
                errorText: _passError,
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => _push(const ForgotPasswordScreen()),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.tealDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              PrimaryButton(text: 'Sign In', onPressed: _handleLogin),
              const SizedBox(height: 20),

              Row(children: [
                const Expanded(child: Divider(color: AppColors.borderColor)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or continue with',
                      style: GoogleFonts.outfit(
                          fontSize: 13, color: AppColors.textGrey)),
                ),
                const Expanded(child: Divider(color: AppColors.borderColor)),
              ]),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleLogin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                        color: AppColors.borderColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    backgroundColor: AppColors.white,
                  ),
                  icon: SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomPaint(painter: _GoogleLogoPainter()),
                  ),
                  label: Text(
                    'Continue with Google',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Center(
                child: Column(
                  children: [
                    Text(
                      "Don't have an account?",
                      style: GoogleFonts.outfit(
                          fontSize: 13.5, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _push(const RegisterScreen()),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tealDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 20;
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(10 * s, 1 * s, 9 * s, 7.5 * s), paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawRect(Rect.fromLTWH(0, 11.5 * s, 10 * s, 7.5 * s), paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawRect(Rect.fromLTWH(0, 5 * s, 4 * s, 6 * s), paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawRect(Rect.fromLTWH(0, 0, 13 * s, 5 * s), paint);

    // White center circle to create the G cutout look
    paint.color = Colors.white;
    canvas.drawCircle(Offset(10 * s, 10 * s), 5.5 * s, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(9.5 * s, 8.5 * s, 9 * s, 3 * s), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
