import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/rating_model.dart';

class RatingService {
  final ApiClient _apiClient = ApiClient();
  late final Dio _dio;

  RatingService() {
    _dio = _apiClient.dio;
  }

  // Submit rating and review
  Future<Map<String, dynamic>> submitRating({
    required int consultationId,
    required int score,
    String? comment,
  }) async {
    try {
      final response = await _dio.post('/ratings/consultation/$consultationId', data: {
        'score': score,
        'comment': comment,
      });

      return {
        'success': true,
        'message': response.data['message'],
        'rating': Rating.fromJson(response.data['data']),
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to submit rating');
      return {'success': false, 'message': msg};
    }
  }

  // Get user's submitted ratings
  Future<Map<String, dynamic>> getUserRatings({int page = 1}) async {
    try {
      final response = await _dio.get('/ratings/my-ratings', queryParameters: {'page': page});
      final listJson = response.data['data']['data'] as List;
      final ratings = listJson.map((json) => Rating.fromJson(json)).toList();
      final lastPage = response.data['data']['last_page'] ?? 1;

      return {
        'success': true,
        'ratings': ratings,
        'lastPage': lastPage,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load ratings');
      return {'success': false, 'message': msg};
    }
  }

  // Get expert's received ratings
  Future<Map<String, dynamic>> getExpertRatings({int page = 1}) async {
    try {
      final response = await _dio.get('/ratings/expert-ratings', queryParameters: {'page': page});
      final listJson = response.data['data']['ratings']['data'] as List;
      final ratings = listJson.map((json) => Rating.fromJson(json)).toList();
      final lastPage = response.data['data']['ratings']['last_page'] ?? 1;

      return {
        'success': true,
        'ratings': ratings,
        'lastPage': lastPage,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load expert ratings');
      return {'success': false, 'message': msg};
    }
  }

  // Get public ratings for an expert
  Future<Map<String, dynamic>> getPublicExpertRatings(int expertId, {int page = 1}) async {
    try {
      final response = await _dio.get('/ratings/expert/$expertId', queryParameters: {'page': page});
      final listJson = response.data['data']['ratings']['data'] as List;
      final ratings = listJson.map((json) => Rating.fromJson(json)).toList();
      final lastPage = response.data['data']['ratings']['last_page'] ?? 1;

      return {
        'success': true,
        'ratings': ratings,
        'lastPage': lastPage,
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load ratings');
      return {'success': false, 'message': msg};
    }
  }

  // Get consultations that need a rating
  Future<Map<String, dynamic>> getPendingRatings() async {
    try {
      final response = await _dio.get('/ratings/pending');
      final listJson = response.data['data'] as List;
      // In Laravel RatingController, pendingRatings returns array of consultations or ratings. Let's parse appropriately.
      return {
        'success': true,
        'consultationIds': listJson.map((json) => json['id'] as int).toList(),
      };
    } on DioException catch (e) {
      final msg = e.getErrorMessage('Failed to load pending ratings');
      return {'success': false, 'message': msg};
    }
  }
}