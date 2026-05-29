import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'expert_consult.dart';
import 'expert_riwayat_consult.dart';

const Color kExChatMain = Color(0xFF5DCFCF);
const Color kExChatTeal = Color(0xFF76EAD0);
const Color kExChatBlue = Color(0xFF76D7EA);
const Color kExChatScaffold = Color(0xFFE8F5F3);

// ─── Message model ────────────────────────────────────────────────────────────
enum ExMsgType { text, image, video }

class ExpertChatMessage {
  final String? text;
  final bool isMe; // true = expert (right bubble)
  final String time;
  final ExMsgType type;
  final String? mediaUrl;
  final File? mediaFile;
  final String? videoDuration;

  const ExpertChatMessage({
    this.text,
    required this.isMe,
    required this.time,
    this.type = ExMsgType.text,
    this.mediaUrl,
    this.mediaFile,
    this.videoDuration,
  });
}

// ─── Auto-reply pool ──────────────────────────────────────────────────────────
const List<String> _clientReplies = [
  'Thank you so much! That really helps.',
  'I see, so I should reduce watering frequency?',
  'How often should I apply the treatment?',
  'Great advice! I will try that right away.',
  'Can you show me which part of the leaf to check?',
  'Is this something I can treat at home?',
  'What if the symptoms get worse after treatment?',
  'Which product brand do you recommend?',
  'I will send you another photo once I see changes.',
  'This is really helpful, thank you so much!',
];

