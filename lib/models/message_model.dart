import 'user_model.dart';

class Message {
  final int id;
  final int consultationId;
  final int senderId;
  final String? message;
  final String? attachment;
  final String messageType; // 'text', 'image', 'video'
  final bool isRead;
  final DateTime? createdAt;
  final User? sender;

  Message({
    required this.id,
    required this.consultationId,
    required this.senderId,
    this.message,
    this.attachment,
    required this.messageType,
    required this.isRead,
    this.createdAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      consultationId: json['consultation_id'] is String
          ? int.parse(json['consultation_id'])
          : json['consultation_id'],
      senderId: json['sender_id'] is String
          ? int.parse(json['sender_id'])
          : json['sender_id'],
      message: json['message'],
      attachment: json['attachment'],
      messageType: json['message_type'] ?? 'text',
      isRead: json['is_read'] is int
          ? json['is_read'] == 1
          : (json['is_read'] ?? false),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'consultation_id': consultationId,
        'sender_id': senderId,
        'message': message,
        'attachment': attachment,
        'message_type': messageType,
        'is_read': isRead,
        'created_at': createdAt?.toIso8601String(),
        'sender': sender?.toJson(),
      };
}
