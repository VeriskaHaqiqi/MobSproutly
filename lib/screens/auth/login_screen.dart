import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';               // tambahkan
import '../../app_colors.dart';
import '../../app_widgets.dart';
import '../../providers/auth_provider.dart';           // tambahkan
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../user/user_home.dart';                       // untuk HomeUserScreen
import '../expert/expert_home.dart';                   // untuk ExpertHomePage

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

  bool isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);
  }

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
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 350),
    ));
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    setState(() {
      if (email.isEmpty) {
        _emailError = 'Email is required';
      } else if (!isValidEmail(email)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null;
      }
      _passError = password.isEmpty ? 'Password is required' : null;
    });

    if (_emailError != null || _passError != null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(email, password);

    if (success) {
      final role = authProvider.user?.role;
      if (role == 'expert') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ExpertHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeUserScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
              // ── Logo: background tosca penuh, icon putih ──
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF5DCFCF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5DCFCF).withOpacity(0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Heading ──
              Text(
                'Welcome Back',
                style: GoogleFonts.outfit(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'Log in to continue your plant journey',
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 30),

              // ── Email Field ──
              AppTextField(
                label: 'Email',
                hint: 'your@gmail.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 16),

              // ── Password Field ──
              AppTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passController,
                obscureText: true,
                errorText: _passError,
              ),
              const SizedBox(height: 10),

              // ── Forgot Password ──
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

              // ── Log In Button ──
              PrimaryButton(
                text: 'Log In',
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 28),

              // ── Register Link ──
              Center(
                child: Column(
                  children: [
                    Text(
                      "Don't have an account?",
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        color: AppColors.textGrey,
                      ),
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
