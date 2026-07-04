import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/login_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/image_helper.dart';

const Color kEditTeal = Color(0xFF76EAD0);
const Color kEditBlue = Color(0xFF76D7EA);
const Color kEditMain = Color(0xFF5DCFCF);
const Color kEditLGreen = Color(0xFFD0FF99);
const Color kEditScaffold = Color(0xFFF0F4F3);



class UserEditProfilScreen extends StatefulWidget {
  const UserEditProfilScreen({super.key});

  @override
  State<UserEditProfilScreen> createState() => UserEditProfilScreenState();
}

class UserEditProfilScreenState extends State<UserEditProfilScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  String selectedGender = 'Female';
  String? photoPath;
  bool isSaving = false;

  String? nameErr;
  String? emailErr;
  String? phoneErr;

  final ImagePicker picker = ImagePicker();

  bool get isNetworkPhoto =>
      photoPath != null &&
      photoPath!.isNotEmpty &&
      (photoPath!.startsWith('http://') || photoPath!.startsWith('https://'));

  bool isValidGmail(String email) =>
      RegExp(r'^[\w\.-]+@gmail\.com$').hasMatch(email);

  bool isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 9 && digits.length <= 15;
  }

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    nameCtrl.text = user?.name ?? '';
    emailCtrl.text = user?.email ?? '';
    phoneCtrl.text = user?.phone ?? '';
    selectedGender = (user?.gender == 'Male' || user?.gender == 'Female') ? user!.gender! : 'Female';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  // ── Photo Picker ──────────────────────────────────────────────────────────
  void showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text('Change Profile Photo',
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
            const SizedBox(height: 16),
            buildSheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(ctx);
                pickFromGallery();
              },
            ),
            const SizedBox(height: 10),
            buildSheetOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take a Photo',
              onTap: () {
                Navigator.pop(ctx);
                pickFromCamera();
              },
            ),
            const SizedBox(height: 10),
              buildSheetOption(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Photo',
                color: Colors.redAccent,
                onTap: () async {
                  Navigator.pop(ctx);
                  setState(() => photoPath = null);
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final deleted = await authProvider.deletePhoto();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(deleted ? 'Photo removed' : 'Failed to remove photo',
                            style: GoogleFonts.outfit(fontSize: 13)),
                        backgroundColor: deleted ? kEditMain : Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? kEditMain;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w600, color: c)),
          ],
        ),
      ),
    );
  }

  Future<void> pickFromGallery() async {
    try {
      final XFile? file =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file != null) setState(() => photoPath = file.path);
    } catch (_) {}
  }

  Future<void> pickFromCamera() async {
    try {
      final XFile? file =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (file != null) setState(() => photoPath = file.path);
    } catch (_) {}
  }

  // ── Validate & Save ───────────────────────────────────────────────────────
  void handleSave() {
    setState(() {
      nameErr = nameCtrl.text.trim().isEmpty ? 'Full name is required' : null;

      if (emailCtrl.text.trim().isEmpty) {
        emailErr = 'Email is required';
      } else if (!isValidGmail(emailCtrl.text.trim())) {
        emailErr = 'Please use a @gmail.com address';
      } else {
        emailErr = null;
      }

      if (phoneCtrl.text.trim().isEmpty) {
        phoneErr = 'Phone number is required';
      } else if (!isValidPhone(phoneCtrl.text.trim())) {
        phoneErr = 'Enter a valid phone number (min. 9 digits)';
      } else {
        phoneErr = null;
      }
    });

    if (nameErr != null || emailErr != null || phoneErr != null) return;

    setState(() => isSaving = true);

    Future.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateProfile(
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        gender: selectedGender,
      );

      // Handle photo: upload new local file, or skip if network URL (unchanged)
      if (success && photoPath != null && !isNetworkPhoto) {
        await authProvider.uploadPhoto(photoPath!);
      }

      if (!mounted) return;
      setState(() => isSaving = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!',
                style: GoogleFonts.outfit(fontSize: 13)),
            backgroundColor: kEditMain,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile.',
                style: GoogleFonts.outfit(fontSize: 13)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 26),
              ),
              const SizedBox(height: 14),
              Text('Log Out',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text('Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 13, color: Colors.grey.shade500)),
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
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).pushAndRemoveUntil(
                          PageRouteBuilder(
                            pageBuilder: (c, a, b) => const LoginScreen(),
                            transitionsBuilder: (c, animation, b, child) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                            transitionDuration:
                                const Duration(milliseconds: 400),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('Log Out',
                          style: GoogleFonts.outfit(
                              fontSize: 14, fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kEditScaffold,
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAvatarSection(),
                  const SizedBox(height: 28),
                  buildField(
                    label: 'Full Name',
                    controller: nameCtrl,
                    hint: 'Sarah Johnson',
                    errorText: nameErr,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),
                  buildField(
                    label: 'Email',
                    controller: emailCtrl,
                    hint: 'sarah.johnson@gmail.com',
                    errorText: emailErr,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  buildField(
                    label: 'Phone Number',
                    controller: phoneCtrl,
                    hint: '+1 (555) 123-4567',
                    errorText: phoneErr,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d\+\-\s\(\)]')),
                      LengthLimitingTextInputFormatter(16),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildGenderDropdown(),
                  const SizedBox(height: 32),
                  buildSaveButton(),
                  const SizedBox(height: 14),
                  buildLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kEditBlue, kEditTeal],
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
              Text('Edit Profile',
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

  // ── Avatar Section ────────────────────────────────────────────────────────
  Widget buildAvatarSection() {
    final user = Provider.of<AuthProvider>(context).user;
    return Center(
      child: Column(
        children: [
          // Avatar circle
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipOval(
                  child: photoPath != null
                      ? (isNetworkPhoto
                          ? Image.network(photoPath!,
                              fit: BoxFit.cover, width: 100, height: 100,
                              errorBuilder: (ctx, err, stack) => Container(
                                color: kEditTeal.withOpacity(0.2),
                                child: const Icon(Icons.person, color: kEditMain, size: 40),
                              ))
                          : ImageHelper.fromPath(photoPath!,
                              fit: BoxFit.cover, width: 100, height: 100))
                      : Image.network(
                          user?.photoUrl ?? 'https://images.unsplash.com/photo-1494790108755-2616b612b77c?w=200&q=80',
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          errorBuilder: (ctx, err, stack) {
                            return Container(
                              color: kEditTeal.withOpacity(0.2),
                              child: const Icon(Icons.person, color: kEditMain, size: 40),
                            );
                          },
                        ),
                ),
              ),
              // Camera badge
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: showPhotoOptions,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: kEditMain,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Change Photo / Remove buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: showPhotoOptions,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                  decoration: BoxDecoration(
                    color: kEditMain,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Change Photo',
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  setState(() => photoPath = null);
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final deleted = await authProvider.deletePhoto();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(deleted ? 'Photo removed' : 'Failed to remove photo',
                            style: GoogleFonts.outfit(fontSize: 13)),
                        backgroundColor: deleted ? kEditMain : Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 1.2),
                  ),
                  child: Text('Remove',
                      style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Text Field ────────────────────────────────────────────────────────────
  Widget buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? errorText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  errorText != null ? Colors.redAccent : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade400),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  // ── Gender Dropdown ───────────────────────────────────────────────────────
  Widget buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender',
            style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: selectedGender.isEmpty ? null : selectedGender,
            hint: Text('Select gender',
                style: GoogleFonts.outfit(
                    fontSize: 14, color: Colors.grey.shade400)),
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              isDense: true,
            ),
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade500),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(14),
            items: ['Male', 'Female'].map((g) {
              return DropdownMenuItem(
                value: g,
                child: Text(g,
                    style: GoogleFonts.outfit(
                        fontSize: 14, color: Colors.black87)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => selectedGender = val);
            },
          ),
        ),
      ],
    );
  }

  // ── Save Button ───────────────────────────────────────────────────────────
  Widget buildSaveButton() {
    return GestureDetector(
      onTap: isSaving ? null : handleSave,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSaving
                ? [Colors.grey.shade300, Colors.grey.shade300]
                : [kEditBlue, kEditMain],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSaving
              ? []
              : [
                  BoxShadow(
                      color: kEditMain.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
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
            : Text('Save Changes',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
      ),
    );
  }

  // ── Log Out Button ────────────────────────────────────────────────────────
  Widget buildLogoutButton() {
    return GestureDetector(
      onTap: handleLogout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
            const SizedBox(width: 8),
            Text('Log Out',
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }
}
