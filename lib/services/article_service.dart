import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/article_model.dart';
import '../utils/file_helper.dart';

class ArticleService {
  final ApiClient _apiClient = ApiClient();
  late final Dio _dio;

  ArticleService() {
    _dio = _apiClient.dio;
  }

  // Get all articles (with pagination, search, category filters)
  Future<Map<String, dynamic>> getArticles({int page = 1, int? categoryId, String? search}) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
      };
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('/articles', queryParameters: queryParams);
      final listJson = response.data['data']['data'] as List;
      final articles = listJson.map((json) => Article.fromJson(json)).toList();
      final lastPage = response.data['data']['last_page'] ?? 1;

      return {
        'success': true,
        'articles': articles,
        'lastPage': lastPage,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load articles');
      return {'success': false, 'message': msg};
    }
  }

  // Get categories
  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _dio.get('/articles/categories');
      final listJson = response.data['data'] as List;
      final categories = listJson.map((json) => ArticleCategory.fromJson(json)).toList();

      return {
        'success': true,
        'categories': categories,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load categories');
      return {'success': false, 'message': msg};
    }
  }

  // Get expert's own articles
  Future<Map<String, dynamic>> getMyArticles({int page = 1}) async {
    try {
      final response = await _dio.get('/articles/user/my-articles', queryParameters: {'page': page});
      final listJson = response.data['data']['data'] as List;
      final articles = listJson.map((json) => Article.fromJson(json)).toList();
      final lastPage = response.data['data']['last_page'] ?? 1;

      return {
        'success': true,
        'articles': articles,
        'lastPage': lastPage,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load your articles');
      return {'success': false, 'message': msg};
    }
  }

  // Create article (Expert only)
  Future<Map<String, dynamic>> createArticle({
    required int categoryId,
    required String title,
    required String content,
    String? coverImagePath,
    String status = 'published',
  }) async {
    try {
      final mapData = <String, dynamic>{
        'category_id': categoryId,
        'title': title,
        'content': content,
        'status': status,
      };

      if (coverImagePath != null && coverImagePath.isNotEmpty) {
        mapData['cover_image'] = await FileHelper.createMultipartFile(
          coverImagePath,
          filename: coverImagePath.split(RegExp(r'[/\\]')).last,
        );
      }

      final formData = FormData.fromMap(mapData);
      final response = await _dio.post('/articles', data: formData);

      return {
        'success': true,
        'article': Article.fromJson(response.data['data']),
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to create article');
      return {'success': false, 'message': msg};
    }
  }

  // Update article (Expert only)
  // Laravel POST method with _method replacement or normal POST since Route::post('/{id}') is used in backend
  Future<Map<String, dynamic>> updateArticle({
    required int id,
    required int categoryId,
    required String title,
    required String content,
    String? coverImagePath,
    String status = 'published',
  }) async {
    try {
      final mapData = <String, dynamic>{
        'category_id': categoryId,
        'title': title,
        'content': content,
        'status': status,
      };

      if (coverImagePath != null && coverImagePath.isNotEmpty) {
        mapData['cover_image'] = await FileHelper.createMultipartFile(
          coverImagePath,
          filename: coverImagePath.split(RegExp(r'[/\\]')).last,
        );
      }

      final formData = FormData.fromMap(mapData);
      final response = await _dio.post('/articles/$id', data: formData);

      return {
        'success': true,
        'article': Article.fromJson(response.data['data']),
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to update article');
      return {'success': false, 'message': msg};
    }
  }

  // Delete article (Expert only)
  Future<Map<String, dynamic>> deleteArticle(int id) async {
    try {
      final response = await _dio.delete('/articles/$id');
      return {
        'success': true,
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to delete article');
      return {'success': false, 'message': msg};
    }
  }

  // Bookmark / Unbookmark article
  Future<Map<String, dynamic>> toggleBookmark(int id) async {
    try {
      final response = await _dio.post('/articles/$id/bookmark');
      return {
        'success': true,
        'bookmarked': response.data['bookmarked'],
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to bookmark/unbookmark article');
      return {'success': false, 'message': msg};
    }
  }

  // Get bookmarked articles
  Future<Map<String, dynamic>> getBookmarkedArticles({int page = 1}) async {
    try {
      final response = await _dio.get('/articles/user/bookmarks', queryParameters: {'page': page});
      final listJson = response.data['data']['data'] as List;
      // In Laravel BookmarkedArticle relation might return bookmark object. Let's parse BookmarkedArticle properly.
      // Laravel returns: BookmarkedArticle::with(['article.author', 'article.category'])
      // So json['article'] contains the actual article. Let's handle both.
      final articles = listJson.map((json) {
        final articleJson = json['article'];
        if (articleJson != null) {
          final art = Article.fromJson(articleJson);
          art.isBookmarked = true; // since it is from bookmark endpoint
          return art;
        } else {
          return Article.fromJson(json);
        }
      }).toList();

      final lastPage = response.data['data']['last_page'] ?? 1;

      return {
        'success': true,
        'articles': articles,
        'lastPage': lastPage,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load bookmarked articles');
      return {'success': false, 'message': msg};
    }
  }
}