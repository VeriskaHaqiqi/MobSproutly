import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserSupportScreen extends StatelessWidget {
  const UserSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      appBar: AppBar(
        title: Text(
          'Support & Info',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF76D7EA),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Support and information page',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
