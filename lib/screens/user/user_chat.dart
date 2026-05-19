import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'user_consult.dart';

const Color kChatTeal = Color(0xFF76EAD0);
const Color kChatBlue = Color(0xFF76D7EA);
const Color kChatMain = Color(0xFF5DCFCF);
const Color kChatLGreen = Color(0xFFD0FF99);
const Color kChatScaffold = Color(0xFFE8F5F3);

enum MessageType { text, image, video }

class ChatMessage {
  final String? text;
  final bool isMe;
  final String time;
  final MessageType type;
  final String? mediaUrl;
  final File? mediaFile;
  final String? videoDuration;

  const ChatMessage({
    this.text,
    required this.isMe,
    required this.time,
    this.type = MessageType.text,
    this.mediaUrl,
    this.mediaFile,
    this.videoDuration,
  });
}

List<ChatMessage> buildDummyMessages(ConsultItem consult) {
  return [
    ChatMessage(
      text:
          "Hi! I'm ${consult.expertName.split(' ').first}, your plant expert for today. Can you tell me more about the symptoms you've noticed?",
      isMe: false,
      time: '2:34 PM',
    ),
    const ChatMessage(
      text:
          'The leaves are turning yellow and have brown spots. It started about a week ago.',
      isMe: true,
      time: '2:35 PM',
    ),
    const ChatMessage(
      text:
          'That sounds like it could be overwatering or a fungal issue. Could you send me a photo of the affected leaves?',
      isMe: false,
      time: '2:36 PM',
    ),
    const ChatMessage(
      type: MessageType.image,
      mediaUrl:
          'https://images.unsplash.com/photo-1591857177580-dc82b9ac4e1e?w=500&q=80',
      text: "Here's the worst affected leaf",
      isMe: true,
      time: '2:38 PM',
    ),
    const ChatMessage(
      text:
          "Perfect! I can see this is likely overwatering combined with poor drainage. Let's start treatment immediately.",
      isMe: false,
      time: '2:40 PM',
    ),
  ];
}

class UserChatScreen extends StatefulWidget {
  final ConsultItem consult;

  const UserChatScreen({
    super.key,
    required this.consult,
  });

  @override
  State<UserChatScreen> createState() => UserChatScreenState();
}

class UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController msgCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();
  final ImagePicker picker = ImagePicker();

  late List<ChatMessage> messages;
  bool hasText = false;
  int replyIndex = 0;

  static const List<String> expertReplies = [
    "Thank you for sharing that. Based on what you've described, I'd recommend reducing your watering frequency and checking the drainage holes.",
    "That sounds like a common issue with indoor plants. Let the soil dry slightly before the next watering.",
    "The symptoms may indicate early root stress. Try checking the roots and removing any dark or mushy parts.",
    "For this type of plant, bright indirect light is usually best. Avoid direct afternoon sun.",
    "Please keep monitoring the new growth. Healthy new leaves are a good sign of recovery.",
    "If you can, send another photo from the top and side of the plant so I can check the overall condition.",
    "You can also wipe the leaves gently with a damp cloth to remove dust and improve photosynthesis.",
    "This may also be related to pests. Check the underside of the leaves for tiny insects or webbing.",
  ];

  @override
  void initState() {
    super.initState();

    messages = buildDummyMessages(widget.consult);

    msgCtrl.addListener(() {
      setState(() {
        hasText = msgCtrl.text.trim().isNotEmpty;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  @override
  void dispose() {
    msgCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    if (!scrollCtrl.hasClients) return;

    scrollCtrl.animateTo(
      scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String currentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : now.hour == 0
            ? 12
            : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  void triggerAutoReply() {
    final reply = expertReplies[replyIndex % expertReplies.length];
    replyIndex++;

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      setState(() {
        messages.add(
          ChatMessage(
            text: reply,
            isMe: false,
            time: currentTime(),
          ),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    });
  }

  void sendText() {
    final text = msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isMe: true,
          time: currentTime(),
        ),
      );
      msgCtrl.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });

    triggerAutoReply();
  }

  Future<void> pickImage() async {
    try {
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (file == null) return;

      setState(() {
        messages.add(
          ChatMessage(
            type: MessageType.image,
            mediaFile: File(file.path),
            isMe: true,
            time: currentTime(),
          ),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });

      triggerAutoReply();
    } catch (_) {}
  }

  Future<void> pickVideo() async {
    try {
      final XFile? file = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (file == null) return;

      setState(() {
        messages.add(
          ChatMessage(
            type: MessageType.video,
            mediaFile: File(file.path),
            videoDuration: '0:00',
            isMe: true,
            time: currentTime(),
          ),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });

      triggerAutoReply();
    } catch (_) {}
  }

  void showExpertProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.45,
          builder: (ctx, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4F3),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: kChatTeal.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: kChatMain,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Expert Information',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey.shade200, height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildExpertProfileCard(),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _buildSimpleExpertStat(
                                '120+',
                                'Consultations',
                                Icons.chat_bubble_outline_rounded,
                                const Color(0xFFD0FF99),
                              ),
                              const SizedBox(width: 10),
                              _buildSimpleExpertStat(
                                '4.9',
                                'Rating',
                                Icons.star_outline_rounded,
                                const Color(0xFF99FF99),
                              ),
                              const SizedBox(width: 10),
                              _buildSimpleExpertStat(
                                'Fast',
                                'Response',
                                Icons.access_time_rounded,
                                kChatTeal,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpertProfileCard() {
    final consult = widget.consult;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipOval(
                    child: Image.network(
                      consult.avatarUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, s) {
                        return Container(
                          width: 70,
                          height: 70,
                          color: kChatTeal.withOpacity(0.2),
                          child: Center(
                            child: Text(
                              consult.expertName[0],
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: kChatMain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (consult.isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consult.expertName,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      consult.specialty,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: kChatMain,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFBB00),
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.9',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '8 years exp',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      consult.isOnline ? 'Available now' : 'Currently offline',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: consult.isOnline
                            ? const Color(0xFF2E7D32)
                            : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 12),
          Text(
            'About',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${consult.expertName} helps users diagnose plant problems, understand plant care routines, and provide practical recommendations based on the consultation details.',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade100),
          const SizedBox(height: 12),
          Text(
            'Specialization',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: kChatTeal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: kChatTeal.withOpacity(0.4),
              ),
            ),
            child: Text(
              consult.specialty,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: kChatMain,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleExpertStat(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: kChatMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kChatScaffold,
      body: Column(
        children: [
          buildHeader(),
          buildSessionBanner(),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                return buildMessageItem(messages[i]);
              },
            ),
          ),
          buildInputBar(),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kChatBlue, kChatTeal],
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
              Expanded(
                child: Text(
                  'Consultations Chat',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExpertCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipOval(
                child: Image.network(
                  widget.consult.avatarUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, s) {
                    return Container(
                      width: 52,
                      height: 52,
                      color: kChatTeal.withOpacity(0.2),
                      child: Center(
                        child: Text(
                          widget.consult.expertName[0],
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: kChatMain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (widget.consult.isOnline)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.consult.expertName,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.consult.specialty,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: kChatMain,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFBB00),
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '4.9',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '  •  8 years exp',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showExpertProfile(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: kChatMain,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'View Profile',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSessionBanner() {
    return Column(
      children: [
        buildExpertCard(),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: kChatTeal.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Session Active',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '45-minute consultation',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
          child: Text(
            'Send photos or videos for better diagnosis',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMessageItem(ChatMessage msg) {
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
                    widget.consult.avatarUrl,
                    width: 34,
                    height: 34,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, s) {
                      return Container(
                        width: 34,
                        height: 34,
                        color: kChatTeal.withOpacity(0.3),
                        child: Center(
                          child: Text(
                            widget.consult.expertName[0],
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kChatMain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: buildBubble(msg),
              ),
              if (isMe) const SizedBox(width: 4),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              bottom: 10,
              left: isMe ? 0 : 42,
              right: isMe ? 4 : 0,
            ),
            child: Text(
              msg.time,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBubble(ChatMessage msg) {
    final isMe = msg.isMe;
    final maxWidth = MediaQuery.of(context).size.width * 0.68;

    switch (msg.type) {
      case MessageType.image:
        return buildImageBubble(msg, isMe, maxWidth);
      case MessageType.video:
        return buildVideoBubble(msg, isMe, maxWidth);
      case MessageType.text:
        return buildTextBubble(msg, isMe, maxWidth);
    }
  }

  Widget buildTextBubble(ChatMessage msg, bool isMe, double maxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: isMe ? kChatMain : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        msg.text ?? '',
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: isMe ? Colors.white : Colors.black87,
          height: 1.45,
        ),
      ),
    );
  }

  Widget buildImageBubble(ChatMessage msg, bool isMe, double maxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: isMe ? kChatMain.withOpacity(0.9) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(18),
            ),
            child: msg.mediaFile != null
                ? Image.file(
                    msg.mediaFile!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    msg.mediaUrl ?? '',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, p) {
                      if (p == null) return child;

                      return Container(
                        height: 200,
                        color: kChatTeal.withOpacity(0.2),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kChatMain,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, e, s) {
                      return Container(
                        height: 200,
                        color: kChatTeal.withOpacity(0.2),
                        child: const Icon(
                          Icons.image_outlined,
                          color: kChatMain,
                          size: 40,
                        ),
                      );
                    },
                  ),
          ),
          if (msg.text != null && msg.text!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Text(
                msg.text!,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isMe ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget buildVideoBubble(ChatMessage msg, bool isMe, double maxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        child: Stack(
          children: [
            msg.mediaFile != null
                ? Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.black54,
                    child: const Icon(
                      Icons.videocam,
                      color: Colors.white54,
                      size: 48,
                    ),
                  )
                : Image.network(
                    msg.mediaUrl ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, p) {
                      if (p == null) return child;

                      return Container(
                        height: 200,
                        color: Colors.black38,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, e, s) {
                      return Container(
                        height: 200,
                        color: Colors.black54,
                        child: const Icon(
                          Icons.videocam,
                          color: Colors.white54,
                          size: 48,
                        ),
                      );
                    },
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
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            if (msg.videoDuration != null)
              Positioned(
                bottom: 8,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    msg.videoDuration!,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: kChatTeal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: kChatMain,
                  size: 22,
                ),
              ),
            ),
            GestureDetector(
              onTap: pickVideo,
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: kChatTeal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.videocam_outlined,
                  color: kChatMain,
                  size: 22,
                ),
              ),
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: msgCtrl,
                  maxLines: 5,
                  minLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: sendText,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: hasText ? kChatMain : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
