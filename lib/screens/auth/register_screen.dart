import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../app_colors.dart';
import '../../app_widgets.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'expert_register.dart';

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

  bool _passVisible = false;
  bool _confirmVisible = false;

  bool isValidEmail(String email) =>
      RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);

  bool isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 9 && digits.length <= 15;
  }

  // Sama persis dengan expert_register: min 8 karakter, minimal 1 angka
  bool isValidPassword(String pass) =>
      pass.length >= 8 && RegExp(r'\d').hasMatch(pass);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() {
      // Name
      _nameErr = _nameCtrl.text.trim().isEmpty ? 'Full name is required' : null;

      // Email
      if (_emailCtrl.text.trim().isEmpty) {
        _emailErr = 'Email is required';
      } else if (!isValidEmail(_emailCtrl.text.trim())) {
        _emailErr = 'Please enter a valid email address';
      } else {
        _emailErr = null;
      }

      // Phone
      if (_phoneCtrl.text.trim().isEmpty) {
        _phoneErr = 'Phone number is required';
      } else if (!isValidPhone(_phoneCtrl.text.trim())) {
        _phoneErr = 'Enter a valid phone number (min. 9 digits)';
      } else {
        _phoneErr = null;
      }

      // Password — min 8 chars + 1 number
      if (_passCtrl.text.trim().isEmpty) {
        _passErr = 'Password is required';
      } else if (!isValidPassword(_passCtrl.text)) {
        _passErr = 'Min 8 characters, include at least 1 number';
      } else {
        _passErr = null;
      }

      // Confirm password
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
        _passErr != null ||
        _confirmErr != null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.registerUser(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _selectedGender,
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registration successful!'),
          backgroundColor: AppColors.teal,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registration failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _goToExpertRegister() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => const ExpertRegisterScreen(),
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

              Text('Create Account',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.3,
                  )),
              const SizedBox(height: 6),
              Text('Join Sproutly to connect with plant experts',
                  style: GoogleFonts.outfit(
                      fontSize: 13.5, color: AppColors.textGrey)),
              const SizedBox(height: 20),

              // ── Tab Switcher ──
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
                hint: 'your@gmail.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailErr,
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Phone Number',
                hint: '+62 812 3456 7890',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                errorText: _phoneErr,
              ),
              const SizedBox(height: 14),

              // ── Gender ──
              Text('Gender',
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              Row(
                children: ['Male', 'Female'].map((g) {
                  final isLast = g == 'Female';
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 10),
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
              const SizedBox(height: 14),

              // ── Password ──
              _buildPasswordField(
                label: 'Password',
                hint: '••••••••',
                controller: _passCtrl,
                errorText: _passErr,
                isVisible: _passVisible,
                onToggle: () => setState(() => _passVisible = !_passVisible),
              ),
              // Helper text — hanya muncul kalau tidak ada error
              if (_passErr == null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    'Min 8 characters, include at least 1 number',
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: AppColors.textGrey),
                  ),
                ),
              const SizedBox(height: 14),

              // ── Confirm Password ──
              _buildPasswordField(
                label: 'Confirm Password',
                hint: '••••••••',
                controller: _confirmCtrl,
                errorText: _confirmErr,
                isVisible: _confirmVisible,
                onToggle: () =>
                    setState(() => _confirmVisible = !_confirmVisible),
              ),
              const SizedBox(height: 22),

              PrimaryButton(text: 'Create Account', onPressed: _handleRegister),
              const SizedBox(height: 22),

              Center(
                child: Column(
                  children: [
                    Text('Already have an account?',
                        style: GoogleFonts.outfit(
                            fontSize: 13.5, color: AppColors.textGrey)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Log In',
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.tealDark,
                          )),
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
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
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

  Widget _buildTab(String label, bool isUser) {
    final isActive = _isUser == isUser;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isUser) {
            setState(() => _isUser = true);
          } else {
            _goToExpertRegister();
          }
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