List<ExpertChatMessage> _buildInitialMessages(String clientName, String topic) {
  return [
    ExpertChatMessage(
      text:
          'Hi Dr. Martinez! My ${topic.toLowerCase()} is a real concern right now. Can you help me understand what\'s happening?',
      isMe: false,
      time: '2:14 PM',
    ),
    ExpertChatMessage(
      type: ExMsgType.image,
      mediaUrl:
          'https://images.unsplash.com/photo-1591857177580-dc82b9ac4e1e?w=500&q=80&auto=format&fit=crop',
      isMe: false,
      time: '2:15 PM',
    ),
    ExpertChatMessage(
      text:
          'Hello $clientName! Thank you for the detailed photo. I can see the issue clearly. This looks like a watering problem combined with possible fungal infection.',
      isMe: true,
      time: '2:18 PM',
    ),
    ExpertChatMessage(
      text:
          'Based on the symptoms, I recommend:\n\n1. Reduce watering frequency\n2. Ensure proper drainage\n3. Apply fungicide treatment\n4. Remove affected leaves',
      isMe: true,
      time: '2:19 PM',
    ),
    ExpertChatMessage(
      text:
          'Thank you so much! How often should I water it now? And which fungicide do you recommend?',
      isMe: false,
      time: '2:22 PM',
    ),
    ExpertChatMessage(
      text:
          'Water only when the top 2 inches of soil are dry. For fungicide, I recommend copper-based spray. Apply every 7–10 days for 3 weeks.',
      isMe: true,
      time: '2:24 PM',
    ),
  ];
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ExpertChatPage extends StatefulWidget {
  final String clientName;
  final String clientAvatar;
  final String topic;

  const ExpertChatPage({
    super.key,
    required this.clientName,
    required this.clientAvatar,
    required this.topic,
  });

  @override
  State<ExpertChatPage> createState() => ExpertChatPageState();
}

class ExpertChatPageState extends State<ExpertChatPage> {
  final TextEditingController msgCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();
  final ImagePicker picker = ImagePicker();
  late List<ExpertChatMessage> messages;
  bool hasText = false;
  int replyIndex = 0;

  @override
  void initState() {
    super.initState();
    messages = _buildInitialMessages(widget.clientName, widget.topic);
    msgCtrl.addListener(
        () => setState(() => hasText = msgCtrl.text.trim().isNotEmpty));
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    msgCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (scrollCtrl.hasClients) {
      scrollCtrl.animateTo(
        scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour > 12
        ? now.hour - 12
        : now.hour == 0
            ? 12
            : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  void _triggerAutoReply() {
    final reply = _clientReplies[replyIndex % _clientReplies.length];
    replyIndex++;
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        messages.add(ExpertChatMessage(
          text: reply,
          isMe: false,
          time: _currentTime(),
        ));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  void _sendText() {
    final text = msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add(ExpertChatMessage(
        text: text,
        isMe: true,
        time: _currentTime(),
      ));
      msgCtrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    _triggerAutoReply();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? file =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return;
      setState(() {
        messages.add(ExpertChatMessage(
          type: ExMsgType.image,
          mediaFile: File(file.path),
          isMe: true,
          time: _currentTime(),
        ));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      _triggerAutoReply();
    } catch (_) {}
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
      if (file == null) return;
      setState(() {
        messages.add(ExpertChatMessage(
          type: ExMsgType.video,
          mediaFile: File(file.path),
          videoDuration: '0:00',
          isMe: true,
          time: _currentTime(),
        ));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      _triggerAutoReply();
    } catch (_) {}
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.call_end_rounded,
                    color: Colors.redAccent, size: 28),
              ),
              const SizedBox(height: 14),
              Text('End Session',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to end this consultation session with ${widget.clientName}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.5),
              ),
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
                        _endSession();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text('End Session',
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

  void _endSession() {
    // Move from active to completed
    final activeIndex =
        activeConsults.indexWhere((c) => c.clientName == widget.clientName);
    if (activeIndex != -1) {
      final item = activeConsults[activeIndex];
      activeConsults.removeAt(activeIndex);
      completedConsults.insert(0, item);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: kExChatTeal.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: kExChatMain, size: 28),
              ),
              const SizedBox(height: 14),
              Text('Session Ended',
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text(
                'Consultation with ${widget.clientName} has been completed and moved to your history.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.5),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (c) => ExpertConsultPage()),
                    (route) => route.isFirst,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: kExChatMain,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: kExChatMain.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Text('Back to Consultations',
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
      backgroundColor: kExChatScaffold,
      body: Column(
        children: [
          _buildHeader(),
          _buildSessionBanner(),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (ctx, i) => _buildMessageItem(messages[i]),
            ),
          ),
          _buildInputBar(),
          _buildEndSessionButton(),
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
          colors: [kExChatBlue, kExChatTeal],
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
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              // Client avatar
              Stack(
                children: [
                  ClipOval(
                    child: Image.network(
                      widget.clientAvatar,
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, s) => Container(
                        width: 38,
                        height: 38,
                        color: Colors.white.withOpacity(0.3),
                        child: Center(
                          child: Text(widget.clientName[0],
                              style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.clientName,
                        style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(widget.topic,
                        style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.85))),
                  ],
                ),
              ),
              Text('Active Session',
                  style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9))),
            ],
          ),
        ),
      ),
    );
  }

  // ── Session Banner ────────────────────────────────────────────────────────
  Widget _buildSessionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kExChatTeal.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: Color(0xFF4CAF50), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session Active',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                Text('45-minute consultation',
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Message Item ──────────────────────────────────────────────────────────
  Widget _buildMessageItem(ExpertChatMessage msg) {
    final isMe = msg.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                ClipOval(
                  child: Image.network(
                    widget.clientAvatar,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, s) => Container(
                      width: 32,
                      height: 32,
                      color: kExChatTeal.withOpacity(0.3),
                      child: Center(
                        child: Text(widget.clientName[0],
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: kExChatMain)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(child: _buildBubble(msg)),
              if (isMe) const SizedBox(width: 4),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              bottom: 10,
              left: isMe ? 0 : 40,
              right: isMe ? 4 : 0,
            ),
            child: Text(msg.time,
                style: GoogleFonts.outfit(
                    fontSize: 10, color: Colors.grey.shade400)),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ExpertChatMessage msg) {
    final maxWidth = MediaQuery.of(context).size.width * 0.68;
    switch (msg.type) {
      case ExMsgType.image:
        return _buildImageBubble(msg, maxWidth);
      case ExMsgType.video:
        return _buildVideoBubble(msg, maxWidth);
      default:
        return _buildTextBubble(msg, maxWidth);
    }
  }

  Widget _buildTextBubble(ExpertChatMessage msg, double maxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        // Expert (isMe) = teal, client = white
        color: msg.isMe ? kExChatMain : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
          bottomRight: Radius.circular(msg.isMe ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Text(msg.text ?? '',
          style: GoogleFonts.outfit(
              fontSize: 14,
              color: msg.isMe ? Colors.white : Colors.black87,
              height: 1.45)),
    );
  }

  Widget _buildImageBubble(ExpertChatMessage msg, double maxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: msg.isMe ? kExChatMain.withOpacity(0.9) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
          bottomRight: Radius.circular(msg.isMe ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
          bottomRight: Radius.circular(msg.isMe ? 4 : 18),
        ),
        child: msg.mediaFile != null
            ? Image.file(msg.mediaFile!,
                width: double.infinity, height: 200, fit: BoxFit.cover)
            : Image.network(msg.mediaUrl ?? '',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, p) {
                  if (p == null) return child;
                  return Container(
                    height: 200,
                    color: kExChatTeal.withOpacity(0.2),
                    child: const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kExChatMain),
                    ),
                  );
                },
                errorBuilder: (ctx, e, s) => Container(
                      height: 200,
                      color: kExChatTeal.withOpacity(0.2),
                      child: const Icon(Icons.image_outlined,
                          color: kExChatMain, size: 40),
                    )),
      ),
    );
  }

  Widget _buildVideoBubble(ExpertChatMessage msg, double maxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
          bottomRight: Radius.circular(msg.isMe ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(msg.isMe ? 18 : 4),
          bottomRight: Radius.circular(msg.isMe ? 4 : 18),
        ),
        child: Stack(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black54,
              child:
                  const Icon(Icons.videocam, color: Colors.white54, size: 48),
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
            ),
            if (msg.videoDuration != null)
              Positioned(
                bottom: 8,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(msg.videoDuration!,
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Input Bar ─────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Photo
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: kExChatTeal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_outlined,
                    color: kExChatMain, size: 22),
              ),
            ),
            // Video
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: kExChatTeal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.videocam_outlined,
                    color: kExChatMain, size: 22),
              ),
            ),
            // Text field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: kExChatScaffold,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: msgCtrl,
                  maxLines: 5,
                  minLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  style:
                      GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Type your reply...',
                    hintStyle: GoogleFonts.outfit(
                        fontSize: 14, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send
            GestureDetector(
              onTap: _sendText,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: hasText ? kExChatMain : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── End Session Button ────────────────────────────────────────────────────
  // ── End Session Button ────────────────────────────────────────────────────
  Widget _buildEndSessionButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _showEndSessionDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'End Session',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
