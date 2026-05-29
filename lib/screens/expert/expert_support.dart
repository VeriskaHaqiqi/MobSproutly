import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kExpertSupportTeal = Color(0xFF76EAD0);
const Color kExpertSupportBlue = Color(0xFF76D7EA);
const Color kExpertSupportMain = Color(0xFF5DCFCF);
const Color kExpertSupportScaffold = Color(0xFFF0F4F3);

class ExpertSupportScreen extends StatefulWidget {
  const ExpertSupportScreen({super.key});

  @override
  State<ExpertSupportScreen> createState() => _ExpertSupportScreenState();
}

class _ExpertSupportScreenState extends State<ExpertSupportScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _helpKey = GlobalKey();
  final GlobalKey _privacyKey = GlobalKey();
  final GlobalKey _termsKey = GlobalKey();
  final GlobalKey _reportKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();

  final TextEditingController _issueTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _scrollController.dispose();
    _issueTitleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final sizeInMb = file.size / (1024 * 1024);

    if (sizeInMb > 5) {
      _showSnackBar('File size must be less than 5 MB.');
      return;
    }

    setState(() {
      _selectedFile = file;
    });
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _submitReport() {
    final title = _issueTitleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty || _selectedFile == null) {
      _showSnackBar('Please complete all fields before submitting the report.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: kExpertSupportTeal.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: kExpertSupportMain,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Report Sent',
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your report has been submitted successfully. Our support team will review your account issue and respond within 1x24 hours.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.55,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _issueTitleController.clear();
                      _descriptionController.clear();
                      setState(() {
                        _selectedFile = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kExpertSupportMain,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Okay',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    final mb = bytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(2)} MB';

    final kb = bytes / 1024;
    return '${kb.toStringAsFixed(1)} KB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kExpertSupportScaffold,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSupportTopics(),
                  const SizedBox(height: 16),
                  _buildHelpCenter(),
                  const SizedBox(height: 16),
                  _buildPrivacyPolicy(),
                  const SizedBox(height: 16),
                  _buildTermsOfService(),
                  const SizedBox(height: 16),
                  _buildReportProblem(),
                  const SizedBox(height: 16),
                  _buildAboutSproutly(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kExpertSupportBlue, kExpertSupportTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
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
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Support & Info',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportTopics() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Support Topics'),
          const SizedBox(height: 12),
          _topicItem(
            icon: Icons.help_outline_rounded,
            color: kExpertSupportBlue,
            title: 'Help Center',
            onTap: () => _scrollToSection(_helpKey),
          ),
          _topicItem(
            icon: Icons.privacy_tip_outlined,
            color: kExpertSupportTeal,
            title: 'Privacy Policy',
            onTap: () => _scrollToSection(_privacyKey),
          ),
          _topicItem(
            icon: Icons.description_outlined,
            color: const Color(0xFFD0FF99),
            title: 'Terms of Service',
            onTap: () => _scrollToSection(_termsKey),
          ),
          _topicItem(
            icon: Icons.flag_outlined,
            color: Colors.redAccent,
            title: 'Report a Problem',
            onTap: () => _scrollToSection(_reportKey),
          ),
          _topicItem(
            icon: Icons.eco_outlined,
            color: const Color(0xFF99CC66),
            title: 'About Sproutly',
            onTap: () => _scrollToSection(_aboutKey),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCenter() {
    return Container(
      key: _helpKey,
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Help Center'),
            const SizedBox(height: 10),
            _paragraph(
              'Find answers to common questions about managing consultations, responding to clients, writing articles, setting schedules, and handling account settings.',
            ),
            const SizedBox(height: 12),
            _faqTile(
              title: 'How to manage consultation requests',
              answer:
                  'Open the Consultations page and check the Requested tab. You can review the client name, consultation topic, category, and session fee before accepting the request.',
            ),
            _faqTile(
              title: 'When can I start chatting with a client?',
              answer:
                  'Chat access becomes available after you accept a consultation request. Before acceptance, the client request remains locked and the conversation cannot start yet.',
            ),
            _faqTile(
              title: 'How to end an active consultation',
              answer:
                  'Open an active consultation chat, then tap End Session. After confirmation, the session will move to the Completed section and become read-only history.',
            ),
            _faqTile(
              title: 'How to set my consultation availability',
              answer:
                  'Go to Account, open Manage Schedule, and update your available consultation time. This schedule helps users know when you are available.',
            ),
            _faqTile(
              title: 'How to update consultation fees',
              answer:
                  'Go to Account, open Set Consultation Fee, then adjust your session price. The selected fee will be shown to users before they start a consultation.',
            ),
            _faqTile(
              title: 'How to publish articles',
              answer:
                  'Use the article writing feature to create educational content. You can add text, images, and helpful plant care guidance for Sproutly users.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return Container(
      key: _privacyKey,
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Privacy Policy'),
            const SizedBox(height: 10),
            _paragraph(
              'We take expert privacy seriously. This policy explains how Sproutly collects, uses, and protects expert account information and consultation activity.',
            ),
            const SizedBox(height: 12),
            _subTitle('Profile Data'),
            _paragraph(
              'Sproutly may store your profile information, such as name, email, specialty, profile photo, availability schedule, consultation fee, and article activity.',
            ),
            _subTitle('Consultation Data'),
            _paragraph(
              'Messages, photos, videos, diagnosis notes, and session history may be stored to support consultation quality, dispute handling, and service continuity.',
            ),
            _subTitle('Client Information'),
            _paragraph(
              'Experts may access client consultation information only for the purpose of providing plant care advice. Client data must not be shared outside the platform.',
            ),
            _subTitle('Data Protection'),
            _paragraph(
              'Expert and client information is handled securely. Sproutly may restrict access to accounts that misuse personal information or violate platform rules.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsOfService() {
    return Container(
      key: _termsKey,
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Terms of Service'),
            const SizedBox(height: 10),
            _paragraph(
              'By using Sproutly as an expert, you agree to provide responsible consultation services and follow platform guidelines.',
            ),
            const SizedBox(height: 12),
            _subTitle('Expert Responsibilities'),
            _paragraph(
              'Experts must provide helpful, respectful, and accurate guidance based on the information shared by clients. Advice should be communicated clearly and professionally.',
            ),
            _subTitle('Consultation Quality'),
            _paragraph(
              'Experts should review client messages, photos, or videos carefully before giving a diagnosis. If the issue is unclear, experts should ask for additional details.',
            ),
            _subTitle('Availability and Response'),
            _paragraph(
              'Experts are expected to manage their schedule and respond to accepted consultations within a reasonable time. Inactive or abandoned sessions may affect user trust.',
            ),
            _subTitle('Content and Articles'),
            _paragraph(
              'Articles created by experts should be educational, original, and relevant to plant care. Misleading, copied, or harmful content is not allowed.',
            ),
            _subTitle(
              'Payment and Earnings',
            ),
            _paragraph(
              'Consultation earnings may be calculated based on completed sessions and platform policy. Payment records and payout details can be reviewed through expert account features.',
            ),
            _subTitle('Platform Rules'),
            _paragraph(
              'Harassment, misinformation, spam, privacy violations, and misuse of client data are not allowed. Sproutly may review or restrict expert accounts that break these rules.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportProblem() {
    return Container(
      key: _reportKey,
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Report a Problem'),
            const SizedBox(height: 10),
            _paragraph(
              'Found an issue with your account, consultation flow, article editor, schedule, payment, or client session? Submit a report and our team will review it.',
            ),
            const SizedBox(height: 14),
            Text(
              'Issue Title',
              style: _labelStyle(),
            ),
            const SizedBox(height: 6),
            _textField(
              controller: _issueTitleController,
              hint: 'Brief description of the issue',
              maxLines: 1,
            ),
            const SizedBox(height: 14),
            Text(
              'Description',
              style: _labelStyle(),
            ),
            const SizedBox(height: 6),
            _textField(
              controller: _descriptionController,
              hint:
                  'Please explain the problem, affected feature, and what happened...',
              maxLines: 5,
            ),
            const SizedBox(height: 14),
            Text(
              'Screenshot or Supporting File',
              style: _labelStyle(),
            ),
            const SizedBox(height: 6),
            _buildUploadBox(),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kExpertSupportMain,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Submit Report',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSproutly() {
    return Container(
      key: _aboutKey,
      child: _sectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('About Sproutly'),
            const SizedBox(height: 10),
            _paragraph(
              'Sproutly is a feature that allows plant specialists to provide consultations, share educational articles, manage schedules, and help users solve plant care problems.',
            ),
            const SizedBox(height: 12),
            _paragraph(
              'Experts play an important role in helping plant owners understand symptoms, improve care routines, prevent plant damage, and learn better cultivation practices.',
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 10),
            _aboutRow('App Version', '1.0.0'),
            const SizedBox(height: 14),
            _aboutRow('Support Email', 'support@sproutly.app'),
            const SizedBox(height: 14),
            _aboutRow('Service Type', 'Plant Expert Consultation'),
            const SizedBox(height: 22),
            Center(
              child: Text(
                '© 2026 Sproutly by AVI',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topicItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqTile({
    required String title,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kExpertSupportScaffold,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: Colors.grey.shade500,
          collapsedIconColor: Colors.grey.shade500,
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox() {
    if (_selectedFile != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kExpertSupportScaffold,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kExpertSupportMain.withOpacity(0.45)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kExpertSupportTeal.withOpacity(0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.insert_drive_file_outlined,
                color: kExpertSupportMain,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFile!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatFileSize(_selectedFile!.size),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _removeFile,
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: Colors.grey.shade300,
              size: 34,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to upload file',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'PNG, JPG, JPEG, or PDF up to 5 MB',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kExpertSupportMain, width: 1.4),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  Widget _subTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _paragraph(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12.5,
        height: 1.55,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: kExpertSupportMain,
          ),
        ),
      ],
    );
  }

  TextStyle _labelStyle() {
    return GoogleFonts.inter(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    );
  }
}
