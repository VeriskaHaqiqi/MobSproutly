import 'user_model.dart';

class Rating {
  final int id;
  final int consultationId;
  final int userId;
  final int expertId;
  final int score;
  final String? comment;
  final DateTime? createdAt;
  final User? user; // User who gave the rating

  Rating({
    required this.id,
    required this.consultationId,
    required this.userId,
    required this.expertId,
    required this.score,
    this.comment,
    this.createdAt,
    this.user,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      consultationId: json['consultation_id'] is String
          ? int.parse(json['consultation_id'])
          : json['consultation_id'],
      userId: json['user_id'] is String
          ? int.parse(json['user_id'])
          : json['user_id'],
      expertId: json['expert_id'] is String
          ? int.parse(json['expert_id'])
          : json['expert_id'],
      score: json['score'] is String
          ? int.parse(json['score'])
          : (json['score'] ?? 0),
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'consultation_id': consultationId,
        'user_id': userId,
        'expert_id': expertId,
        'score': score,
        'comment': comment,
        'created_at': createdAt?.toIso8601String(),
        'user': user?.toJson(),
      };
}
