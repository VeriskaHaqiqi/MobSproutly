import 'user_model.dart';
import 'payment_model.dart';
import 'rating_model.dart';

class Consultation {
  final int id;
  final int userId;
  final int expertId;
  final String? topic;
  final double fee;
  final int? duration; 
  final String
      status; // 'waiting_payment', 'waiting_verification', 'active', 'completed', 'rejected'
  final DateTime? startedAt;
  final DateTime? scheduledEndAt;
  final DateTime? endedAt;
  final DateTime? createdAt;
  final User? user;
  final User? expert;
  final Payment? payment;
  final Rating? rating;

  Consultation({
    required this.id,
    required this.userId,
    required this.expertId,
    this.topic,
    required this.fee,
    this.duration,
    required this.status,
    this.startedAt,
    this.scheduledEndAt,
    this.endedAt,
    this.createdAt,
    this.user,
    this.expert,
    this.payment,
    this.rating,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'],
      userId: json['user_id'] is String
          ? int.parse(json['user_id'])
          : json['user_id'],
      expertId: json['expert_id'] is String
          ? int.parse(json['expert_id'])
          : json['expert_id'],
      topic: json['topic'],
      fee: json['fee'] != null ? double.parse(json['fee'].toString()) : 0.0,
      duration: json['duration'] as int?,
      status: json['status'] ?? 'waiting_payment',
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      scheduledEndAt: json['scheduled_end_at'] != null
          ? DateTime.parse(json['scheduled_end_at'])
          : null,
      endedAt:
          json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      expert: json['expert'] != null ? User.fromJson(json['expert']) : null,
      payment:
          json['payment'] != null ? Payment.fromJson(json['payment']) : null,
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'expert_id': expertId,
        'topic': topic,
        'fee': fee,
        'status': status,
        'started_at': startedAt?.toIso8601String(),
        'scheduled_end_at': scheduledEndAt?.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'user': user?.toJson(),
        'expert': expert?.toJson(),
        'payment': payment?.toJson(),
        'rating': rating?.toJson(),
      };
}
