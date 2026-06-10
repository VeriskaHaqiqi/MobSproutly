import 'user_model.dart';

class ArticleCategory {
  final int id;
  final String name;

  ArticleCategory({
    required this.id,
    required this.name,
  });

  factory ArticleCategory.fromJson(Map<String, dynamic> json) {
    return ArticleCategory(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class Article {
  final int id;
  final int userId;
  final int categoryId;
  final String title;
  final String content;
  final String? coverImage;
  final String status;
  final DateTime? createdAt;
  final User? author;
  final ArticleCategory? category;
  bool isBookmarked; // Local UI state or API derived

  Article({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.content,
    this.coverImage,
    required this.status,
    this.createdAt,
    this.author,
    this.category,
    this.isBookmarked = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      userId: json['user_id'] is String
          ? int.parse(json['user_id'])
          : json['user_id'],
      categoryId: json['category_id'] is String
          ? int.parse(json['category_id'])
          : json['category_id'],
      title: json['title'],
      content: json['content'],
      coverImage: json['cover_image'],
      status: json['status'] ?? 'published',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      author: json['author'] != null ? User.fromJson(json['author']) : null,
      category: json['category'] != null
          ? ArticleCategory.fromJson(json['category'])
          : null,
      isBookmarked: json['is_bookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'category_id': categoryId,
        'title': title,
        'content': content,
        'cover_image': coverImage,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'author': author?.toJson(),
        'category': category?.toJson(),
      };
}
