import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../app_widgets.dart';
import 'hello_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isUser = true;
  String _selectedGender = 'Male';

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _nameErr;
  String? _emailErr;
  String? _phoneErr;
  String? _passErr;
  String? _confirmErr;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() {
      _nameErr =
          _nameCtrl.text.trim().isEmpty ? 'Nama wajib diisi' : null;
      _emailErr =
          _emailCtrl.text.trim().isEmpty ? 'Email wajib diisi' : null;
      _phoneErr =
          _phoneCtrl.text.trim().isEmpty ? 'Nomor HP wajib diisi' : null;
      _passErr =
          _passCtrl.text.trim().isEmpty ? 'Password wajib diisi' : null;
      if (_confirmCtrl.text.trim().isEmpty) {
        _confirmErr = 'Konfirmasi password wajib diisi';
      } else if (_confirmCtrl.text != _passCtrl.text) {
        _confirmErr = 'Password tidak cocok';
      } else {
        _confirmErr = null;
      }
    });

    if (_nameErr != null ||
        _emailErr != null ||
        _phoneErr != null ||
        _passErr != null ||
        _confirmErr != null) return;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButtonWidget(),
              const SizedBox(height: 12),

              Text(
                'Create Account',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Join Sproutly to connect with plant experts',
                style: GoogleFonts.outfit(
                    fontSize: 13.5, color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),

              // Tab switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4EEEC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  _buildTab('Register as User', true),
                  _buildTab('Botanist Expert', false),
                ]),
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: 'Full Name',
                hint: 'John Doe',
                controller: _nameCtrl,
                errorText: _nameErr,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Email',
                hint: 'your@email.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailErr,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Phone Number',
                hint: '+1 (555) 000-0000',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                errorText: _phoneErr,
              ),
              const SizedBox(height: 14),

              // Gender
              Text(
                'Gender',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Male', 'Female', 'Other'].map((g) {
                  final isLast = g == 'Other';
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGender = g),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 11),
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
                          child: Text(
                            g,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _selectedGender == g
                                  ? AppColors.tealDark
                                  : AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passCtrl,
                obscureText: true,
                errorText: _passErr,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Confirm Password',
                hint: '••••••••',
                controller: _confirmCtrl,
                obscureText: true,
                errorText: _confirmErr,
              ),
              const SizedBox(height: 22),

              PrimaryButton(
                  text: 'Create Account', onPressed: _handleRegister),
              const SizedBox(height: 22),

              Center(
                child: Column(
                  children: [
                    Text(
                      "Already have an account?",
                      style: GoogleFonts.outfit(
                          fontSize: 13.5, color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
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

  Widget _buildTab(String label, bool isUser) {
    final isActive = _isUser == isUser;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isUser = isUser),
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
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.white : AppColors.textGrey,
            ),
          ),
        ),
      ),
    );
  }
}
